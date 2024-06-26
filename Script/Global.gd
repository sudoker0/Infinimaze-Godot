extends Node

enum Difficulty {
	EASY,
	MEDIUM,
	HARD
}

enum WindowMode {
	EXCLUSIVE_FULLSCREEN,
	FULLSCREEN,
	WINDOWED
}

const ITEM_STAT = {
	Difficulty.EASY: {
		"min_clock_time": 5,
		"max_clock_time": 10,
		"min_randomized_clock_time": -10,
		"max_randomized_clock_time": 15,
		"speed_boost": [2, 4, 5],
		"speed_boost_time": 15,
		"min_noclip": 5,
		"max_noclip": 7.5,
		"min_teleporter": 10,
		"max_teleporter": 20,
		"teleporter_decrease_time": 2,
		"min_trap": 3,
		"max_trap": 5,
		"bomb_radius": 10,
		"bomb_wait_time": 5,
		"banana_peel_friction": 500,
		"banana_peel_time": 10,
		"darkness_min_time": 5,
		"darkness_max_time": 10,
		"darkness_intensity": 10,
	},
	Difficulty.MEDIUM: {
		"min_clock_time": 2.5,
		"max_clock_time": 5,
		"min_randomized_clock_time": -20,
		"max_randomized_clock_time": 15,
		"speed_boost": [2, 4],
		"speed_boost_time": 10,
		"min_noclip": 3,
		"max_noclip": 5,
		"min_teleporter": 10,
		"max_teleporter": 20,
		"teleporter_decrease_time": 5,
		"min_trap": 5,
		"max_trap": 15,
		"bomb_radius": 20,
		"bomb_wait_time": 4,
		"banana_peel_friction": 100,
		"banana_peel_time": 20,
		"darkness_min_time": 10,
		"darkness_max_time": 20,
		"darkness_intensity": 15,
	},
	Difficulty.HARD: {
		"min_clock_time": 2,
		"max_clock_time": 3,
		"min_randomized_clock_time": -30,
		"max_randomized_clock_time": 20,
		"speed_boost": [2],
		"speed_boost_time": 5,
		"min_noclip": 0,
		"max_noclip": 0,
		"min_teleporter": 10,
		"max_teleporter": 20,
		"teleporter_decrease_time": 7,
		"min_trap": 10,
		"max_trap": 30,
		"bomb_radius": 30,
		"bomb_wait_time": 0,
		"banana_peel_friction": 0,
		"banana_peel_time": 15,
		"darkness_min_time": 15,
		"darkness_max_time": 30,
		"darkness_intensity": 20,
	}
}

const BOARD_BLOCK = {
	"PATH": Vector2i(0, 0),
	"WALL": Vector2i(1, 0),
}

enum ITEMS {
	CLOCK,
	RANDOMIZED_CLOCK,
	SPEED_BOOST,
	NOCLIP,
	TELEPORTER,
	TRAP,
	BOMB,
	BANANA_PEEL,
	DARKNESS
}

enum EFFECTS {
	SPEED_BOOST,
	NOCLIP,
	TRAP,
	BANANA_PEEL,
	DARKNESS
}

const CONSTANT = {
	"chunk_size": 32,
	"block_size": 32,
	"render_distance": 1,
	"max_time": 100,
	"crouching_speed_factor": 0.2,
	"initial_time": 60,
	"chunk_filepath": "user://chunk-x%sy%s.data",
	"settings_filepath": "user://config.cfg",
	"default_player_skin": "res://Resources/Image/player.png",
	"custom_player_skin": "user://custom_skin.png",
}

const SCENE = {
	"main": "res://Scene/Main.tscn",
	"menu": "res://Scene/Menu.tscn",
	"options": "res://Scene/Options.tscn",
	"about": "res://Scene/About.tscn",
	"help": "res://Scene/Help.tscn",
}

var currentGameState = {
	"stopped": false,
	"timeleft": 0,
	"elapsed": 0,
	"score": 0
}

var WINDOW_MODE_MAP = {
	WindowMode.EXCLUSIVE_FULLSCREEN: Window.MODE_EXCLUSIVE_FULLSCREEN,
	WindowMode.FULLSCREEN: Window.MODE_FULLSCREEN,
	WindowMode.WINDOWED: Window.MODE_WINDOWED
}

const TEXT = {
	"timer_text": "TIME LEFT: %.2fs",
	"teleported_text": "TELEPORTED!",
	"score_time_text": "SCORE: %s | ELAPSED: %ss",
	"game_over_stat_text": "YOU SURVIVED FOR %s SECONDS AND SCORED %s POINTS",
	"easy_difficulty": "EASY",
	"medium_difficulty": "MEDIUM",
	"hard_difficulty": "HARD",
	"exclusive_fullscreen_window_mode": "EXCLUSIVE FULLSCREEN",
	"fullscreen_window_mode": "FULLSCREEN",
	"windowed_window_mode": "WINDOWED",
}

var CONFIG = {
	"window_mode_option": WindowMode.EXCLUSIVE_FULLSCREEN,
	"difficulty": Difficulty.MEDIUM,
	"crt_shader_scanline": true,
	"crt_shader_chromatic_aberration": true,
	"sound_effect_volume": 100,
	"bg_music_volume": 50,
	"debug": false,
	"player_skin_path": CONSTANT.default_player_skin,
}

func load_config():
	var config = ConfigFile.new()
	var status = config.load(CONSTANT.settings_filepath)

	if status != OK:
		save_config()
		return

	for i in config.get_section_keys("main"):
		if CONFIG.get(i, null) == null:
			continue
		CONFIG[i] = config.get_value("main", i)

func save_config():
	var config = ConfigFile.new()
	for i in CONFIG.keys():
		config.set_value("main", i, CONFIG[i])
	config.save(CONSTANT.settings_filepath)
	Preload.apply_config()

func _ready():
	load_config()
