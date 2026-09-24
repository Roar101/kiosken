extends Area2D

# Træk de gemte scener for dine varer (.tscn filer) fra FileSystem ind her
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
	preload("res://vare_scener/vare_water.tscn"),
	# Du kan tilføje flere varer her, adskilt af komma, når du har lavet dem:
	# preload("res://en_anden_vare.tscn")
]

@onready var spawn_punkt = $SpawnPunkt
# Husk at rette -100 til det tal, du faktisk valgte som hastighed på dine varer!
var normal_hastighed = -100.0
var hojre_baand_korer = true # Viser om båndet køre
const KUNDE_SCENE = preload("res://vare_scener/kunde_martin.tscn") # Vær sikker på stien er korrekt!

func _ready():
	# Starter funktionen når spillet begynder (du kan også sætte dette på en knap eller når en NPC ankommer)
	spawn_kunde_varer()

func spawn_kunde_varer():
	var antal_varer = randi_range(1, 10)
	
	# Spawn selve kunden
	var ny_kunde = KUNDE_SCENE.instantiate()
	add_child(ny_kunde)
	
	
	# Sæt koordinaterne for, hvor kunden starter (uden for skærmen) og hvor kunden skal stå (ved pulten)
	# (Du skal sandsynligvis justere disse Vector2-tal, så de passer til dit spils opløsning)
	var start_pos = Vector2(200, -500) 
	var slut_pos = Vector2(200, 600)
	
	ny_kunde.start_kunde(antal_varer, start_pos, slut_pos)
	
	# Forbind kundens afgang til at starte denne funktion forfra = uendeligt loop!
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


# Når en vare rammer den HØJRE røde streg
func _on_stop_hojre_area_entered(area):
	hojre_baand_korer = false # Husk at båndet er stoppet
	# call_group rammer ALLE varer, der er i gruppen 'hojre_baand' og sætter deres fart til 0
	get_tree().call_group("hojre_baand", "saet_fart", 0)
	
func _on_stop_hojre_area_exited(area: Area2D) -> void:
	hojre_baand_korer = true # Husk at båndet kører igen
	# Når varen flyttes fra den røde streg, starter hele højre bånd igen
	get_tree().call_group("hojre_baand", "saet_fart", normal_hastighed)

# Når en vare rammer den VENSTRE røde streg
func _on_stop_venstre_area_entered(area):
	# Her stopper varen bare sig selv (så de hober sig op nede i enden)
	if "baand_fart" in area:
		area.baand_fart = 0

# Når varen rammer den GRØNNE streg (typisk når du har scannet den og trukket den herhen)
func _on_start_gron_area_entered(area):
	# Vi fjerner varen fra gruppen, så den ikke længere stopper, 
	# når nye varer rammer den højre fotocelle!
	if area.has_method("frys_paa_midten"):
		area.frys_paa_midten(false) # Start kørslen igen!


# NY SENSOR: Når varen ruller ind på kasseapparatet/scanneren
func _on_midte_zone_area_entered(area):
	# Fjern varen fra højre bånd MED DET SAMME, så den ignorerer start-beskeder derfra
	if area.is_in_group("hojre_baand"):
		area.remove_from_group("hojre_baand")
		
	if area.has_method("frys_paa_midten"):
		area.frys_paa_midten(true)


func _on_bog_klik_zone_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass # Replace with function body.
