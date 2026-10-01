extends Control


func _ready():
	var box = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.position = Vector2(-100, -250)
	add_child(box)

	var title = Label.new()
	title.text = "VÆLG LEVEL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	for i in range(1, 11):
		var button = Button.new()
		button.text = "Level " + str(i)
		button.custom_minimum_size = Vector2(200, 40)
		button.pressed.connect(_on_level_pressed.bind(i))
		box.add_child(button)

	var back = Button.new()
	back.text = "TILBAGE"
	back.pressed.connect(_on_back_pressed)
	box.add_child(back)


func _on_level_pressed(level: int):
	if level == 1:
		get_tree().change_scene_to_file("res://Main.tscn")
	else:
		print("Level ", level, " er ikke lavet endnu")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
