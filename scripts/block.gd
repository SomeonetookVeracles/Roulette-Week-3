extends StaticBody2D

@export var max_health: int = 1
@export var base_points: int = 10

var current_health: int
var points: int

# Collision flag for shader effects
var just_hit: bool = false
var hit_timer: float = 0.0
var hit_flash_duration: float = 0.2

# Shader material for trippy effects
var shader_material: ShaderMaterial

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $HealthLabel
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	current_health = max_health
	points = base_points * max_health  # More health = more points
	
	# Setup shader material
	setup_shader()
	
	update_appearance()
	
	# Enable input events for clicking
	input_event.connect(_on_input_event)

func setup_shader():
	# Create shader material if it doesn't exist
	if not sprite.material or not sprite.material is ShaderMaterial:
		shader_material = ShaderMaterial.new()
		# You'll need to load your shader resource here
		# shader_material.shader = preload("res://shaders/pulse_distortion.gdshader")
		sprite.material = shader_material
	else:
		shader_material = sprite.material as ShaderMaterial
	
	# Set initial shader parameters
	update_shader_params()

func _process(delta):
	# Handle hit flash timer for shader
	if just_hit:
		hit_timer += delta
		if hit_timer >= hit_flash_duration:
			just_hit = false
			hit_timer = 0.0
		update_shader_params()

func _on_input_event(viewport, event, shape_idx):
	# Handle mouse clicks on the block
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			click_damage()

func click_damage():
	# Deal click damage based on shop upgrades
	var damage = ShopManager.get_click_damage()
	current_health -= damage
	
	# Give $1 for hitting the block (whether destroyed or not)
	GameManager.block_hit()
	
	# Set collision flag for shader
	just_hit = true
	hit_timer = 0.0
	update_shader_params()
	
	update_appearance()
	
	# Visual click effect
	click_effect()
	
	if current_health <= 0:
		destroy_block()
	else:
		# Add bonus points for manual clicking
		GameManager.add_score(damage * 2)  # Double points for clicking

# Original hit function (for backward compatibility)
func hit():
	hit_with_damage(1)

# New hit function that accepts damage amount
func hit_with_damage(damage: int):
	current_health -= damage
	
	# Give $1 for hitting the block (whether destroyed or not)
	GameManager.block_hit()
	
	# Set collision flag for shader
	just_hit = true
	hit_timer = 0.0
	update_shader_params()
	
	update_appearance()
	
	# Ball hit effect
	flash_effect()
	
	if current_health <= 0:
		destroy_block()

func update_shader_params():
	# Update shader with collision flag and intensity
	if shader_material and shader_material.shader:
		shader_material.set_shader_parameter("just_hit", just_hit)
		
		var intensity = 0.0
		if just_hit and hit_flash_duration > 0.0:
			intensity = 1.0 - (hit_timer / hit_flash_duration)
		
		shader_material.set_shader_parameter("hit_intensity", intensity)
		
		# Set trippy effect parameters
		shader_material.set_shader_parameter("pulse_speed", 4.0)
		shader_material.set_shader_parameter("distortion_strength", 0.2)
		shader_material.set_shader_parameter("wave_frequency", 12.0)
		shader_material.set_shader_parameter("pulse_color", Color.MAGENTA)
		shader_material.set_shader_parameter("chromatic_strength", 0.05)

func click_effect():
	# Special effect for mouse clicks
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.parallel().tween_property(sprite, "modulate", Color.YELLOW, 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	tween.parallel().tween_property(sprite, "modulate", get_health_color(), 0.1)

func flash_effect():
	# Ball collision effect - more intense for higher damage
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.05)
	tween.tween_property(sprite, "modulate", get_health_color(), 0.05)

func destroy_block():
	# Destruction effect
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.parallel().tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
	
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
	# Color gradient based on health
	if max_health == 1:
		return Color.LIGHT_BLUE
	
	var health_ratio = float(current_health) / float(max_health)
	if health_ratio > 0.8:
		return Color.RED
	elif health_ratio > 0.6:
		return Color.ORANGE_RED
	elif health_ratio > 0.4:
		return Color.ORANGE
	elif health_ratio > 0.2:
		return Color.YELLOW
	else:
		return Color.LIGHT_GREEN

func set_health(health: int):
	max_health = health
	current_health = health
	points = base_points * max_health
	update_appearance()

# Getter functions for shader access
func is_just_hit() -> bool:
	return just_hit

func get_hit_intensity() -> float:
	if not just_hit:
		return 0.0
	return 1.0 - (hit_timer / hit_flash_duration)
