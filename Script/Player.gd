extends CharacterBody2D

signal apply_item(location: Vector2i)

#var MAX_SPEED = 1500
#var ACCELERATION = 10000
#var FRICTION = 400

@export var MAX_SPEED = 20000
var ACCELERATION = 10000
var FRICTION = 2000
var LIMIT_LENGTH = 150
var SMALL_ENOUGH = 10
var CAMERA_ZOOM = Vector2(4, 4)
var MIN_CAMERA_ZOOM = Vector2(0.5, 0.5)
var MAX_CAMERA_ZOOM = Vector2(2.5, 2.5)
var FREEZE = false

var middle = Vector2.ZERO
var mousePos = Vector2.ZERO
var joystick = Vector2.ZERO

#var MAX_SPEED = 400
#var ACCELERATION = 1000
#var FRICTION = 600

@onready var axis = Vector2.ZERO

func clamp_vector(vector, _min = 0, _max = 100):
	vector.x = clamp(vector.x, _min, _max)
	vector.y = clamp(vector.y, _min, _max)
	return vector

func _process(delta):
	if Input.is_action_just_pressed("scroll_down"):
		$Camera.zoom += CAMERA_ZOOM * -1 * delta
	elif Input.is_action_just_pressed("scroll_up"):
		$Camera.zoom += CAMERA_ZOOM * delta
	$Camera.zoom = clamp($Camera.zoom, MIN_CAMERA_ZOOM, MAX_CAMERA_ZOOM)

func _physics_process(delta):
	if not FREEZE:
		move(delta)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is TileMap and collider.is_in_group("items"):
			var tile_pos = collider.local_to_map(position)
			emit_signal("apply_item", tile_pos - Vector2i(collision.get_normal()))
			pass

func _draw():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var offset_middle = Vector2.ZERO
		var pos = joystick
		var color = Color(128, 128, 128, 0.4)
		var width = 5.0
		var antialias = true
		draw_line(
			offset_middle,
			pos * (1 / $Camera.zoom.x),
			color, width, antialias)

func get_input_axis():
	var window_info = get_viewport().get_visible_rect().size
	middle = Vector2(window_info.x / 2, window_info.y / 2)
	mousePos = get_viewport().get_mouse_position()

	joystick = mousePos - middle
	queue_redraw()

	return clamp_vector(joystick, -LIMIT_LENGTH, LIMIT_LENGTH) / LIMIT_LENGTH

func move(delta):
	axis = get_input_axis()
	if axis == Vector2.ZERO or (not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		apply_friction(FRICTION * delta)
	else:
		apply_movement(axis * ACCELERATION * delta - velocity.normalized() * FRICTION * delta)

	move_and_slide()

func apply_friction(amount):
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO

func apply_movement(accel):
	velocity += accel
	velocity = velocity.limit_length(MAX_SPEED)
	if velocity.length() < SMALL_ENOUGH:
		velocity = Vector2.ZERO
