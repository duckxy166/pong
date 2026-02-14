extends Node2D

var player_score: int = 0
var ai_score: int = 0
var is_game_over: bool = false

@onready var ball = $Ball
@onready var player = $Player
@onready var ai = $AI

func _ready():
	ai.ball_ref = ball

	# เชื่อม signal จาก Goal Zones
	$GoalLeft.body_entered.connect(_on_goal_left)
	$GoalRight.body_entered.connect(_on_goal_right)

	# เชื่อม signal จาก Ball
	ball.hit_paddle.connect(_on_ball_hit)

	update_ui()

func _on_goal_left(_body):
	# ลูกหลุดซ้าย → AI ได้แต้ม
	ai_score += 1
	update_ui()
	check_game_over()
	if not is_game_over:
		ball.reset(Vector2(640, 360))

func _on_goal_right(_body):
	# ลูกหลุดขวา → ผู้เล่นได้แต้ม
	player_score += 1
	update_ui()
	check_game_over()
	if not is_game_over:
		ball.reset(Vector2(640, 360))

func _on_ball_hit():
	# ลูกโดนแร็คเก็ต (ไว้ใช้ทีหลังตอนเพิ่มระบบหด)
	pass

func check_game_over():
	# เล่นถึง 5 แต้มก่อนชนะ
	if player_score >= 5 or ai_score >= 5:
		is_game_over = true
		ball.speed = 0
		if player_score >= 5:
			$UI/GameOverLabel.text = "YOU WIN!"
		else:
			$UI/GameOverLabel.text = "YOU LOSE!"
		$UI/GameOverLabel.visible = true
		$UI/RestartLabel.visible = true

func update_ui():
	$UI/ScoreLabel.text = str(player_score) + "  -  " + str(ai_score)

func _input(event):
	if is_game_over and event.is_action_pressed("ui_accept"):
		restart_game()

func restart_game():
	player_score = 0
	ai_score = 0
	is_game_over = false
	$UI/GameOverLabel.visible = false
	$UI/RestartLabel.visible = false
	ball.reset(Vector2(640, 360))
	update_ui()
