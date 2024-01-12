extends TileMap

signal clock_handler
signal randomized_clock_handler
signal speed_boost_handler
signal noclip_handler
signal teleporter_handler
signal trap_handler
signal bomb_handler
signal banana_peel_handler
signal darkness_handler

var rng = RandomNumberGenerator.new()
var ITEM_METADATA = {
	Vector2i(0, 1): {
		"type": Global.ITEMS.CLOCK,
		"effect_function": "clock_handler",
		"chance": 0.012,
		"score": 100,
	},
	Vector2i(1, 1): {
		"type": Global.ITEMS.RANDOMIZED_CLOCK,
		"effect_function": "randomized_clock_handler",
		"chance": 0.0025,
		"score": 250,
	},
	Vector2i(2, 1): {
		"type": Global.ITEMS.SPEED_BOOST,
		"effect_function": "speed_boost_handler",
		"chance": 0.0004,
		"score": 150,
	},
	Vector2i(3, 1): {
		"type": Global.ITEMS.NOCLIP,
		"effect_function": "noclip_handler",
		"chance": 0.0004,
		"score": 150,
	},
	Vector2i(4, 1): {
		"type": Global.ITEMS.TELEPORTER,
		"effect_function": "teleporter_handler",
		"chance": 0.0004,
		"score": 200,
	},
	Vector2i(5, 1): {
		"type": Global.ITEMS.TRAP,
		"effect_function": "trap_handler",
		"chance": 0.0008,
		"score": 0,
	},
	Vector2i(6, 1): {
		"type": Global.ITEMS.BOMB,
		"effect_function": "bomb_handler",
		"chance": 0.00008
	},
	Vector2i(7, 1): {
		"type": Global.ITEMS.BANANA_PEEL,
		"effect_function": "banana_peel_handler",
		"chance": 0.0005,
		"score": 100,
	},
	Vector2i(0, 2): {
		"type": Global.ITEMS.DARKNESS,
		"effect_function": "darkness_handler",
		"chance": 0.00054,
		"score": 150,
	}
}

# item (second row of texture):
# 0: clock
# 1: randomized clock
# 2: speed boost
# 3: noclip
# 4: teleporter
# 5: trap
# 6: bomb
# 7: Banana peel
func place_item(chunkCoord = Vector2i(0, 0)):
	var startPos = chunkCoord * Global.CONSTANT.chunk_size
	var width = Global.CONSTANT.chunk_size
	var height = Global.CONSTANT.chunk_size
	var board = self

	for i in range(startPos.x, startPos.x + width):
		for j in range(startPos.y, startPos.y + height):
			if i == 0 and j ==0:
				continue
			if Global.BOARD_TILEMAP\
				.get_cell_atlas_coords(0, Vector2i(i, j)) != Global.BOARD_BLOCK.PATH:
				continue
			var dice = rng.randf_range(0, 1)
			var totalChance = 0
			var chance = 0
			for item in ITEM_METADATA.keys():
				chance = ITEM_METADATA[item].chance
				if dice <= chance + totalChance:
					board.set_cell(0, Vector2i(i, j), 0, item)
					break
				else:
					totalChance += chance

func apply_item(location):
	Global.PARTICLES.position = (location * Global.CONSTANT.block_size)\
		+ Global.CONSTANT.block_size * Vector2i(1, 1) / 2
	Global.PARTICLES.emitting = true

	var itemAtlasCoords = get_cell_atlas_coords(0, location)
	var item = ITEM_METADATA.get(itemAtlasCoords)
	set_cell(0, location, 0, Vector2i(-1, -1))
	if item == null:
		return

	Global.currentGameState.score += item.score
	emit_signal(item.effect_function)

	Global.SOUND_EFFECT_HANDLER.stream = preload(Global.SOUND_EFFECT.pickup)
	Global.SOUND_EFFECT_HANDLER.play()
