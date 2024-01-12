extends Node
class_name ItemHandler

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
	},
	Global.EFFECTS.DARKNESS: {
		"text": "Darkness"
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
	Global.INSTANT_EFFECT_LABEL.text = text
	apply_zoom_in(
		Global.INSTANT_EFFECT_LABEL, func(): Global.INSTANT_EFFECT_LABEL.text = "")

func clock_handler():
	rng.randomize()
	Global.currentGameState.endTime += rng.randf_range(
		stat.min_clock_time, stat.max_clock_time) * 1000
	apply_zoom_in(Global.TIMER_PROGRESS_BAR)
	apply_zoom_in(Global.SCORE_TIME_LABEL)

func randomized_clock_hander():
	rng.randomize()
	Global.currentGameState.endTime += rng.randf_range(
		stat.min_randomized_clock_time, stat.max_randomized_clock_time) * 1000
	apply_zoom_in(Global.TIMER_PROGRESS_BAR)
	apply_zoom_in(Global.SCORE_TIME_LABEL)

func speed_boost_handler():
	apply_zoom_in(Global.EFFECT_LABEL)
	apply_zoom_in(Global.SCORE_TIME_LABEL)

	rng.randomize()
	var boost = stat.speed_boost[rng.randi_range(0, len(stat.speed_boost) - 1)]
	var boostTime = stat.speed_boost_time

	var output = add_effect(
		Global.EFFECTS.SPEED_BOOST,
		effectDetail[Global.EFFECTS.SPEED_BOOST].text % (boost),
		{
			"MAX_SPEED": Global.PLAYER.MAX_SPEED,
			"ACCELERATION": Global.PLAYER.ACCELERATION
		},
		Time.get_ticks_msec() + boostTime * 1000
	)
	if output[0]:
		undo_speed_boost(output[1])

	Global.PLAYER.MAX_SPEED *= boost
	Global.PLAYER.ACCELERATION *= boost
func undo_speed_boost(previous_data):
	Global.PLAYER.MAX_SPEED = previous_data.MAX_SPEED
	Global.PLAYER.ACCELERATION = previous_data.ACCELERATION
	return true

func noclip_handler():
	apply_zoom_in(Global.EFFECT_LABEL)
	apply_zoom_in(Global.SCORE_TIME_LABEL)

	rng.randomize()
	var noclipTime = \
		rng.randf_range(stat.min_noclip, stat.max_noclip)

	var output = add_effect(
		Global.EFFECTS.NOCLIP,
		effectDetail[Global.EFFECTS.NOCLIP].text,
		{
			"COLLISION_BIT": Global.PLAYER.collision_mask
		},
		Time.get_ticks_msec() + noclipTime * 1000
	)
	if output[0]:
		undo_noclip(output[1])

	Global.PLAYER.set_collision_mask_value(1, 0)
func undo_noclip(previous_data):
	var blockPos = floor(Global.PLAYER.position / Global.CONSTANT.block_size)
	var block = Global.BOARD_TILEMAP.get_cell_atlas_coords(0, blockPos)
	if block == Global.BOARD_BLOCK.WALL:
		return false

	Global.PLAYER.set_collision_mask_value(1, previous_data.COLLISION_BIT)
	return true

func teleporter_handler():
	apply_instant_label(Global.TEXT.teleported_text)
	apply_zoom_in(Global.SCORE_TIME_LABEL)

	rng.randomize()
	var teleportRadius = rng.randi_range(
		stat.min_teleporter, stat.max_teleporter)
	var playerBlockLocation = floor(
		Global.PLAYER.position / Global.CONSTANT.block_size)

	var teleportLocation = {
		"left": playerBlockLocation.x - teleportRadius,
		"right": playerBlockLocation.x + teleportRadius,
		"top": playerBlockLocation.y - teleportRadius,
		"bottom": playerBlockLocation.y + teleportRadius,
	}

	var possibleLocation = []
	var helper = func(location):
		var block = Global.BOARD_TILEMAP.get_cell_atlas_coords(0, location)
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
	Global.PLAYER.position = \
		possibleLocation[rng.randi_range(0, len(possibleLocation) - 1)]

	Global.currentGameState.endTime -= stat.teleporter_decrease_time * 1000
	apply_zoom_in(Global.TIMER_PROGRESS_BAR)

func trap_handler():
	apply_zoom_in(Global.EFFECT_LABEL)
	rng.randomize()
	var trapTime = rng.randf_range(stat.min_trap, stat.max_trap)

	var output = add_effect(
		Global.EFFECTS.TRAP,
		effectDetail[Global.EFFECTS.TRAP].text,
		{
			"FREEZE": Global.PLAYER.FREEZE
		},
		Time.get_ticks_msec() + trapTime * 1000
	)
	if output[0]:
		undo_trap(output[1])

	Global.PLAYER.FREEZE = true
func undo_trap(previous_data):
	Global.PLAYER.FREEZE = previous_data.FREEZE
	return true

static func bomb_handler():
	pass

func banana_peel_handler():
	apply_zoom_in(Global.EFFECT_LABEL)
	apply_zoom_in(Global.SCORE_TIME_LABEL)

	var trapTime = stat.banana_peel_time
	var output = add_effect(
		Global.EFFECTS.BANANA_PEEL,
		effectDetail[Global.EFFECTS.BANANA_PEEL].text,
		{
			"FRICTION": Global.PLAYER.FRICTION
		},
		Time.get_ticks_msec() + trapTime * 1000
	)
	if output[0]:
		undo_banana_peel(output[1])

	Global.PLAYER.FRICTION = stat.banana_peel_friction
func undo_banana_peel(previous_data):
	Global.PLAYER.FRICTION = previous_data.FRICTION
	return true

func darkness_handler():
	apply_zoom_in(Global.EFFECT_LABEL)
	apply_zoom_in(Global.SCORE_TIME_LABEL)

	rng.randomize()
	var darknessTime = rng.randf_range(
		stat.darkness_min_time, stat.darkness_max_time)

	var output = add_effect(
		Global.EFFECTS.DARKNESS,
		effectDetail[Global.EFFECTS.DARKNESS].text,
		{
			"INTENSITY": Global.VIGNETTE_OVERLAY.material\
				.get_shader_parameter("vignette_intensity")
		},
		Time.get_ticks_msec() + darknessTime * 1000
	)
	if output[0]:
		undo_darkness(output[1])

	Global.VIGNETTE_OVERLAY.material\
		.set_shader_parameter("vignette_intensity", stat.darkness_intensity)

func undo_darkness(previous_data):
	Global.VIGNETTE_OVERLAY.material\
		.set_shader_parameter("vignette_intensity", previous_data.INTENSITY)
	return true

func _process(_delta):
	Global.EFFECT_LABEL.text = ""
	var currentTime = Time.get_ticks_msec()

	for i in effectList:
		var diffTime = (float)(i.endTime - currentTime) / 1000
		diffTime = max(0, diffTime)
		Global.EFFECT_LABEL.text += \
			i.display + \
			" (%.2fs)" % (diffTime) + \
			"\n"

		if currentTime < i.endTime:
			continue

		var status = false
		match i.effect:
			Global.EFFECTS.SPEED_BOOST:
				status = undo_speed_boost(i.previous_data)
			Global.EFFECTS.TRAP:
				status = undo_trap(i.previous_data)
			Global.EFFECTS.BANANA_PEEL:
				status = undo_banana_peel(i.previous_data)
			Global.EFFECTS.NOCLIP:
				status = undo_noclip(i.previous_data)
			Global.EFFECTS.DARKNESS:
				status = undo_darkness(i.previous_data)

		if status:
			effectList.erase(i)
