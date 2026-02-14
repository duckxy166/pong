extends Node2D

var player_score: int = 0
var ai_score: int = 0
var is_game_over: bool = false

# Shrink & Combo
var combo_count: int = 0
const COMBO_THRESHOLD: int = 5
const SHRINK_AMOUNT: float = 0.07
const COMBO_GROW: float = 0.15
const MIN_SCALE_Y: float = 0.2

# Power-up
var powerup_scene = preload("res://powerup.tscn")
var powerup_spawn_timer: float = 0.0
const POWERUP_INTERVAL: float = 15.0
const POWERUP_DURATION: float = 5.0
var powerup_active: bool = false
var powerup_timer: float = 0.0

# High score
var session_hits: int = 0
var high_score: int = 0
const SAVE_PATH: String = "user://highscore.save"

@onready var ball = $Ball
@onready var player = $Player
@onready var ai = $AI

func _ready():
	ai.ball_ref = ball

	$GoalLeft.body_entered.connect(_on_goal_left)
	$GoalRight.body_entered.connect(_on_goal_right)
	ball.hit_paddle.connect(_on_ball_hit)

	load_high_score()
	update_ui()

func _process(delta):
	if is_game_over:
		return

	# Power-up spawn timer
	powerup_spawn_timer += delta
	if powerup_spawn_timer >= POWERUP_INTERVAL:
		powerup_spawn_timer = 0.0
		spawn_powerup()

	# Power-up duration countdown
	if powerup_active:
		powerup_timer -= delta
		if powerup_timer <= 0:
			deactivate_powerup()

func _on_goal_left(body):
	if body == ball:
		ai_score += 1
		reset_combo()
		update_ui()
		check_game_over()
		if not is_game_over:
			ball.reset(Vector2(640, 360))

func _on_goal_right(body):
	if body == ball:
		player_score += 1
		reset_combo()
		update_ui()
		check_game_over()
		if not is_game_over:
			ball.reset(Vector2(640, 360))

func _on_ball_hit():
	session_hits += 1
	combo_count += 1

	# แร็คเก็ตหดทุกครั้งที่ตี
	if not powerup_active:
		player.scale.y = max(player.scale.y - SHRINK_AMOUNT, MIN_SCALE_Y)

	# Combo reward: ตี 5 ครั้งติด → ขยายกลับนิดนึง
	if combo_count >= COMBO_THRESHOLD:
		combo_count = 0
		if not powerup_active:
			player.scale.y = min(player.scale.y + COMBO_GROW, 1.0)
		$UI/ComboLabel.text = "COMBO REWARD!"
		await get_tree().create_timer(1.0).timeout
		$UI/ComboLabel.text = ""

	update_ui()

func reset_combo():
	combo_count = 0

func spawn_powerup():
	var pu = powerup_scene.instantiate()
	add_child(pu)
	pu.collected.connect(_on_powerup_collected)

func _on_powerup_collected():
	powerup_active = true
	powerup_timer = POWERUP_DURATION
	player.scale.y = 1.0

func deactivate_powerup():
	powerup_active = false
	powerup_timer = 0.0

func check_game_over():
	if player_score >= 5 or ai_score >= 5:
		is_game_over = true
		ball.speed = 0
		check_and_save_high_score()
		if player_score >= 5:
			$UI/GameOverLabel.text = "YOU WIN!"
		else:
			$UI/GameOverLabel.text = "YOU LOSE!"
		$UI/GameOverLabel.visible = true
		$UI/RestartLabel.visible = true

func update_ui():
	$UI/ScoreLabel.text = str(player_score) + "  -  " + str(ai_score)
	$UI/HitsLabel.text = "Hits: " + str(session_hits)
	$UI/HighScoreLabel.text = "Best: " + str(high_score)

func _input(event):
	if is_game_over and event.is_action_pressed("ui_accept"):
		restart_game()

func restart_game():
	player_score = 0
	ai_score = 0
	is_game_over = false
	session_hits = 0
	combo_count = 0
	powerup_active = false
	powerup_timer = 0.0
	powerup_spawn_timer = 0.0
	player.scale.y = 1.0
	# ลบ power-up ที่ลอยอยู่
	for node in get_children():
		if node.is_in_group("powerup"):
			node.queue_free()
	$UI/GameOverLabel.visible = false
	$UI/RestartLabel.visible = false
	$UI/ComboLabel.text = ""
	$UI/NewHighScoreLabel.visible = false
	ball.reset(Vector2(640, 360))
	update_ui()

# --- High Score ---

func load_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			high_score = file.get_32()

func save_high_score():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(high_score)

func check_and_save_high_score():
	if session_hits > high_score:
		high_score = session_hits
		save_high_score()
		$UI/NewHighScoreLabel.visible = true
