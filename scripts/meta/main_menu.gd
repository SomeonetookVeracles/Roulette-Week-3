# MainMenu.gd
extends Control

func _ready():
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/OptionsButton.pressed.connect(_on_options_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	# Replace with your main game scene path
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_options_pressed():
	print("Options menu not implemented yet.")
	# Optionally load an Options scene or open a popup

func _on_quit_pressed():
	get_tree().quit()
