extends Area2D

var mulige_varer = [
	preload("res://vare_scener/vare_bread.tscn"),
	preload("res://vare_scener/vare_butter.tscn"),
	preload("res://vare_scener/vare_cereal.tscn"),
	preload("res://vare_scener/vare_chicken.tscn"),
	preload("res://vare_scener/vare_chickenSoup.tscn"),
	preload("res://vare_scener/vare_detergentBlue.tscn"),
	preload("res://vare_scener/vare_detergentPink.tscn"),
	preload("res://vare_scener/vare_eggs4.tscn"),
	preload("res://vare_scener/vare_flakes.tscn"),
	preload("res://vare_scener/vare_flour.tscn"),
	preload("res://vare_scener/vare_gammon.tscn"),
	preload("res://vare_scener/vare_icecream.tscn"),
	preload("res://vare_scener/vare_milk.tscn"),
	preload("res://vare_scener/vare_OJ.tscn"),
	preload("res://vare_scener/vare_pudding.tscn"),
	preload("res://vare_scener/vare_Salmon.tscn"),
	preload("res://vare_scener/vare_soup.tscn"),
	preload("res://vare_scener/vare_spam.tscn"),
	preload("res://vare_scener/vare_Steak.tscn"),
	preload("res://vare_scener/vare_sugar.tscn"),
	preload("res://vare_scener/vare_tissue.tscn"),
	preload("res://vare_scener/vare_tomato.tscn"),
	preload("res://vare_scener/vare_tuna.tscn"),
	preload("res://vare_scener/vare_water.tscn")
]

const KUNDE_SCENE = preload(
	"res://vare_scener/kunde_martin.tscn"
)

@onready var spawn_punkt = $SpawnPunkt

var normal_hastighed = -100.0
var hojre_baand_korer = true

var aktuel_vare = null
var aktiv_kunde = null


func _ready():
	GameState.start_vagt(120.0)
	spawn_kunde_varer()


func spawn_kunde_varer():
	var antal_varer = randi_range(1, 10)

	var ny_kunde = KUNDE_SCENE.instantiate()
	add_child(ny_kunde)

	aktiv_kunde = ny_kunde

	var start_pos = Vector2(200, -500)
	var slut_pos = Vector2(200, 600)

	ny_kunde.start_kunde(
		antal_varer,
		start_pos,
		slut_pos
	)

	ny_kunde.kunde_faerdig.connect(
		_on_kunde_faerdig
	)

	# Spawn varerne én ad gangen
	for i in range(antal_varer):

		var ny_vare = mulige_varer.pick_random().instantiate()

		# Alle varer starter samme sted
		ny_vare.global_position = spawn_punkt.global_position

		if hojre_baand_korer:
			ny_vare.saet_fart(normal_hastighed)
		else:
			ny_vare.saet_fart(0)

		add_child(ny_vare)

		# Hvis der stadig mangler varer,
		# vent tilfældigt før næste vare kommer
		if i < antal_varer - 1:
			var ventetid = randf_range(0.8, 2.2)

			await get_tree().create_timer(
				ventetid
			).timeout


func _on_kunde_faerdig():
	aktiv_kunde = null

	await get_tree().create_timer(0.5).timeout

	spawn_kunde_varer()


func _on_stop_hojre_area_entered(area):
	hojre_baand_korer = false

	get_tree().call_group(
		"hojre_baand",
		"saet_fart",
		0
	)


func _on_stop_hojre_area_exited(area: Area2D) -> void:
	hojre_baand_korer = true

	get_tree().call_group(
		"hojre_baand",
		"saet_fart",
		normal_hastighed
	)


func _on_stop_venstre_area_entered(area):
	if "baand_fart" in area:
		area.baand_fart = 0


func _on_start_gron_area_entered(area):
	if area.has_method("frys_paa_midten"):
		area.frys_paa_midten(false)


func _on_midte_zone_area_entered(area):
	if area.is_in_group("hojre_baand"):
		area.remove_from_group("hojre_baand")

	if area.has_method("frys_paa_midten"):
		area.frys_paa_midten(true)

	aktuel_vare = area

	if not area.is_in_group("vare"):
		return

	if area.has_meta("scannet"):
		return

	area.set_meta("scannet", true)

	if is_instance_valid(aktiv_kunde):
		if aktiv_kunde.has_method("registrer_scannet_vare"):
			aktiv_kunde.registrer_scannet_vare()

	var skal_tastes = false

	if "skal_tastes" in area:
		skal_tastes = area.skal_tastes

	if skal_tastes == false:
		$Scanner/BipLyd.play()
