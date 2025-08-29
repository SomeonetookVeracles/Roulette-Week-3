extends StaticBody2D

@export var max_health: int = 1
@export var base_points: int = 10

var current_health: int
var points: int

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $HealthLabel
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	current_health = max_health
	points = base_points * max_health  # More health = more points
	update_appearance()

func hit():
	current_health -= 1
	update_appearance()
	
	# Screen shake effect (simple)
	var tween = create_tween()
	var original_pos = global_position
	tween.tween_method(shake_position, 0.0, 1.0, 0.2)
	
	if current_health <= 0:
		destroy_block()
	else:
		# Hit effect - flash white
		flash_effect()

func shake_position(progress: float):
	var shake_strength = 5.0 * (1.0 - progress)
	global_position = Vector2(
		global_position.x + randf_range(-shake_strength, shake_strength),
		global_position.y + randf_range(-shake_strength, shake_strength)
	)

func flash_effect():
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.05)
	tween.tween_property(sprite, "modulate", get_health_color(), 0.05)

func destroy_block():
	# Destruction effect
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 0.3)
	
	# Disable collision immediately
	collision.set_deferred("disabled", true)
	
	GameManager.add_score(points)
	GameManager.block_destroyed()
	
	await tween.finished
	queue_free()

func update_appearance():
	# Update health label
	if label:
		label.text = str(current_health) if current_health > 1 else ""
	
	# Change color based on health
	if sprite:
		sprite.modulate = get_health_color()

func get_health_color() -> Color:
	# Color gradient from green (1 health) to red (high health)
	if max_health == 1:
		return Color.CYAN
	
	var health_ratio = float(current_health) / float(max_health)
	if health_ratio > 0.66:
		return Color.RED
	elif health_ratio > 0.33:
		return Color.ORANGE
	else:
		return Color.YELLOW

func set_health(health: int):
	max_health = health
	current_health = health
	points = base_points * max_health
	update_appearance()
