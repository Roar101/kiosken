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

@onready var spawn_punkt = $SpawnPunkt

var normal_hastighed = -100.0
var hojre_baand_korer = true
var aktiv_kunde = null

const KUNDE_SCENE = preload("res://vare_scener/kunde_martin.tscn")


func _ready():
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

	ny_kunde.kunde_faerdig.connect(spawn_kunde_varer)

	var afstand_mellem_varer = 250

	for i in range(antal_varer):
		var ny_vare = mulige_varer.pick_random().instantiate()

		var spawn_pos = spawn_punkt.global_position
		spawn_pos.x += i * afstand_mellem_varer

		ny_vare.global_position = spawn_pos

		if hojre_baand_korer == false:
			ny_vare.saet_fart(0)
		else:
			ny_vare.saet_fart(normal_hastighed)

		add_child(ny_vare)


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

	if area.is_in_group("vare"):
		if not area.has_meta("scannet"):
			area.set_meta("scannet", true)

			if is_instance_valid(aktiv_kunde):
				aktiv_kunde.registrer_scannet_vare()
