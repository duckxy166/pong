extends CharacterBody2D

signal hit_paddle

var speed: float = 400.0
var direction: Vector2 = Vector2.ZERO
var time_elapsed: float = 0.0
const SPEED_INTERVAL: float = 10.0
const SPEED_INCREMENT: float = 50.0

func _ready():
	start_moving()

func start_moving():
	var angle = randf_range(-PI / 4, PI / 4)
	if randi() % 2 == 0:
		angle += PI
	direction = Vector2.from_angle(angle).normalized()

func _physics_process(delta):
	# เพิ่มความเร็วทุก 10 วิ
	time_elapsed += delta
	if time_elapsed >= SPEED_INTERVAL:
		speed += SPEED_INCREMENT
		time_elapsed = 0.0

	velocity = direction * speed
	var collision = move_and_collide(velocity * delta)

	if collision:
		var collider = collision.get_collider()
		direction = direction.bounce(collision.get_normal())

		if collider.is_in_group("paddle"):
			hit_paddle.emit()
		elif collider.is_in_group("powerup"):
			collider.collect()

func reset(pos: Vector2):
	position = pos
	speed = 400.0
	time_elapsed = 0.0
	start_moving()
