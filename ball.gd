extends CharacterBody2D

signal hit_paddle

var speed: float = 400.0
var direction: Vector2 = Vector2.ZERO

func _ready():
	start_moving()

func start_moving():
	var angle = randf_range(-PI / 4, PI / 4)
	if randi() % 2 == 0:
		angle += PI
	direction = Vector2.from_angle(angle).normalized()

func _physics_process(delta):
	velocity = direction * speed
	var collision = move_and_collide(velocity * delta)

	if collision:
		var collider = collision.get_collider()
		direction = direction.bounce(collision.get_normal())

		# ถ้าชนแร็คเก็ต → ส่งสัญญาณ
		if collider.is_in_group("paddle"):
			hit_paddle.emit()

func reset(pos: Vector2):
	position = pos
	speed = 400.0
	start_moving()
