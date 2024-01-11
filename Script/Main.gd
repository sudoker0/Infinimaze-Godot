extends Node2D
@export var TIMER_LABEL: Label
@export var EFFECT_LABEL: Label
@export var INSTANT_EFFECT_LABEL: Label
@export var PLAYER: CharacterBody2D

func start_game():
	Global.currentGameState.endTime = Time.get_ticks_msec() + 60000

func pause_game():
	pass

func stop_game():
	pass

func _ready():
	start_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	TIMER_LABEL.pivot_offset = TIMER_LABEL.size / 2
	EFFECT_LABEL.pivot_offset = Vector2(EFFECT_LABEL.size.x, 0)
	INSTANT_EFFECT_LABEL.pivot_offset = INSTANT_EFFECT_LABEL.size / 2
	var deltaTime = float(Global.currentGameState.endTime - Time.get_ticks_msec())
	TIMER_LABEL.text = str(Global.TEXT.timer_text % (deltaTime / 1000))
	pass
