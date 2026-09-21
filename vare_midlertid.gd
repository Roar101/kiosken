extends Area2D

var is_dragging = false
var drag_offset = Vector2.ZERO
var er_scannet = false
var baand_fart = -100.0 # Negativt tal får den til at køre mod venstre. Positivt kører mod højre.
var genstand_foran = null
var er_paa_midten = false

# Henter CollisionShape2D-noden automatisk
@onready var min_kollision = $CollisionShape2D

func _ready():
	# Så snart varen spawner, bliver den en del af højre bånd
	add_to_group("hojre_baand")
	
	# NYT: Sæt automatisk varen i vare-gruppen, så NPC'en kan kende den
	add_to_group("vare")
	
# Ny funktion som kassebåndet kan bruge til at styre denne vare
func saet_fart(ny_fart):
	baand_fart = ny_fart

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_offset = global_position - get_global_mouse_position()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			is_dragging = false

func _process(delta):
	if is_dragging:
		var target_pos = get_global_mouse_position() + drag_offset
		
		var baand_venstre = -40  # Dine koordinater
		var baand_hoejre = 1960
		var baand_top = 780   
		var baand_bund = 1110
		
		# Hent størrelsen på præcis denne vares RectangleShape2D
		var boks_stoerrelse = min_kollision.shape.size
		
		# Udregn en unik X og Y margin (halvdelen af bredden/højden)
		var margin_x = boks_stoerrelse.x / 2.0
		var margin_y = boks_stoerrelse.y / 2.0
		
		# Brug margin_x til højre/venstre og margin_y til top/bund
		target_pos.x = clamp(target_pos.x, baand_venstre + margin_x, baand_hoejre - margin_x)
		target_pos.y = clamp(target_pos.y, baand_top + margin_y, baand_bund - margin_y)
		
		global_position = target_pos
		
	else:
		# Kø-system
		if genstand_foran != null:
			# 1. Følg hastigheden fra varen foran
			global_position.x += genstand_foran.baand_fart * delta
			
			# 2. DYNAMISK AFSTAND: Find begge varers halve bredde
			var min_halve_bredde = min_kollision.shape.size.x / 2.0
			var foran_halve_bredde = genstand_foran.get_node("CollisionShape2D").shape.size.x / 2.0
			
			# Læg dem sammen for at få den perfekte center-til-center afstand
			# Vi trækker 5 pixels fra, så de danner et lille, stabilt overlap
			var min_afstand = min_halve_bredde + foran_halve_bredde - 5.0
			
			# Skub tilbage hvis den kører for tæt på
			if global_position.x < genstand_foran.global_position.x + min_afstand:
				global_position.x = genstand_foran.global_position.x + min_afstand
				
		else:
			# Ingen foran os = kør med vores egen fart
			global_position.x += baand_fart * delta


func _on_area_entered(area: Area2D) -> void:
	# I stedet for at tjekke gruppen "hojre_baand", tjekker vi bare om det er en vare
	if "baand_fart" in area and area.global_position.x < global_position.x:
		genstand_foran = area


func _on_area_exited(area: Area2D) -> void:
	# Hvis varen foran os bliver løftet væk, har vi fri bane igen
	if area == genstand_foran:
		genstand_foran = null

# Gør det muligt for kassebåndet at parkere varen på midten
func frys_paa_midten(skal_fryse: bool):
	if skal_fryse:
		baand_fart = 0
		genstand_foran = null # Glemmer køen, så den ikke skubber til noget
	else:
		baand_fart = -100.0 # Husk at rette til din normale hastighed!
