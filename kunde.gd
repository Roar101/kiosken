extends Node2D

var forventede_varer = 0
var indsamlede_varer = 0
var varer_klar_til_pakning = []

# Dette signal fortæller hovedspillet, at næste kunde kan komme
signal kunde_faerdig

@onready var pakke_timer = $PakkeTimer

# Kaldes af kassebåndet når kunden spawner
func start_kunde(antal, start_position, pult_position):
	forventede_varer = antal
	global_position = start_position
	
	# Tween får kunden til at glide pænt ind på plads på 2 sekunder
	var tween = create_tween()
	tween.tween_property(self, "global_position", pult_position, 2.0)

# Når en vare ruller ind i pakkezonen (venstre side af båndet)
func _on_pakke_zone_area_entered(area):
	if area.is_in_group("vare"):
		varer_klar_til_pakning.append(area)
		
		# Hvis kunden ikke allerede er i gang med at pakke en vare, startes timeren
		if pakke_timer.is_stopped():
			pakke_en_vare()

func pakke_en_vare():
	# Sæt et random tempo mellem 0.5 og 1.5 sekunder
	pakke_timer.wait_time = randf_range(0.5, 4.5)
	pakke_timer.start()

# Når timeren udløber (kunden tager varen)
func _on_pakke_timer_timeout():
	if varer_klar_til_pakning.size() > 0:
		var aktuel_vare = varer_klar_til_pakning.pop_front()
		
		# Tjekker om varen stadig findes (hvis spilleren f.eks. trak i den)
		if is_instance_valid(aktuel_vare):
			aktuel_vare.queue_free() # Sletter varen helt fra spillet
			indsamlede_varer += 1
			
		# Tjek om vi er færdige
		if indsamlede_varer >= forventede_varer:
			forlad_butikken()
		elif varer_klar_til_pakning.size() > 0:
			pakke_en_vare() # Tag næste vare i køen

func forlad_butikken():
	var tween = create_tween()
	# Får kunden til at glide op af skærmen (Y = -500) på 1 sekund
	tween.tween_property(self, "global_position:y", -500, 1.0)
	await tween.finished # Vent til animationen er slut
	
	kunde_faerdig.emit() # Giv besked til Kassebåndet
	queue_free() # Slet kunden
