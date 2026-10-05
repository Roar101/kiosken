extends Node2D

const CHOICE_OVERLAY_SCENE = preload("res://choice_overlay.tscn")

var forventede_varer = 0
var indsamlede_varer = 0
var scannede_varer = 0
var varer_klar_til_pakning = []

var intro_faerdig = false
var kan_klikkes = false
var overlay_aaben = false
var har_svaret = false
var pakning_faerdig = false
var forlader = false

signal kunde_faerdig

@onready var pakke_timer = $PakkeTimer


const intro_lines: Array[String] = [
	"Hej!",
	"Jeg vil gerne betale for mine varer."
]


func start_kunde(antal, start_position, pult_position):
	forventede_varer = antal
	global_position = start_position

	var tween = create_tween()

	tween.tween_property(
		self,
		"global_position",
		pult_position,
		2.0
	)

	await tween.finished

	await DialogManager.start_dialog(
		global_position + Vector2(-100, -300),
		intro_lines
	)

	intro_faerdig = true
	_opdater_klik()


func registrer_scannet_vare():
	scannede_varer += 1

	print(
		"Scannede varer: ",
		scannede_varer,
		"/",
		forventede_varer
	)

	_opdater_klik()


func _opdater_klik():
	kan_klikkes = (
		intro_faerdig
		and scannede_varer >= forventede_varer
		and not overlay_aaben
		and not har_svaret
	)


func _on_pakke_zone_area_entered(area):
	if area.is_in_group("vare"):

		if not varer_klar_til_pakning.has(area):
			varer_klar_til_pakning.append(area)

		if pakke_timer.is_stopped():
			pakke_en_vare()


func pakke_en_vare():
	if varer_klar_til_pakning.is_empty():
		return

	pakke_timer.wait_time = randf_range(0.5, 4.5)
	pakke_timer.start()


func _on_pakke_timer_timeout():
	if varer_klar_til_pakning.is_empty():
		return

	var aktuel_vare = varer_klar_til_pakning.pop_front()

	if is_instance_valid(aktuel_vare):
		aktuel_vare.queue_free()
		indsamlede_varer += 1

		print(
			"Pakkede varer: ",
			indsamlede_varer,
			"/",
			forventede_varer
		)

	if indsamlede_varer >= forventede_varer:
		pakning_faerdig = true

		if har_svaret:
			forlad_butikken()

		return

	if varer_klar_til_pakning.size() > 0:
		pakke_en_vare()


func _input(event):
	if not kan_klikkes:
		return

	if overlay_aaben:
		return

	if har_svaret:
		return

	if event is InputEventMouseButton:

		if (
			event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):

			var mouse_pos = $Sprite2D.to_local(
				get_global_mouse_position()
			)

			if $Sprite2D.get_rect().has_point(mouse_pos):

				kan_klikkes = false
				overlay_aaben = true

				var overlay = CHOICE_OVERLAY_SCENE.instantiate()

				get_tree().root.add_child(overlay)

				overlay.setup(
					"Er alle mine varer blevet scannet?",
					"Ja, alle dine varer er scannet!",
					"Nej, jeg mangler stadig nogle."
				)

				overlay.choice_selected.connect(
					_on_choice_selected
				)


func _on_choice_selected(correct: bool):
	overlay_aaben = false
	har_svaret = true
	kan_klikkes = false

	if correct:

		GameState.change_tilfredshed(1)

		await DialogManager.start_dialog(
			global_position + Vector2(-100, -300),
			[
				"Perfekt, tak for hjælpen!"
			]
		)

	else:

		GameState.change_tilfredshed(-1)

		await DialogManager.start_dialog(
			global_position + Vector2(-100, -300),
			[
				"Hvad?! Det er da dårlig service!"
			]
		)

	if pakning_faerdig:
		forlad_butikken()


func forlad_butikken():
	if forlader:
		return

	forlader = true
	kan_klikkes = false

	var tween = create_tween()

	tween.tween_property(
		self,
		"global_position:y",
		-500,
		1.0
	)

	await tween.finished

	kunde_faerdig.emit()
	queue_free()
