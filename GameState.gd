extends Node

var tilfredshed = 10
var max_tilfredshed = 10

var vagt_tid = 120.0
var vagt_aktiv = false
var game_over = false

var hud: CanvasLayer
var timer_label: Label
var tilfredshed_label: Label
var popup_timer: Timer


func start_vagt(seconds: float):
	tilfredshed = 10
	vagt_tid = seconds
	vagt_aktiv = true
	game_over = false

	get_tree().paused = false

	_lav_hud()
	_opdater_vagt_timer()


func _process(delta):
	if not vagt_aktiv:
		return

	if game_over:
		return

	vagt_tid -= delta

	if vagt_tid < 0:
		vagt_tid = 0

	_opdater_vagt_timer()

	if vagt_tid <= 0:
		vagt_aktiv = false
		_vis_vagt_slut()


func change_tilfredshed(amount: int):
	if game_over:
		return

	var gammel_tilfredshed = tilfredshed

	tilfredshed = clamp(
		tilfredshed + amount,
		0,
		max_tilfredshed
	)

	var faktisk_aendring = tilfredshed - gammel_tilfredshed

	# Vis kun popup hvis point faktisk ændrede sig
	if faktisk_aendring != 0:
		_vis_tilfredshed_popup(faktisk_aendring)

	if tilfredshed <= 0:
		_game_over()


func _lav_hud():
	if is_instance_valid(hud):
		hud.queue_free()

	hud = CanvasLayer.new()
	hud.layer = 100
	hud.process_mode = Node.PROCESS_MODE_ALWAYS

	get_tree().root.add_child(hud)

	# VAGT TIMER
	timer_label = Label.new()
	timer_label.position = Vector2(30, 30)

	timer_label.add_theme_font_size_override(
		"font_size",
		32
	)

	timer_label.add_theme_color_override(
		"font_color",
		Color.WHITE
	)

	hud.add_child(timer_label)

	# KUNDETILFREDSHED POPUP
	tilfredshed_label = Label.new()
	tilfredshed_label.position = Vector2(30, 80)

	tilfredshed_label.add_theme_font_size_override(
		"font_size",
		30
	)

	tilfredshed_label.visible = false

	hud.add_child(tilfredshed_label)

	# TIMER TIL AT SKJULE POPUP
	popup_timer = Timer.new()
	popup_timer.one_shot = true
	popup_timer.wait_time = 2.0
	popup_timer.timeout.connect(_skjul_tilfredshed)

	hud.add_child(popup_timer)


func _opdater_vagt_timer():
	if not is_instance_valid(timer_label):
		return

	var total_seconds = int(ceil(vagt_tid))
	var minutter = int(total_seconds / 60)
	var sekunder = total_seconds % 60

	timer_label.text = "VAGT: %02d:%02d" % [
		minutter,
		sekunder
	]


func _vis_tilfredshed_popup(amount: int):
	if not is_instance_valid(tilfredshed_label):
		return

	if amount > 0:
		tilfredshed_label.text = (
			"+%d  Kundetilfredshed: %d/10"
			% [amount, tilfredshed]
		)

		tilfredshed_label.add_theme_color_override(
			"font_color",
			Color.GREEN
		)

	else:
		tilfredshed_label.text = (
			"%d  Kundetilfredshed: %d/10"
			% [amount, tilfredshed]
		)

		tilfredshed_label.add_theme_color_override(
			"font_color",
			Color.RED
		)

	tilfredshed_label.visible = true
	popup_timer.start()


func _skjul_tilfredshed():
	if is_instance_valid(tilfredshed_label):
		tilfredshed_label.visible = false


func _game_over():
	game_over = true
	vagt_aktiv = false

	get_tree().paused = true

	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.9)

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	hud.add_child(background)

	var center = CenterContainer.new()

	center.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	background.add_child(center)

	var box = VBoxContainer.new()
	box.custom_minimum_size = Vector2(400, 320)

	center.add_child(box)

	var title = Label.new()
	title.text = "GAME OVER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	title.add_theme_font_size_override(
		"font_size",
		50
	)

	box.add_child(title)

	var score = Label.new()
	score.text = "Kundetilfredshed: 0/10"
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	box.add_child(score)

	var restart = Button.new()
	restart.text = "GENSTART SPIL"
	restart.custom_minimum_size = Vector2(400, 60)
	restart.pressed.connect(_restart)

	box.add_child(restart)

	var menu = Button.new()
	menu.text = "MAIN MENU"
	menu.custom_minimum_size = Vector2(400, 60)
	menu.pressed.connect(_main_menu)

	box.add_child(menu)

	var quit = Button.new()
	quit.text = "QUIT"
	quit.custom_minimum_size = Vector2(400, 60)
	quit.pressed.connect(_quit)

	box.add_child(quit)


func _vis_vagt_slut():
	if not is_instance_valid(hud):
		return

	var label = Label.new()
	label.text = "VAGTEN ER SLUT!"
	label.position = Vector2(500, 250)

	label.add_theme_font_size_override(
		"font_size",
		50
	)

	hud.add_child(label)


func _restart():
	get_tree().paused = false

	if is_instance_valid(hud):
		hud.queue_free()

	get_tree().reload_current_scene()


func _main_menu():
	get_tree().paused = false

	if is_instance_valid(hud):
		hud.queue_free()

	get_tree().change_scene_to_file(
		"res://main_menu.tscn"
	)


func _quit():
	get_tree().paused = false
	get_tree().quit()
