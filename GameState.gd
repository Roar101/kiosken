extends Node

var tilfredshed = 10
var max_tilfredshed = 10

# DINE POINT
var score = 0

var vagt_tid = 120.0
var vagt_aktiv = false

var game_over = false
var vagt_slut_i_gang = false

var hud: CanvasLayer
var timer_label: Label
var tilfredshed_label: Label
var popup_timer: Timer


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


func start_vagt(seconds: float):
	tilfredshed = 10
	score = 0

	vagt_tid = seconds

	vagt_aktiv = true
	game_over = false
	vagt_slut_i_gang = false

	get_tree().paused = false

	_lav_hud()
	_opdater_vagt_timer()


func _process(delta):
	if not vagt_aktiv:
		return

	if game_over:
		return

	if vagt_slut_i_gang:
		return

	vagt_tid -= delta

	if vagt_tid < 0:
		vagt_tid = 0

	_opdater_vagt_timer()

	if vagt_tid <= 0:
		vagt_aktiv = false
		_vagt_gennemfoert()


func change_tilfredshed(amount: int):
	if game_over:
		return

	if vagt_slut_i_gang:
		return

	# Point ændres også
	score += amount

	if score < 0:
		score = 0

	tilfredshed = clamp(
		tilfredshed + amount,
		0,
		max_tilfredshed
	)

	# Vis popup HVER gang,
	# også selvom man allerede har 10/10
	_vis_tilfredshed_popup(
		amount
	)

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

	timer_label.position = Vector2(
		30,
		30
	)

	timer_label.add_theme_font_size_override(
		"font_size",
		32
	)

	timer_label.add_theme_color_override(
		"font_color",
		Color.WHITE
	)

	hud.add_child(
		timer_label
	)


	# KUNDETILFREDSHED
	tilfredshed_label = Label.new()

	tilfredshed_label.position = Vector2(
		30,
		80
	)

	tilfredshed_label.add_theme_font_size_override(
		"font_size",
		30
	)

	tilfredshed_label.visible = false

	hud.add_child(
		tilfredshed_label
	)


	popup_timer = Timer.new()

	popup_timer.one_shot = true
	popup_timer.wait_time = 2.0

	popup_timer.process_mode = (
		Node.PROCESS_MODE_ALWAYS
	)

	popup_timer.timeout.connect(
		_skjul_tilfredshed
	)

	hud.add_child(
		popup_timer
	)


func _opdater_vagt_timer():
	if not is_instance_valid(
		timer_label
	):
		return

	var total_seconds = int(
		ceil(vagt_tid)
	)

	var minutter = int(
		total_seconds / 60
	)

	var sekunder = (
		total_seconds % 60
	)

	timer_label.text = (
		"VAGT: %02d:%02d"
		% [
			minutter,
			sekunder
		]
	)


func _vis_tilfredshed_popup(
	amount: int
):
	if not is_instance_valid(
		tilfredshed_label
	):
		return

	if amount > 0:

		tilfredshed_label.text = (
			"+%d  Kundetilfredshed: %d/10"
			% [
				amount,
				tilfredshed
			]
		)

		tilfredshed_label.add_theme_color_override(
			"font_color",
			Color.GREEN
		)

	else:

		tilfredshed_label.text = (
			"%d  Kundetilfredshed: %d/10"
			% [
				amount,
				tilfredshed
			]
		)

		tilfredshed_label.add_theme_color_override(
			"font_color",
			Color.RED
		)

	tilfredshed_label.visible = true

	popup_timer.start()


func _skjul_tilfredshed():
	if is_instance_valid(
		tilfredshed_label
	):
		tilfredshed_label.visible = false


