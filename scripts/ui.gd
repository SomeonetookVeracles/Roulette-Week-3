extends CanvasLayer

@onready var score_label: Label = $ScoreLabel
@onready var level_label: Label = $LevelLabel
@onready var game_over_label: Label = $GameOverLabel

func _ready():
	# Connect to GameManager signals
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.level_changed.connect(_on_level_changed)
	GameManager.game_over_signal.connect(_on_game_over)
	
	# Hide game over label initially
	game_over_label.visible = false
	
	# Initial UI setup
	_on_score_changed(0)
	_on_level_changed(1)

func _on_score_changed(new_score: int):
	score_label.text = "Score: " + str(new_score)

func _on_level_changed(new_level: int):
	level_label.text = "Level: " + str(new_level)

func _on_game_over():
	game_over_label.visible = true
	game_over_label.text = "Game Over!\nFinal Score: " + str(GameManager.score) + "\n\nRestarting..."
	
	# Create fade effect
	var tween = create_tween()
	game_over_label.modulate = Color.TRANSPARENT
	tween.tween_property(game_over_label, "modulate", Color.WHITE, 0.5)
	
	# Hide game over message after delay
	await get_tree().create_timer(3.0).timeout
	tween = create_tween()
	tween.tween_property(game_over_label, "modulate", Color.TRANSPARENT, 0.5)
	await tween.finished
	game_over_label.visible = false
