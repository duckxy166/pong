extends CharacterBody2D

@export var move_speed: float = 500.0
@export var is_player: bool = true

var ball_ref: Node2D = null

func _physics_process(delta):
	var input_dir = 0.0

	if is_player:
		if Input.is_action_pressed("ui_up"):
			input_dir = -1.0
		if Input.is_action_pressed("ui_down"):
			input_dir = 1.0
	else:
		if ball_ref:
			var diff = ball_ref.position.y - position.y
			if abs(diff) > 10:
				input_dir = sign(diff)

	velocity = Vector2(0, input_dir * move_speed)
	move_and_slide()

	position.y = clamp(position.y, 70, 650)
