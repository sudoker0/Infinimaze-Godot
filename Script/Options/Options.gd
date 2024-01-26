extends Node2D

@export var DIFFICULTY_OPTION: OptionButton
@export var WINDOW_MODE_OPTION: OptionButton
@export var ENABLE_SCANLINE_CHECK: CheckButton
@export var ENABLE_CHROMATIC_ABERRATION_CHECK: CheckButton
@export var SFX_VOLUME_SLIDER: HSlider
@export var DEBUG_DIALOG_CHECK: CheckButton

@export var CHANGE_SAVED_DIALOG: Container
@export var PLAYER_SKIN_CHOOSER: FileDialog

var difficultyMap = {
	Global.Difficulty.EASY: Global.TEXT.easy_difficulty,
	Global.Difficulty.MEDIUM: Global.TEXT.medium_difficulty,
	Global.Difficulty.HARD: Global.TEXT.hard_difficulty,
}

var windowModeMap = {
	Global.WindowMode.EXCLUSIVE_FULLSCREEN: Global.TEXT.exclusive_fullscreen_window_mode,
	Global.WindowMode.FULLSCREEN: Global.TEXT.fullscreen_window_mode,
	Global.WindowMode.WINDOWED: Global.TEXT.windowed_window_mode,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in difficultyMap.keys():
		DIFFICULTY_OPTION.add_item(difficultyMap[i], i)
	for i in windowModeMap.keys():
		WINDOW_MODE_OPTION.add_item(windowModeMap[i], i)
	Global.load_config()

	DIFFICULTY_OPTION.selected = Global.CONFIG.difficulty
	WINDOW_MODE_OPTION.selected = Global.CONFIG.window_mode_option
	ENABLE_SCANLINE_CHECK.button_pressed = Global.CONFIG.crt_shader_scanline
	ENABLE_CHROMATIC_ABERRATION_CHECK.button_pressed = Global.CONFIG.crt_shader_chromatic_aberration
	SFX_VOLUME_SLIDER.value = Global.CONFIG.sound_effect_volume
	DEBUG_DIALOG_CHECK.button_pressed = Global.CONFIG.debug

func center_pivot(node):
	node.pivot_offset = node.size / 2

func _on_ok_change_saved_button_up():
	CHANGE_SAVED_DIALOG.visible = false
	CHANGE_SAVED_DIALOG.scale = Vector2(1.2, 1.2)

func _on_save_button_up():
	Global.CONFIG.difficulty = DIFFICULTY_OPTION.get_selected_id()
	Global.CONFIG.window_mode_option = WINDOW_MODE_OPTION.get_selected_id()
	Global.CONFIG.crt_shader_scanline = ENABLE_SCANLINE_CHECK.button_pressed
	Global.CONFIG.crt_shader_chromatic_aberration = ENABLE_CHROMATIC_ABERRATION_CHECK.button_pressed
	Global.CONFIG.sound_effect_volume = SFX_VOLUME_SLIDER.value
	Global.CONFIG.debug = DEBUG_DIALOG_CHECK.button_pressed

	Global.save_config()
	CHANGE_SAVED_DIALOG.visible = true
	var tween = create_tween()
	tween\
		.tween_property(CHANGE_SAVED_DIALOG, "scale", Vector2(1.0, 1.0), 0.1)\
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func _on_exit_button_up():
	get_tree().change_scene_to_file(Global.SCENE.menu)

func _process(delta):
	center_pivot(CHANGE_SAVED_DIALOG)

func choose_player_skin():
	PLAYER_SKIN_CHOOSER.add_filter("*.png, *.jpg")
	PLAYER_SKIN_CHOOSER.popup()

func reset_player_skin():
	Global.CONFIG.player_skin_path = Global.CONSTANT.default_player_skin

func _on_player_skin_chooser_file_selected(path):
	Global.CONFIG.player_skin_path = path
