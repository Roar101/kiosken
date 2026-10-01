extends Control


func _ready():
	var box = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_CENTER)
	box.position = Vector2(-150, -100)
	box.custom_minimum_size = Vector2(300, 200)
	add_child(box)

	var title = Label.new()
	title.text = "SETTINGS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var volume_text = Label.new()
	volume_text.text = "LYDSTYRKE"
	box.add_child(volume_text)

	var volume = HSlider.new()
	volume.min_value = 0
	volume.max_value = 100
	volume.value = 100
	volume.value_changed.connect(_on_volume_changed)
	box.add_child(volume)

	var back = Button.new()
	back.text = "TILBAGE"
	back.pressed.connect(_on_back_pressed)
	box.add_child(back)


func _on_volume_changed(value):
	var volume_db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		volume_db
	)


func _on_back_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")
