extends Node2D


func _on_exit_button_up():
	get_tree().change_scene_to_file(Global.SCENE.menu)
