extends Node2D
@export var TIMER_LABEL: Label
@export var EFFECT_LABEL: Label
@export var INSTANT_EFFECT_LABEL: Label
@export var TIMER_PROGRESS_BAR: ProgressBar
@export var SCORE_TIME_LABEL: Label

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	center_pivot(TIMER_LABEL)
	center_pivot(TIMER_PROGRESS_BAR)
	center_pivot(INSTANT_EFFECT_LABEL)
	EFFECT_LABEL.pivot_offset = Vector2(EFFECT_LABEL.size.x, 0)

	var deltaTime = float(Global.currentGameState.endTime - Time.get_ticks_msec())
	var elapsed = int((Time.get_ticks_msec() - startTime) / 1000)
	TIMER_LABEL.text = str(Global.TEXT.timer_text % (deltaTime / 1000))
	TIMER_PROGRESS_BAR.value = deltaTime / 1000

	SCORE_TIME_LABEL.text = Global.TEXT.score_time_text % [Global.currentGameState.score, elapsed]
