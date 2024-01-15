extends Node2D
@export var ANIMATION: AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	ANIMATION.play("fade_in")
	await get_tree().create_timer(7).timeout
	get_tree().change_scene_to_file(Global.SCENE.menu)
