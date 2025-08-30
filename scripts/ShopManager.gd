extends Node

# Ball purchase
var ball_cost: int = 100
var ball_cost_multiplier: float = 1.5

# Click damage upgrade
var click_damage: int = 1
var click_damage_cost: int = 200
var click_damage_multiplier: float = 2.0

# Ball speed upgrade
var ball_speed_multiplier: float = 1.0
var ball_speed_cost: int = 150
var ball_speed_cost_multiplier: float = 1.8
var ball_speed_increment: float = 0.2  # 20% speed increase per upgrade

# Ball damage upgrade
var ball_damage: int = 1
var ball_damage_cost: int = 300
var ball_damage_cost_multiplier: float = 2.2

func _ready():
	pass

func buy_ball() -> bool:
	if GameManager.spend_currency(ball_cost):
		GameManager.spawn_ball()
		
		# Increase cost for next ball
		ball_cost = int(ball_cost * ball_cost_multiplier)
		
		return true
	return false

func buy_click_upgrade() -> bool:
	if GameManager.spend_currency(click_damage_cost):
		click_damage *= 2  # Double the click damage
		
		# Increase cost for next upgrade (exponentially)
		click_damage_cost = int(click_damage_cost * click_damage_multiplier)
		
		return true
	return false

func buy_ball_speed_upgrade() -> bool:
	if GameManager.spend_currency(ball_speed_cost):
		ball_speed_multiplier += ball_speed_increment  # Increase speed by 20%
		
		# Apply speed upgrade to all existing balls
		apply_speed_upgrade_to_all_balls()
		
		# Increase cost for next upgrade
		ball_speed_cost = int(ball_speed_cost * ball_speed_cost_multiplier)
		
		return true
	return false

func buy_ball_damage_upgrade() -> bool:
	if GameManager.spend_currency(ball_damage_cost):
		ball_damage += 1  # Increase damage by 1
		
		# Increase cost for next upgrade
		ball_damage_cost = int(ball_damage_cost * ball_damage_cost_multiplier)
		
		return true
	return false

func apply_speed_upgrade_to_all_balls():
	# Apply speed upgrade to all existing balls
	for ball in GameManager.balls:
		if is_instance_valid(ball) and ball.has_method("apply_speed_upgrade"):
			ball.apply_speed_upgrade(ball_speed_multiplier)

# Getter functions
func get_ball_cost() -> int:
	return ball_cost

func get_click_damage() -> int:
	return click_damage

func get_click_upgrade_cost() -> int:
	return click_damage_cost

func get_ball_speed_cost() -> int:
	return ball_speed_cost

func get_ball_speed_multiplier() -> float:
	return ball_speed_multiplier

func get_ball_damage_cost() -> int:
	return ball_damage_cost

func get_ball_damage() -> int:
	return ball_damage
