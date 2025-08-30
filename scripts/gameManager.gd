extends Node
signal score_changed(new_score)
signal level_changed(new_level)
signal currency_changed(new_currency)
var score: int = 0
var currency: int = 0  # Money to buy more balls
var level: int = 1
var blocks_remaining: int = 0
var ball_scene = preload("res://scenes/Ball.tscn")
var block_scene = preload("res://scenes/Block.tscn")
var blocks_container: Node2D
var balls_container: Node2D
var ui: CanvasLayer
var balls: Array[RigidBody2D] = []

func _ready():
	# Wait for scene to be ready
	await get_tree().process_frame
	setup_references()
	start_new_game()

func setup_references():
	var main_scene = get_tree().current_scene
	blocks_container = main_scene.get_node("Blocks")
	balls_container = main_scene.get_node("Balls")
	ui = main_scene.get_node("UI")

func start_new_game():
	score = 0
	currency = 50  # Starting currency
	level = 1
	emit_signal("score_changed", score)
	emit_signal("currency_changed", currency)
	
	# Clear existing balls
	clear_balls()
	
	# Spawn initial ball
	spawn_ball()
	generate_level()

func clear_balls():
	for ball in balls:
		if is_instance_valid(ball):
			ball.queue_free()
	balls.clear()

func spawn_ball():
	var ball = ball_scene.instantiate()
	balls_container.add_child(ball)
	balls.append(ball)
	
	# Ball will set its own random position in its _ready() function
	# No need to set position here anymore

func generate_level():
	# Clear existing blocks
	if blocks_container:
		for child in blocks_container.get_children():
			child.queue_free()
	
	# Wait a frame for cleanup
	await get_tree().process_frame
	
	blocks_remaining = 0
	var rows = 5 + (level - 1) * 2  # More rows each level
	var cols = 10
	var block_width = 80
	var block_height = 30
	var padding = 5
	
	var viewport_size = get_viewport().get_visible_rect().size
	var start_x = (viewport_size.x - (cols * (block_width + padding) - padding)) / 2
	var start_y = 250  # Start blocks lower to leave room for balls
	
	for row in range(rows):
		for col in range(cols):
			var block = block_scene.instantiate()
			blocks_container.add_child(block)
			
			# Position block
			var pos = Vector2(
				start_x + col * (block_width + padding),
				start_y + row * (block_height + padding)
			)
			block.global_position = pos
			
			# Set block health based on level and row
			var health = level + row
			block.set_health(health)
			
			blocks_remaining += 1
	
	emit_signal("level_changed", level)

func add_score(points: int):
	score += points
	emit_signal("score_changed", score)

# NEW: Separate function for when blocks are hit (not destroyed)
func block_hit():
	# Give $1 for every block hit
	currency += 1
	emit_signal("currency_changed", currency)

func spend_currency(amount: int) -> bool:
	if currency >= amount:
		currency -= amount
		emit_signal("currency_changed", currency)
		return true
	return false

func block_destroyed():
	blocks_remaining -= 1
	if blocks_remaining <= 0:
		next_level()

func next_level():
	level += 1
	# Apply 1.5x multiplier to current currency when completing level
	currency = int(currency * 1.5)
	emit_signal("currency_changed", currency)
	
	await get_tree().create_timer(1.5).timeout
	generate_level()

func get_ball_count() -> int:
	return balls.size()
