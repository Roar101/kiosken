extends Node2D

const CHOICE_OVERLAY_SCENE = preload(
	"res://choice_overlay.tscn"
)

var forventede_varer = 0
var indsamlede_varer = 0
var scannede_varer = 0

var varer_klar_til_pakning = []

var intro_faerdig = false
var kan_klikkes = false
var overlay_aaben = false
var final_besvaret = false
var pakning_faerdig = false
var forlader = false

var foerste_svar_er_korrekt = true

# STRESS EFTER ALLE VARER ER SCANNET
var stress_timer_startet = false
var pakke_kontrol_startet = false
var pakke_straf_givet = false

# STRESS MELLEM SCANNINGER
var scan_timer_version = 0

# VEJLEDNING
var vejledning_tekst: Label = null
var vejledning_pil: Label = null

signal kunde_faerdig

@onready var pakke_timer = $PakkeTimer


const intro_lines: Array[String] = [
	"Hej!",
	"Jeg vil gerne betale for mine varer."
]


func start_kunde(
	antal,
	start_position,
	pult_position
):
	forventede_varer = antal
	indsamlede_varer = 0
	scannede_varer = 0

	varer_klar_til_pakning.clear()

	intro_faerdig = false
	kan_klikkes = false
	overlay_aaben = false
	final_besvaret = false
	pakning_faerdig = false
	forlader = false

	stress_timer_startet = false
	pakke_kontrol_startet = false
	pakke_straf_givet = false

	scan_timer_version = 0

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

	var denne_version = scan_timer_version

	_start_scan_stress(
		denne_version
	)


func registrer_scannet_vare():
	if scannede_varer >= forventede_varer:
		return

	scannede_varer += 1

	print(
		"Scannede varer: ",
		scannede_varer,
		"/",
		forventede_varer
	)

	scan_timer_version += 1

	_opdater_klik()

	if scannede_varer < forventede_varer:

		var denne_version = scan_timer_version

		_start_scan_stress(
			denne_version
		)

	else:
		# ALLE VARER ER SCANNET
		_vis_vejledning()

		if not stress_timer_startet:
			stress_timer_startet = true
			_start_svar_stress()

		if not pakke_kontrol_startet:
			pakke_kontrol_startet = true
			_start_pakke_kontrol()


func _vis_vejledning():
	if is_instance_valid(vejledning_pil):
		return

	# TEKSTEN OVER PILEN
	vejledning_tekst = Label.new()

	vejledning_tekst.text = (
		"CLICK FOR AT BETJENE KUNDEN"
	)

	vejledning_tekst.position = Vector2(
		-300,
		-275
	)

	vejledning_tekst.custom_minimum_size = Vector2(
		600,
		50
	)

	vejledning_tekst.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	vejledning_tekst.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	vejledning_tekst.add_theme_font_size_override(
		"font_size",
		26
	)

	vejledning_tekst.add_theme_color_override(
		"font_color",
		Color.YELLOW
	)

	vejledning_tekst.z_index = 100

	add_child(
		vejledning_tekst
	)


	# PILEN BLIVER PÅ SAMME STED
	vejledning_pil = Label.new()

	vejledning_pil.text = "↓"

	vejledning_pil.position = Vector2(
		-200,
		-220
	)

	vejledning_pil.custom_minimum_size = Vector2(
		400,
		50
	)

	vejledning_pil.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	vejledning_pil.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	vejledning_pil.add_theme_font_size_override(
		"font_size",
		26
	)

	vejledning_pil.add_theme_color_override(
		"font_color",
		Color.YELLOW
	)

	vejledning_pil.z_index = 100

	add_child(
		vejledning_pil
	)


func _skjul_vejledning():
	if is_instance_valid(vejledning_tekst):
		vejledning_tekst.queue_free()

	if is_instance_valid(vejledning_pil):
		vejledning_pil.queue_free()

	vejledning_tekst = null
	vejledning_pil = null


func _start_scan_stress(version: int):
	while true:

		await get_tree().create_timer(
			5.0
		).timeout

		if version != scan_timer_version:
			return

		if scannede_varer >= forventede_varer:
			return

		if forlader:
			return

		if GameState.game_over:
			return

		if GameState.vagt_slut_i_gang:
			return

		GameState.change_tilfredshed(-1)

		print(
			"For langsom scanning! -1 point"
		)

		if GameState.game_over:
			return


func _start_svar_stress():
	while true:

		await get_tree().create_timer(
			5.0
		).timeout

		if final_besvaret:
			return

		if forlader:
			return

		if GameState.game_over:
			return

		if GameState.vagt_slut_i_gang:
			return

		GameState.change_tilfredshed(-1)

		if GameState.game_over:
			return

		var sure_tekster: Array[String] = [
			"Hallo? Kan jeg betale eller hvad?!",
			"Jeg har altså ikke hele dagen!",
			"Er du snart færdig?!",
			"Jeg står stadig og venter!",
			"Kan vi komme videre snart?",
			"Det her tager alt for lang tid!"
		]

		if not DialogManager.is_dialog_active:
			DialogManager.start_dialog(
				global_position + Vector2(-100, -300),
				[
					sure_tekster.pick_random()
				]
			)


