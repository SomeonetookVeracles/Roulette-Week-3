extends CanvasLayer

@onready var score_label: Label = $HUD/ScoreLabel  # Adjust path to your actual label
@onready var currency_label: Label = $HUD/CurrencyLabel  # Adjust path to your actual label
@onready var level_label: Label = $HUD/LevelLabel  # Adjust path to your actual label

# Shop UI elements (adjust paths as needed)
@onready var buy_ball_button: Button = $ShopPanel/VBoxContainer/BallBuyButton
@onready var buy_click_button: Button = $ShopPanel/VBoxContainer/BuyClickButton
@onready var buy_speed_button: Button = $ShopPanel/VBoxContainer/BuySpeedButton
@onready var buy_damage_button: Button = $ShopPanel/VBoxContainer/BuyDamageButton2

@onready var ball_cost_label: Label = $ShopPanel/VBoxContainer/BallCostLabel
@onready var click_cost_label: Label = $ShopPanel/VBoxContainer/ClickCostLabel
@onready var speed_cost_label: Label = $ShopPanel/VBoxContainer/SpeedCostLabel
@onready var damage_cost_label: Label = $ShopPanel/VBoxContainer/DamageCostLabel



func _ready():
	# Connect GameManager signals
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.currency_changed.connect(_on_currency_changed)
	GameManager.level_changed.connect(_on_level_changed)
	
	# Connect shop button signals
	if buy_ball_button:
		buy_ball_button.pressed.connect(_on_buy_ball_pressed)
	if buy_click_button:
		buy_click_button.pressed.connect(_on_buy_click_pressed)
	if buy_speed_button:
		buy_speed_button.pressed.connect(_on_buy_speed_pressed)
	if buy_damage_button:
		buy_damage_button.pressed.connect(_on_buy_damage_pressed)
	
	# Update shop costs initially
	update_shop_ui()

func _on_score_changed(new_score: int):
	if score_label:
		score_label.text = "Score: " + str(new_score)

func _on_currency_changed(new_currency: int):
	if currency_label:
		currency_label.text = "Money: $" + str(new_currency)
	
	# Update shop button availability
	update_shop_ui()

func _on_level_changed(new_level: int):
	if level_label:
		level_label.text = "Level: " + str(new_level)

func _on_buy_ball_pressed():
	if ShopManager.buy_ball():
		update_shop_ui()

func _on_buy_click_pressed():
	if ShopManager.buy_click_upgrade():
		update_shop_ui()

func _on_buy_speed_pressed():
	if ShopManager.buy_ball_speed_upgrade():
		update_shop_ui()

func _on_buy_damage_pressed():
	if ShopManager.buy_ball_damage_upgrade():
		update_shop_ui()

func update_shop_ui():
	var current_currency = GameManager.currency
	
	# Update cost labels with current prices
	if ball_cost_label:
		ball_cost_label.text = "Buy Ball " + str(ShopManager.get_ball_cost())
	if click_cost_label:
		click_cost_label.text = "Upgrade Click " + str(ShopManager.get_click_upgrade_cost())
	if speed_cost_label:
		speed_cost_label.text = "Speed Upgrade: " + str(ShopManager.get_ball_speed_cost())
	if damage_cost_label:
		damage_cost_label.text = "DMG Upgrade: " + str(ShopManager.get_ball_damage_cost())
	
	# Enable/disable buttons based on currency
	if buy_ball_button:
		buy_ball_button.disabled = current_currency < ShopManager.get_ball_cost()
	if buy_click_button:
		buy_click_button.disabled = current_currency < ShopManager.get_click_upgrade_cost()
	if buy_speed_button:
		buy_speed_button.disabled = current_currency < ShopManager.get_ball_speed_cost()
	if buy_damage_button:
		buy_damage_button.disabled = current_currency < ShopManager.get_ball_damage_cost()
