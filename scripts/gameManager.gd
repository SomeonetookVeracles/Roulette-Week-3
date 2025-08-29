extends Node

signal score_changed(new_score)
signal level_changed(new_level)
signal game_over_signal

var score: int = 0
var level: int = 1
var blocks_remaining: int = 0
var ball_scene = preload("res://scenes/Ball.tscn")
var block_scene = preload("res://scenes/Block.tscn")

var blocks_container: Node2D
var ui: CanvasLayer

func _ready():
	# Wait for scene to be ready
	await get_tree().process_frame
	setup_references()
	start_new_game()

func setup_references():
	var main_scene = get_tree().current_scene
	blocks_container = main_scene.get_node("Blocks")
	ui = main_scene.get_node("UI")

func start_new_game():
	score = 0
	level = 1
	emit_signal("score_changed", score)
	generate_level()

func generate_level():
	# Clear existing blocks
	if blocks_container:
		for child in blocks_container.get_children():
			child.queue_free()
	
	# Wait a frame for cleanup
	await get_tree().process_frame
	
	blocks_remaining = 0
	var rows = 4 + level  # More rows each level
	var cols = 8
	var block_width = 80
	var block_height = 40
	var padding = 10
	
	var viewport_size = get_viewport().get_visible_rect().size
	var start_x = (viewport_size.x - (cols * (block_width + padding) - padding)) / 2
	var start_y = 80
	
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
			var health = level + (row / 2)  # Gradual health increase
			if health < 1:
				health = 1
			block.set_health(int(health))
			
			blocks_remaining += 1
	
	emit_signal("level_changed", level)

func add_score(points: int):
	score += points
	emit_signal("score_changed", score)

func block_destroyed():
	blocks_remaining -= 1
	if blocks_remaining <= 0:
		next_level()

func next_level():
	level += 1
	await get_tree().create_timer(1.5).timeout
	generate_level()

func game_over():
	emit_signal("game_over_signal")
	# Restart game after delay
	await get_tree().create_timer(3.0).timeout
	start_new_game()
