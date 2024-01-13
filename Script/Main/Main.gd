extends Node2D
var startTime = 0

signal game_over_signal
signal game_start_signal

func start_game():
	Global.PLAYER.visible = true
	Global.GAME_OVER_CONTAINER.visible = false
	Global.currentGameState.stopped = false
	Global.PLAYER.position = Vector2(
		Global.CONSTANT.block_size / 2,
		Global.CONSTANT.block_size / 2)

	startTime = Time.get_ticks_msec()
	Global.currentGameState.endTime =\
		Time.get_ticks_msec() + Global.CONSTANT.initial_time * 1000
	Global.currentGameState.score = 0

	emit_signal("game_start_signal")

func pause_game():
	pass

func game_over(time, score):
	Global.PLAYER.visible = false
	Global.PARTICLES.position = Global.PLAYER.position
	Global.PARTICLES.emitting = true
	
	Global.GAME_OVER_CONTAINER.visible = true
	Global.GAME_OVER_STAT_LABEL.text = Global.TEXT.game_over_stat_text %\
		[time, score]

	var tween = create_tween()
	tween\
		.tween_property(Global.GAME_OVER_CONTAINER, "scale", Vector2(1.0, 1.0), 0.1)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	Global.SOUND_EFFECT_HANDLER.stream = Global.DIE_SOUND_EFFECT
	Global.SOUND_EFFECT_HANDLER.play()

	emit_signal("game_over_signal")
	stop_game()

func stop_game():
	Global.currentGameState.stopped = true
	pass

func return_to_menu():
	get_tree().change_scene_to_file(Global.SCENE.menu)

func _ready():
	start_game()

func center_pivot(node):
	node.pivot_offset = node.size / 2

# Called every frame. 'delta' is the elapsedtime since the previous frame.
func _process(_delta):
	if Global.currentGameState.stopped:
		return

	Global.currentGameState.endTime =\
		clamp(
			Global.currentGameState.endTime,
			Time.get_ticks_msec(),
			Time.get_ticks_msec() + Global.CONSTANT.max_time * 1000)

	center_pivot(Global.TIMER_LABEL)
	center_pivot(Global.TIMER_PROGRESS_BAR)
	center_pivot(Global.INSTANT_EFFECT_LABEL)
	center_pivot(Global.SCORE_TIME_LABEL)
	center_pivot(Global.GAME_OVER_CONTAINER)
	Global.EFFECT_LABEL.pivot_offset = Vector2(Global.EFFECT_LABEL.size.x, 0)

	var deltaTime = float(Global.currentGameState.endTime - Time.get_ticks_msec())
	deltaTime = max(0, deltaTime)

	Global.TIMER_LABEL.text = str(Global.TEXT.timer_text % (deltaTime / 1000))
	Global.TIMER_PROGRESS_BAR.value = deltaTime / 1000

	var elapsed = int((Time.get_ticks_msec() - startTime) / 1000)
	Global.SCORE_TIME_LABEL.text =\
		Global.TEXT.score_time_text % [Global.currentGameState.score, elapsed]

	if deltaTime <= 0:
		game_over(elapsed, Global.currentGameState.score)