func _vagt_gennemfoert():
	if vagt_slut_i_gang:
		return

	vagt_slut_i_gang = true
	vagt_aktiv = false

	get_tree().paused = true

	var background = ColorRect.new()

	background.color = Color(
		0,
		0,
		0,
		0.92
	)

	background.process_mode = (
		Node.PROCESS_MODE_ALWAYS
	)

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	hud.add_child(
		background
	)


	var center = CenterContainer.new()

	center.process_mode = (
		Node.PROCESS_MODE_ALWAYS
	)

	center.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	background.add_child(
		center
	)


	var box = VBoxContainer.new()

	box.custom_minimum_size = Vector2(
		600,
		400
	)

	center.add_child(
		box
	)


	var title = Label.new()

	title.text = "TILLYKKE!"

	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title.add_theme_font_size_override(
		"font_size",
		55
	)

	box.add_child(
		title
	)


	var tekst = Label.new()

	tekst.text = (
		"Du klarede en vagt i kiosken!"
	)

	tekst.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	tekst.add_theme_font_size_override(
		"font_size",
		30
	)

	box.add_child(
		tekst
	)


	var mellemrum = Label.new()

	mellemrum.text = ""

	box.add_child(
		mellemrum
	)


	var scoreboard_title = Label.new()

	scoreboard_title.text = "SCOREBOARD"

	scoreboard_title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	scoreboard_title.add_theme_font_size_override(
		"font_size",
		40
	)

	box.add_child(
		scoreboard_title
	)


	var point_label = Label.new()

	point_label.text = (
		"POINT: %d"
		% score
	)

	point_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	point_label.add_theme_font_size_override(
		"font_size",
		34
	)

	box.add_child(
		point_label
	)


	var tilfredshed_score = Label.new()

	tilfredshed_score.text = (
		"Kundetilfredshed: %d/10"
		% tilfredshed
	)

	tilfredshed_score.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	tilfredshed_score.add_theme_font_size_override(
		"font_size",
		28
	)

	box.add_child(
		tilfredshed_score
	)


	var lukker_tekst = Label.new()

	lukker_tekst.text = (
		"Spillet lukker om 5 sekunder..."
	)

	lukker_tekst.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	lukker_tekst.add_theme_font_size_override(
		"font_size",
		20
	)

	box.add_child(
		lukker_tekst
	)


	await get_tree().create_timer(
		5.0,
		true
	).timeout

	get_tree().paused = false
	get_tree().quit()


func _game_over():
	if game_over:
		return

	game_over = true
	vagt_aktiv = false

	get_tree().paused = true

	var background = ColorRect.new()

	background.color = Color(
		0,
		0,
		0,
		0.92
	)

	background.process_mode = (
		Node.PROCESS_MODE_ALWAYS
	)

	background.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	hud.add_child(
		background
	)


	var center = CenterContainer.new()

	center.process_mode = (
		Node.PROCESS_MODE_ALWAYS
	)

	center.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)

	background.add_child(
		center
	)


	var box = VBoxContainer.new()

	box.custom_minimum_size = Vector2(
		450,
		400
	)

	center.add_child(
		box
	)


	var title = Label.new()

	title.text = "GAME OVER"

	title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	title.add_theme_font_size_override(
		"font_size",
		50
	)

	box.add_child(
		title
	)


	var point_label = Label.new()

	point_label.text = (
		"POINT: %d"
		% score
	)

	point_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	point_label.add_theme_font_size_override(
		"font_size",
		30
	)

	box.add_child(
		point_label
	)


	var score_label = Label.new()

	score_label.text = (
		"Kundetilfredshed: 0/10"
	)

	score_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	box.add_child(
		score_label
	)


	var restart = Button.new()

	restart.text = "GENSTART SPIL"

	restart.custom_minimum_size = Vector2(
		450,
		60
	)

	restart.process_mode = (
		Node.PROCESS_MODE_ALWAYS
	)

	restart.pressed.connect(
		_restart
	)

	box.add_child(
		restart
	)


	var menu = Button.new()

	menu.text = "MAIN MENU"

	menu.custom_minimum_size = Vector2(
		450,
		60
	)

	menu.process_mode = (
		Node.PROCESS_MODE_ALWAYS
	)

	menu.pressed.connect(
		_main_menu
	)

	box.add_child(
		menu
	)


	var quit = Button.new()

	quit.text = "QUIT"

	quit.custom_minimum_size = Vector2(
		450,
		60
	)

	quit.process_mode = (
		Node.PROCESS_MODE_ALWAYS
	)

	quit.pressed.connect(
		_quit
	)

	box.add_child(
		quit
	)


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
