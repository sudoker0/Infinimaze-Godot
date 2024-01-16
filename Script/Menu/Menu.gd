extends Node2D

@export var MAZE_TEXTURE: TextureRect
var rng = RandomNumberGenerator.new()

func _ready():
	var imageWidth = MAZE_TEXTURE.size.x
	var imageHeight = MAZE_TEXTURE.size.y
	var viewportWidth = get_viewport_rect().size.x
	var viewportHeight = get_viewport_rect().size.y

	var posX = rng.randf_range(viewportWidth - imageWidth, 0)
	var posY = rng.randf_range(viewportHeight - imageHeight, 0)

	MAZE_TEXTURE.position = Vector2(posX, posY)
	pass

func button_play():
	get_tree().change_scene_to_file(Global.SCENE.main)

func button_option():
	get_tree().change_scene_to_file(Global.SCENE.options)

func button_about():
	get_tree().change_scene_to_file(Global.SCENE.about)

func button_help():
	get_tree().change_scene_to_file(Global.SCENE.help)

func button_exit():
	get_tree().quit()
