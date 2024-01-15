extends CanvasLayer
@export var PAUSE_CONTAINER: Control

signal paused
signal unpaused

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func pause_unpause():
	get_tree().paused = not get_tree().paused
	PAUSE_CONTAINER.visible = get_tree().paused
	if get_tree().paused:
		emit_signal("paused")
		var tween = create_tween()
		tween\
			.tween_property(PAUSE_CONTAINER, "scale", Vector2(1.0, 1.0), 0.1)\
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	else:
		emit_signal("unpaused")
		PAUSE_CONTAINER.scale = Vector2(1.2, 1.2)

func _input(event):
	if event.is_action_released("pause"):
		pause_unpause()
