extends Control


func _ready():
	$MenuBox/PlayButton.pressed.connect(_on_play_pressed)
	$MenuBox/SettingsButton.pressed.connect(_on_settings_pressed)
	$MenuBox/QuitButton.pressed.connect(_on_quit_pressed)


func _on_play_pressed():
	get_tree().change_scene_to_file("res://level_select.tscn")


func _on_settings_pressed():
	get_tree().change_scene_to_file("res://settings.tscn")


func _on_quit_pressed():
	get_tree().quit()
