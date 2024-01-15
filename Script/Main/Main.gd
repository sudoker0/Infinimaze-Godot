extends Node2D

@export var PARTICLES: GPUParticles2D
@export var PLAYER: CharacterBody2D

@export var TIMER_PROGRESS_BAR: ProgressBar
@export var TIMER_LABEL: Label
@export var INSTANT_EFFECT_LABEL: Label
@export var EFFECT_LABEL: Label
@export var SCORE_TIME_LABEL: Label

@export var SOUND_EFFECT_HANDLER: AudioStreamPlayer
@export var GAME_OVER_CONTAINER: Control
@export var GAME_OVER_STAT_LABEL: Label

@export var PAUSE_CONTAINER: Control

@export var DIE_SOUND_EFFECT: AudioStream
@export var PICKUP_SOUND_EFFECT: AudioStream

@export var DEBUG_CONTAINER: Control
@export var DEBUG_TEXT: RichTextLabel

signal game_over_signal
signal game_start_signal

func start_game():
	PLAYER.visible = true
	GAME_OVER_CONTAINER.scale = Vector2(1.2, 1.2)
	GAME_OVER_CONTAINER.visible = false
	Global.currentGameState.stopped = false
	PLAYER.position = Vector2(
		Global.CONSTANT.block_size / 2,
		Global.CONSTANT.block_size / 2)

	Global.currentGameState.timeleft = Global.CONSTANT.initial_time * 1000
	Global.currentGameState.elapsed = 0
	Global.currentGameState.score = 0

	emit_signal("game_start_signal")

func pause_game():
	pass

func game_over(time, score):
	PLAYER.visible = false
	PARTICLES.position = PLAYER.position
	PARTICLES.emitting = true
	
	GAME_OVER_CONTAINER.visible = true
	GAME_OVER_STAT_LABEL.text = Global.TEXT.game_over_stat_text %\
		[time, score]

	var tween = create_tween()
	tween\
		.tween_property(GAME_OVER_CONTAINER, "scale", Vector2(1.0, 1.0), 0.1)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	SOUND_EFFECT_HANDLER.stream = DIE_SOUND_EFFECT
	SOUND_EFFECT_HANDLER.play()

	emit_signal("game_over_signal")
	stop_game()

func stop_game():
	Global.currentGameState.stopped = true
	pass

func return_to_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file(Global.SCENE.menu)

func _ready():
	DEBUG_CONTAINER.visible = Global.CONFIG.debug
	start_game()

func debug_display(delta):
	var playerBlockPos = PLAYER.position / Global.CONSTANT.block_size
	playerBlockPos = floor(playerBlockPos)
	
	var text = ""
	text += "fps: %s\n" % floor(1 / delta)
	text += "player block position (x|y): %s | %s\n" % [playerBlockPos.x, playerBlockPos.y]
	DEBUG_TEXT.text = text

func center_pivot(node):
	node.pivot_offset = node.size / 2

# Called every frame. 'delta' is the elapsedtime since the previous frame.
func _process(delta):
	debug_display(delta)
	SOUND_EFFECT_HANDLER.volume_db =\
		linear_to_db(Global.CONFIG.sound_effect_volume / 100)
	
	if Global.currentGameState.stopped:
		return

	Global.currentGameState.timeleft -= delta * 1000
	Global.currentGameState.timeleft =\
		clamp(
			Global.currentGameState.timeleft,
			0,
			Global.CONSTANT.max_time * 1000
		)
	Global.currentGameState.elapsed += delta * 1000

	center_pivot(TIMER_LABEL)
	center_pivot(TIMER_PROGRESS_BAR)
	center_pivot(INSTANT_EFFECT_LABEL)
	center_pivot(SCORE_TIME_LABEL)
	center_pivot(GAME_OVER_CONTAINER)
	center_pivot(PAUSE_CONTAINER)
	EFFECT_LABEL.pivot_offset = Vector2(EFFECT_LABEL.size.x, 0)

	TIMER_LABEL.text = str(
		Global.TEXT.timer_text % (Global.currentGameState.timeleft / 1000))
	TIMER_PROGRESS_BAR.value = Global.currentGameState.timeleft / 1000

	var elapsed = int(Global.currentGameState.elapsed / 1000)
	SCORE_TIME_LABEL.text =\
		Global.TEXT.score_time_text % [Global.currentGameState.score, elapsed]

	if Global.currentGameState.timeleft <= 0:
		game_over(elapsed, Global.currentGameState.score)
