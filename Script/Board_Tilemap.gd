extends TileMap
signal finished_generating_chunk(chunkCoord: Vector2)
@export var PLAYER: CharacterBody2D
@export var ITEM_TILEMAP: TileMap

var rng = RandomNumberGenerator.new()
var generatedChunk = []

func arrayDifference(arr1, arr2):
	var only_in_arr1 = []
	for v in arr1:
		if not (v in arr2):
			only_in_arr1.append(v)
	return only_in_arr1

func generateMaze(chunkCoord = Vector2(0, 0)):
	#rng.seed = 1252
	rng.randomize()
	var width = Global.CONSTANT.chunk_size
	var height = Global.CONSTANT.chunk_size
	var startPos = chunkCoord * Global.CONSTANT.chunk_size
	var currentCell = startPos

	var board = self
	var visitedList = {}
	var stack = []
	var neighbors = [
		Vector2(2, 0),
		Vector2(-2, 0),
		Vector2(0, 2),
		Vector2(0, -2),
	]

	for i in range(startPos.x, startPos.x + width):
		for j in range(startPos.y, startPos.y + height):
			var type = null
			if i % 2 == 0 and j % 2 == 0:
				type = Global.BOARD_BLOCK.PATH
			else:
				type = Global.BOARD_BLOCK.WALL
			board.set_cell(0, Vector2(i, j), 0, type)
			visitedList[Vector2(i, j)] = false

	visitedList[currentCell] = true
	stack.append(currentCell)

	while len(stack) > 0:
		currentCell = stack.pop_back()
		var possibleNeighbor = []
		for i in neighbors:
			var neighborCell = currentCell + i
			var visited = visitedList.get(neighborCell, true)
			if visited:
				continue
			possibleNeighbor.append(neighborCell)

		if len(possibleNeighbor) > 0:
			stack.append(currentCell)
			var neighbor = possibleNeighbor[rng.randi_range(0, len(possibleNeighbor) - 1)]
			var wallToDelete = (currentCell + neighbor) / 2

			board.set_cell(0, wallToDelete, 0, Global.BOARD_BLOCK.PATH)
			visitedList[neighbor] = true
			stack.append(neighbor)

	var alreadyBlend = false
	# chunk blending
	var edgeCases = [
		{ # left
			"offset": Vector2(-1, 0),
			"orientation": "y",
		},
		{ # right
			"offset": Vector2(Global.CONSTANT.chunk_size - 1, 0),
			"orientation": "y",
		},
		{ # top
			"offset": Vector2(0, -1),
			"orientation": "x",
		},
		{ # bottom
			"offset": Vector2(0, Global.CONSTANT.chunk_size - 1),
			"orientation": "x",
		},
	]

	for e in edgeCases:
		currentCell = startPos + e.offset
		for i in range(0, Global.CONSTANT.chunk_size):
			var leftCellPos
			var rightCellPos
			match e.orientation:
				"y":
					leftCellPos = Vector2(-1, i)
					rightCellPos = Vector2(1, i)
				"x":
					leftCellPos = Vector2(i, -1)
					rightCellPos = Vector2(i, 1)
			var leftCell = board.get_cell_atlas_coords(0,
				currentCell + leftCellPos)
			var rightCell = board.get_cell_atlas_coords(0,
				currentCell + rightCellPos)

			if leftCell == Vector2i(-1, -1) or rightCell == Vector2i(-1, -1):
				continue
			if leftCell == Global.BOARD_BLOCK.PATH and rightCell == Global.BOARD_BLOCK.PATH:
				if alreadyBlend:
					continue
				alreadyBlend = true
				board.set_cell(0,
					currentCell + (leftCellPos + rightCellPos) / 2, 0,
					Global.BOARD_BLOCK.PATH)
			else:
				alreadyBlend = false

	emit_signal("finished_generating_chunk", chunkCoord)

func removeMaze(chunkCoord):
	var startPos = chunkCoord * Global.CONSTANT.chunk_size
	var width = Global.CONSTANT.chunk_size
	var height = Global.CONSTANT.chunk_size
	var board = self

	for i in range(startPos.x, startPos.x + width):
		for j in range(startPos.y, startPos.y + height):
			board.set_cell(0, Vector2(i, j), 0, Vector2i(-1, -1))
			ITEM_TILEMAP.set_cell(0, Vector2(i, j), 0, Vector2i(-1, -1))

func generateChunkMaze(origin: Vector2):
	var newChunk = []
	var a = origin.x - Global.CONSTANT.render_distance - 1
	var b = origin.x + Global.CONSTANT.render_distance + 1
	var c = origin.y - Global.CONSTANT.render_distance - 1
	var d = origin.y + Global.CONSTANT.render_distance + 1
	for x in range(a, b):
		for y in range(c, d):
			newChunk.append(Vector2(x, y))

	var addedChunk = arrayDifference(newChunk, generatedChunk)
	var removedChunk = arrayDifference(generatedChunk, newChunk)

	for i in addedChunk:
		generateMaze(i)
		generatedChunk.append(i)
	for i in removedChunk:
		removeMaze(i)
		generatedChunk.erase(i)

func _ready():
	generateChunkMaze(Vector2(0, 0))
	pass

func _process(_delta):
	generateChunkMaze(
		floor(PLAYER.position / Global.CONSTANT.block_size / Global.CONSTANT.chunk_size)
	)
