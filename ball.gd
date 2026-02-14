extends CharacterBody2D


var SPEED = 400.0
var direction: Vector2 = Vector2.ZERO

func _ready():
	start_moving()
	
func start_moving():
	#RandomStart corner
	var angle = randf_range(-PI / 4, PI / 4)

#Random to left/right
	if randi() % 2 == 0:
		angle += PI
	
	direction = Vector2.from_angle(angle).normalized()
	
func _physics_process(delta):
	#move
	velocity = direction * SPEED
	var collision = move_and_collide(velocity * delta)
	
	#if hit -> bounce
	if collision:
		direction = direction.bounce(collision.get_normal())
