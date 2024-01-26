extends CharacterBody2D
signal apply_item(location: Vector2i)

@export var CAMERA: Camera2D
@export var TEXTURE: TextureRect

@onready var rand = RandomNumberGenerator.new()
@onready var noise = FastNoiseLite.new()

var NOISE_SHAKE_SPEED: float = 60.0
var SHAKE_DECAY_RATE: float = 3.0

var MAX_SPEED = 1000
var ACCELERATION = 5000
var FRICTION = 5000
var FREEZE = false

var noise_i: float = 0.0
var shake_strength: float = 0.0

func get_input():
	var input = Vector2.ZERO
	input.x = int(
		Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	input.y = int(
		Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	return input.normalized()

func player_movement(delta, factor = 1):
	var input = get_input()
	if input == Vector2.ZERO:
		if velocity.length() > (FRICTION * delta):
			velocity -= velocity.normalized() * (FRICTION * delta)
		else:
			velocity = Vector2.ZERO
	else:
		velocity += input * ACCELERATION * factor * delta
		velocity = velocity.limit_length(MAX_SPEED * factor)
	move_and_slide()

func get_noise_offset(delta: float) -> Vector2:
	noise_i += delta * NOISE_SHAKE_SPEED
	return Vector2(
		noise.get_noise_2d(1, noise_i) * shake_strength,
		noise.get_noise_2d(20, noise_i) * shake_strength
	)

# https://shaggydev.com/2022/02/23/screen-shake-godot/
func apply_noise_shake(NOISE_SHAKE_STRENGTH = 60.0) -> void:
	shake_strength = NOISE_SHAKE_STRENGTH

func game_over():
	apply_noise_shake()

func _ready():
	var image = Image.new()
	image.load(Global.CONFIG.player_skin_path)
	TEXTURE.texture = ImageTexture.create_from_image(image)
	rand.randomize()
	noise.seed = rand.randi()

func _process(delta):
	shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	CAMERA.offset = get_noise_offset(delta)

func _physics_process(delta):
	if Global.currentGameState.stopped:
		return
	var factor = 1
	if Input.is_action_pressed("croutch"):
		factor = Global.CONSTANT.crouching_speed_factor
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is TileMap and collider.is_in_group("items"):
			var tile_pos = collider.local_to_map(position)
			emit_signal("apply_item", tile_pos - Vector2i(collision.get_normal()))
			apply_noise_shake(30)
	if not FREEZE:
		player_movement(delta, factor)
	else:
		move_and_slide()
