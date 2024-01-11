extends Node
class_name ItemHandler
@export var BOARD: TileMap
@export var PLAYER: CharacterBody2D
@export var TIMER_LABEL: Label
@export var INSTANT_EFFECT_LABEL: Label
@export var EFFECT_LABEL: Label

var rng = RandomNumberGenerator.new()
var difficulty = Global.currentGameState.difficulty
var stat = Global.ITEM_STAT[difficulty]

const effectDetail = {
	Global.EFFECTS.BANANA_PEEL: {
		"text": "Banana Peel"
	},
	Global.EFFECTS.SPEED_BOOST: {
		"text": "Speed Boost (%sx)"
	},
	Global.EFFECTS.TRAP: {
		"text": "Freeze"
	},
	Global.EFFECTS.NOCLIP: {
		"text": "Noclip"
	}
}

var effectList = [
	#{ // example
		#"effect": Global.EFFECTS.SPEED_BOOST,
		#"display": "Speed Boost (2x)"
		#"previous_data": {...}
		#"endTime": 0
	#}
]

func add_effect(effect, display, previous_data, endTime):
	var data = {
		"effect": effect,
		"display": display,
		"previous_data": previous_data,
		"endTime": endTime
	}
	for i in range(len(effectList)):
		if effectList[i].effect == effect:
			data.previous_data = effectList[i].previous_data
			effectList[i] = data
			return [true, data.previous_data]

	effectList.append(data)
	return [false, null]

func apply_zoom_in(node, response: Callable = func(): null):
	var tween = create_tween()
	tween.tween_property(node, "scale", Vector2(2.15, 2.15), 0.1)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(1, 1), 1.2)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.connect("finished", response)

func apply_instant_label(text):
	INSTANT_EFFECT_LABEL.text = text
	apply_zoom_in(INSTANT_EFFECT_LABEL, func(): INSTANT_EFFECT_LABEL.text = "")

func clock_handler():
	rng.randomize()
	Global.currentGameState.endTime += rng.randf_range(
		stat.min_clock_time, stat.max_clock_time) * 1000
	apply_zoom_in(TIMER_LABEL)

func randomized_clock_hander():
	rng.randomize()
	Global.currentGameState.endTime += rng.randf_range(
		stat.min_randomized_clock_time, stat.max_randomized_clock_time) * 1000
	apply_zoom_in(TIMER_LABEL)

func speed_boost_handler():
	apply_zoom_in(EFFECT_LABEL)
	rng.randomize()
	var boost = stat.speed_boost[rng.randi_range(0, len(stat.speed_boost) - 1)]
	var boostTime = stat.speed_boost_time

	var output = add_effect(
		Global.EFFECTS.SPEED_BOOST,
		effectDetail[Global.EFFECTS.SPEED_BOOST].text % (boost),
		{
			"MAX_SPEED": PLAYER.MAX_SPEED,
			"ACCELERATION": PLAYER.ACCELERATION
		},
		Time.get_ticks_msec() + boostTime * 1000
	)
	if output[0]:
		undo_speed_boost(output[1])

	PLAYER.MAX_SPEED *= boost
	PLAYER.ACCELERATION *= boost
func undo_speed_boost(previous_data):
	PLAYER.MAX_SPEED = previous_data.MAX_SPEED
	PLAYER.ACCELERATION = previous_data.ACCELERATION

func noclip_handler():
	apply_zoom_in(EFFECT_LABEL)
	rng.randomize()
	var noclipTime = \
		rng.randf_range(stat.min_noclip, stat.max_noclip)

	var output = add_effect(
		Global.EFFECTS.NOCLIP,
		effectDetail[Global.EFFECTS.NOCLIP].text,
		{
			"COLLISION_BIT": PLAYER.collision_mask
		},
		Time.get_ticks_msec() + noclipTime * 1000
	)
	if output[0]:
		undo_noclip(output[1])

	PLAYER.set_collision_mask_value(1, 0)
func undo_noclip(previous_data):
	PLAYER.set_collision_mask_value(1, previous_data.COLLISION_BIT)

func teleporter_handler():
	apply_instant_label(Global.TEXT.teleported_text)
	rng.randomize()
	var teleportRadius = rng.randi_range(stat.min_teleporter, stat.max_teleporter)
	var playerBlockLocation = floor(PLAYER.position / Global.CONSTANT.block_size)
	var teleportLocation = {
		"left": playerBlockLocation.x - teleportRadius,
		"right": playerBlockLocation.x + teleportRadius,
		"top": playerBlockLocation.y - teleportRadius,
		"bottom": playerBlockLocation.y + teleportRadius,
	}

	var possibleLocation = []
	var helper = func(location):
		var block = BOARD.get_cell_atlas_coords(0, location)
		if block != Global.BOARD_BLOCK.PATH:
			return
		possibleLocation.append(location)

	# left and right
	for y in range(teleportLocation.top, teleportLocation.bottom + 1):
		# left
		var location = Vector2i(teleportLocation.left, y)
		helper.call(location)
		# right
		location = Vector2i(teleportLocation.right, y)
		helper.call(location)

	# top and bottom
	for x in range(teleportLocation.left, teleportLocation.right + 1):
		# top
		var location = Vector2i(x, teleportLocation.top)
		helper.call(location)
		# bottom
		location = Vector2i(x, teleportLocation.bottom)
		helper.call(location)

	if len(possibleLocation) <= 0:
		return
	PLAYER.position = \
		possibleLocation[rng.randi_range(0, len(possibleLocation) - 1)]

func trap_handler():
	apply_zoom_in(EFFECT_LABEL)
	rng.randomize()
	var trapTime = rng.randf_range(stat.min_trap, stat.max_trap)

	var output = add_effect(
		Global.EFFECTS.TRAP,
		effectDetail[Global.EFFECTS.TRAP].text,
		{
			"FREEZE": PLAYER.FREEZE
		},
		Time.get_ticks_msec() + trapTime * 1000
	)
	if output[0]:
		undo_trap(output[1])

	PLAYER.FREEZE = true
func undo_trap(previous_data):
	PLAYER.FREEZE = previous_data.FREEZE

static func bomb_handler():
	pass

func banana_peel_handler():
	apply_zoom_in(EFFECT_LABEL)
	var trapTime = stat.banana_peel_time
	var output = add_effect(
		Global.EFFECTS.BANANA_PEEL,
		effectDetail[Global.EFFECTS.BANANA_PEEL].text,
		{
			"FRICTION": PLAYER.FRICTION
		},
		Time.get_ticks_msec() + trapTime * 1000
	)
	if output[0]:
		undo_banana_peel(output[1])

	PLAYER.FRICTION = stat.banana_peel_friction
func undo_banana_peel(previous_data):
	PLAYER.FRICTION = previous_data.FRICTION

func _process(delta):
	EFFECT_LABEL.text = ""
	var currentTime = Time.get_ticks_msec()

	for i in effectList:
		EFFECT_LABEL.text += \
			i.display + \
			" (%.2fs)" % ((float)(i.endTime - currentTime) / 1000) + \
			"\n"

		if currentTime < i.endTime:
			continue
		match i.effect:
			Global.EFFECTS.SPEED_BOOST:
				undo_speed_boost(i.previous_data)
			Global.EFFECTS.TRAP:
				undo_trap(i.previous_data)
			Global.EFFECTS.BANANA_PEEL:
				undo_banana_peel(i.previous_data)
			Global.EFFECTS.NOCLIP:
				undo_noclip(i.previous_data)
		effectList.erase(i)
