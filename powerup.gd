extends Area2D

signal collected

var move_speed: float = 120.0
var direction: Vector2

func _ready():
	# สุ่มทิศทางลอยข้ามจอ
	var angle = randf_range(-0.3, 0.3)
	if randi() % 2 == 0:
		direction = Vector2(1, angle).normalized()
		position.x = -30
	else:
		direction = Vector2(-1, angle).normalized()
		position.x = 1310
	position.y = randf_range(100, 620)

func _process(delta):
	position += direction * move_speed * delta
	if position.x < -60 or position.x > 1340:
		queue_free()

func collect():
	collected.emit()
	queue_free()
