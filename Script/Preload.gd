extends Node

func apply_config():
	get_window().mode = Global.WINDOW_MODE_MAP[Global.CONFIG.window_mode_option]

# Called when the node enters the scene tree for the first time.
func _ready():
	apply_config()
