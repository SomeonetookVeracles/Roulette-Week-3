extends RigidBody2D

@export var initial_speed: float = 300.0
@export var max_speed: float = 600.0
@export var speed_increase: float = 1.02  # Slight speed increase over time

var start_position: Vector2

func _ready():
	start_position = global_position
	# Set physics properties
	gravity_scale = 0
	lock_rotation = true
	contact_monitor = true
	max_contacts_reported = 10
	
	# Connect collision signal
	body_entered.connect(_on_body_entered)
	
	# Start ball movement
	reset_ball()

func reset_ball():
	global_position = start_position
	# Random angle between -45 and -135 degrees (upward)
	var angle = deg_to_rad(randf_range(-135, -45))
	linear_velocity = Vector2(cos(angle), sin(angle)) * initial_speed

func _physics_process(delta):
	# Clamp speed to prevent infinite acceleration
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
	
	# Gradually increase speed for excitement
	if linear_velocity.length() > 0:
		linear_velocity *= speed_increase
	
	# Keep ball in bounds (bounce off edges)
	handle_boundaries()

func handle_boundaries():
	var viewport_size = get_viewport().get_visible_rect().size
	var pos = global_position
	var ball_radius = 16  # Assuming 32x32 ball sprite
	
	# Left and right walls
	if pos.x < ball_radius:
		linear_velocity.x = abs(linear_velocity.x)
		global_position.x = ball_radius
	elif pos.x > viewport_size.x - ball_radius:
		linear_velocity.x = -abs(linear_velocity.x)
		global_position.x = viewport_size.x - ball_radius
	
	# Top wall
	if pos.y < ball_radius:
		linear_velocity.y = abs(linear_velocity.y)
		global_position.y = ball_radius
	
	# Bottom wall - Game Over
	if pos.y > viewport_size.y + 50:
		GameManager.game_over()

func _on_body_entered(body):
	if body.has_method("hit"):
		body.hit()
		# Add slight random angle to prevent infinite loops
		var random_factor = randf_range(-0.1, 0.1)
		linear_velocity = linear_velocity.rotated(random_factor)