func _start_pakke_kontrol():
	await get_tree().create_timer(
		5.0
	).timeout

	if forlader:
		return

	if GameState.game_over:
		return

	if GameState.vagt_slut_i_gang:
		return

	if indsamlede_varer <= 0:
		if not pakke_straf_givet:

			pakke_straf_givet = true

			GameState.change_tilfredshed(-1)

			if GameState.game_over:
				return

			if not DialogManager.is_dialog_active:
				DialogManager.start_dialog(
					global_position + Vector2(-100, -300),
					[
						"Hvorfor ligger alle mine varer stadig her?!"
					]
				)


func _opdater_klik():
	kan_klikkes = (
		intro_faerdig
		and scannede_varer >= forventede_varer
		and forventede_varer > 0
		and not overlay_aaben
		and not final_besvaret
		and not forlader
	)


func _on_pakke_zone_area_entered(area):
	if not area.is_in_group("vare"):
		return

	if varer_klar_til_pakning.has(area):
		return

	varer_klar_til_pakning.append(area)

	if pakke_timer.is_stopped():
		pakke_en_vare()


func pakke_en_vare():
	if varer_klar_til_pakning.is_empty():
		return

	pakke_timer.wait_time = randf_range(
		0.5,
		4.5
	)

	pakke_timer.start()


func _on_pakke_timer_timeout():
	if varer_klar_til_pakning.is_empty():
		return

	var aktuel_vare = (
		varer_klar_til_pakning.pop_front()
	)

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

		if final_besvaret:
			forlad_butikken()

		return

	if varer_klar_til_pakning.size() > 0:
		pakke_en_vare()


func _input(event):
	if not kan_klikkes:
		return

	if overlay_aaben:
		return

	if final_besvaret:
		return

	if forlader:
		return

	if scannede_varer < forventede_varer:
		return

	if event is InputEventMouseButton:
		if (
			event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
			var mouse_pos = $Sprite2D.to_local(
				get_global_mouse_position()
			)

			if $Sprite2D.get_rect().has_point(
				mouse_pos
			):
				kan_klikkes = false
				overlay_aaben = true

				_skjul_vejledning()

				_vis_random_spoergsmaal()


func _vis_random_spoergsmaal():
	var situation = randi_range(0, 7)

	match situation:

		0:
			_vis_valg(
				"Er alle mine varer blevet scannet?",
				"Ja, alle dine varer er scannet.",
				"Nej, jeg mangler stadig nogle."
			)

		1:
			_vis_valg(
				"Jeg har virkelig travlt. Er vi færdige nu?",
				"Ja, alle varer er scannet.",
				"Nej, men du kan godt betale alligevel."
			)

		2:
			_vis_valg(
				"Min bus går snart! Kan jeg betale nu?",
				"Ja, alle dine varer er registreret.",
				"Nej, men vi springer resten over."
			)

		3:
			_vis_valg(
				"Er du sikker på, at du fik alle varerne med?",
				"Ja, jeg har scannet dem alle.",
				"Nej, jeg tror jeg sprang en over."
			)

		4:
			_vis_valg(
				"Der står folk og venter bag mig. Er vi klar?",
				"Ja, alt er scannet og klart.",
				"Nej, men det går nok."
			)

		5:
			_vis_valg(
				"Så mangler der ikke noget, vel?",
				"Nej, alle varer er scannet.",
				"Jo, der mangler stadig en vare."
			)

		6:
			_vis_valg(
				"Kan jeg gå videre til betaling nu?",
				"Ja, alle varer er blevet scannet.",
				"Nej, men betal bare alligevel."
			)

		_:
			_vis_valg(
				"Vi er færdige nu, ikke?",
				"Jo, alle dine varer er scannet.",
				"Nej, jeg mangler stadig noget."
			)


func _vis_valg(
	question: String,
	correct_answer: String,
	wrong_answer: String
):
	var overlay = (
		CHOICE_OVERLAY_SCENE.instantiate()
	)

	get_tree().root.add_child(
		overlay
	)

	foerste_svar_er_korrekt = (
		randf() < 0.5
	)

	if foerste_svar_er_korrekt:
		overlay.setup(
			question,
			correct_answer,
			wrong_answer
		)

	else:
		overlay.setup(
			question,
			wrong_answer,
			correct_answer
		)

	overlay.choice_selected.connect(
		_on_choice_selected
	)


func _on_choice_selected(
	valgte_foerste: bool
):
	overlay_aaben = false
	final_besvaret = true
	kan_klikkes = false

	_skjul_vejledning()

	var correct = (
		valgte_foerste
		== foerste_svar_er_korrekt
	)

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
				"Det var ikke særlig betryggende..."
			]
		)

	if pakning_faerdig:
		forlad_butikken()


func forlad_butikken():
	if not final_besvaret:
		return

	if not pakning_faerdig:
		return

	if scannede_varer < forventede_varer:
		return

	if forlader:
		return

	forlader = true
	kan_klikkes = false

	_skjul_vejledning()

	scan_timer_version += 1

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
