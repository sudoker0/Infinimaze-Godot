extends Node2D

var startTime = 0

func start_game():
	startTime = Time.get_ticks_msec()
	Global.currentGameState.endTime = Time.get_ticks_msec() + 60000

func pause_game():
	pass

func stop_game():
	pass

func _ready():
	start_game()

func center_pivot(node):
	node.pivot_offset = node.size / 2

# Called every frame. 'delta' is the elapsedtime since the previous frame.
func _process(_delta):
	center_pivot(Global.TIMER_LABEL)
	center_pivot(Global.TIMER_PROGRESS_BAR)
	center_pivot(Global.INSTANT_EFFECT_LABEL)
	center_pivot(Global.SCORE_TIME_LABEL)
	Global.EFFECT_LABEL.pivot_offset = Vector2(Global.EFFECT_LABEL.size.x, 0)

	var deltaTime = float(Global.currentGameState.endTime - Time.get_ticks_msec())
	var elapsed = int((Time.get_ticks_msec() - startTime) / 1000)
	Global.TIMER_LABEL.text = str(Global.TEXT.timer_text % (deltaTime / 1000))
	Global.TIMER_PROGRESS_BAR.value = deltaTime / 1000

	Global.SCORE_TIME_LABEL.text = Global.TEXT.score_time_text % [Global.currentGameState.score, elapsed]
