extends Node

enum Difficulty {
	EASY,
	MEDIUM,
	HARD
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
		"min_trap": 3,
		"max_trap": 5,
		"bomb_radius": 10,
		"bomb_wait_time": 5,
		"banana_peel_friction": 500,
		"banana_peel_time": 10,
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
		"min_trap": 5,
		"max_trap": 15,
		"bomb_radius": 20,
		"bomb_wait_time": 4,
		"banana_peel_friction": 100,
		"banana_peel_time": 20,
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
		"min_trap": 10,
		"max_trap": 30,
		"bomb_radius": 30,
		"bomb_wait_time": 0,
		"banana_peel_friction": 0,
		"banana_peel_time": 15,
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
	BANANA_PEEL
}

enum EFFECTS {
	SPEED_BOOST,
	NOCLIP,
	TRAP,
	BANANA_PEEL
}

const CONSTANT = {
	"chunk_size": 32,
	"block_size": 32,
	"render_distance": 2,
	"max_time": 99
}

var currentGameState = {
	"endTime": 0,
	"difficulty": Difficulty.MEDIUM
}

const TEXT = {
	"timer_text": "TIME LEFT: %.2fs",
	"teleported_text": "TELEPORTED!",
}

var Config = {
	
}
