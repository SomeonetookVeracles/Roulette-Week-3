extends RigidBody2D

@export var base_initial_speed: float = 300.0
@export var base_max_speed: float = 600.0
@export var speed_increase: float = 1.001  # Very gradual speed increase
@export var bounce_randomness: float = 0.3  # Randomness added to bounces

var current_speed_multiplier: float = 1.0
var initial_speed: float
var max_speed: float

var ball_colors: Array[Color] = [
	Color.WHITE,
	Color.CYAN,
	Color.YELLOW,
	Color.MAGENTA,
	Color.LIME,
	Color.ORANGE
]

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	# Apply current shop upgrades to this ball
	current_speed_multiplier = ShopManager.get_ball_speed_multiplier()
	initial_speed = base_initial_speed * current_speed_multiplier
	max_speed = base_max_speed * current_speed_multiplier
	
	# Set physics properties for proper bouncing
	gravity_scale = 0
	lock_rotation = true
	contact_monitor = true
	max_contacts_reported = 10
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY  # Better collision detection
	
	# Set physics material for bouncing
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 1.0  # Perfect bounce
	physics_material.friction = 0.0  # No friction
	physics_material_override = physics_material
	
	# Connect collision signal
	body_entered.connect(_on_body_entered)
	
	# Set random color
	sprite.modulate = ball_colors[randi() % ball_colors.size()]
	
	# Start ball at random position with random movement
	start_at_random_position()

func apply_speed_upgrade(new_multiplier: float):
	# Update speed multiplier and recalculate speeds
	current_speed_multiplier = new_multiplier
	initial_speed = base_initial_speed * current_speed_multiplier
	max_speed = base_max_speed * current_speed_multiplier
	
	# Apply new speed to current velocity if ball is moving
	if linear_velocity.length() > 0:
		var current_direction = linear_velocity.normalized()
		linear_velocity = current_direction * initial_speed

func start_at_random_position():
	# Random position anywhere in the play area
	var viewport_size = get_viewport().get_visible_rect().size
	var spawn_x = randf_range(100, viewport_size.x - 100)
	var spawn_y = randf_range(100, viewport_size.y - 100)
	global_position = Vector2(spawn_x, spawn_y)
	
	# Random direction with full 360 degree coverage
	var angle = randf() * 2 * PI
	linear_velocity = Vector2(cos(angle), sin(angle)) * initial_speed

func _physics_process(delta):
	# Maintain minimum speed to prevent stopping
	if linear_velocity.length() < initial_speed * 0.8:
		linear_velocity = linear_velocity.normalized() * initial_speed
	
	# Clamp max speed
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
	
	# Very gradual speed increase for excitement
	linear_velocity *= speed_increase
	
	# Keep ball in bounds - bounce off ALL edges
	handle_boundaries()

func handle_boundaries():
	var viewport_size = get_viewport().get_visible_rect().size
	var pos = global_position
	var ball_radius = 16  # Assuming 32x32 ball sprite
	
	# Left wall
	if pos.x <= ball_radius:
		linear_velocity.x = abs(linear_velocity.x)
		global_position.x = ball_radius + 1
		add_bounce_randomness()
	
	# Right wall
	if pos.x >= viewport_size.x - ball_radius:
		linear_velocity.x = -abs(linear_velocity.x)
		global_position.x = viewport_size.x - ball_radius - 1
		add_bounce_randomness()
	
	# Top wall
	if pos.y <= ball_radius:
		linear_velocity.y = abs(linear_velocity.y)
		global_position.y = ball_radius + 1
		add_bounce_randomness()
	
	# Bottom wall - BOUNCE instead of game over
	if pos.y >= viewport_size.y - ball_radius:
		linear_velocity.y = -abs(linear_velocity.y)
		global_position.y = viewport_size.y - ball_radius - 1
		add_bounce_randomness()

func add_bounce_randomness():
	# Add slight randomness to prevent infinite loops
	var random_angle = randf_range(-bounce_randomness, bounce_randomness)
	linear_velocity = linear_velocity.rotated(random_angle)

func _on_body_entered(body):
	if body.has_method("hit_with_damage"):
		# Use new damage system
		body.hit_with_damage(ShopManager.get_ball_damage())
	elif body.has_method("hit"):
		# Fallback to old system
		body.hit()
	
	# Ensure ball maintains good velocity after block collision
	var current_speed = linear_velocity.length()
	if current_speed < initial_speed:
		linear_velocity = linear_velocity.normalized() * initial_speed
	
	# Add randomness to prevent getting stuck
	add_bounce_randomness()
