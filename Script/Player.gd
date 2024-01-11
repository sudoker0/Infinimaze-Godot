extends CharacterBody2D

signal apply_item(location: Vector2i)

#var MAX_SPEED = 1500
#var ACCELERATION = 10000
#var FRICTION = 400

var MAX_SPEED = 1000
var ACCELERATION = 5000
var FRICTION = 5000
var FREEZE = false
var CAMERA_ZOOM = Vector2(4, 4)
var MIN_CAMERA_ZOOM = Vector2(0.5, 0.5)
var MAX_CAMERA_ZOOM = Vector2(4, 4)

#var MAX_SPEED = 400
#var ACCELERATION = 1000
#var FRICTION = 600

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
	#print(velocity)
	move_and_slide()

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("scroll_down"):
		$Camera.zoom += CAMERA_ZOOM * -1 * delta
	elif Input.is_action_just_pressed("scroll_up"):
		$Camera.zoom += CAMERA_ZOOM * delta
	$Camera.zoom = clamp($Camera.zoom, MIN_CAMERA_ZOOM, MAX_CAMERA_ZOOM)

func _physics_process(delta):
	var factor = 1
	if Input.is_action_pressed("croutch"):
		factor = Global.CONSTANT.crouching_speed_factor
	if not FREEZE:
		player_movement(delta, factor)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is TileMap and collider.is_in_group("items"):
			var tile_pos = collider.local_to_map(position)
			emit_signal("apply_item", tile_pos - Vector2i(collision.get_normal()))
