extends CanvasLayer

@onready var display = $TextureRect/DisplayContainer # Sørg for navnet passer!
var indtastet_kode = ""

# @export laver felter i Inspektoren til dine sprites
@export var sprite_1: Texture2D
@export var sprite_2: Texture2D
@export var sprite_3: Texture2D
@export var sprite_4: Texture2D
@export var sprite_5: Texture2D
@export var sprite_6: Texture2D
@export var sprite_7: Texture2D
@export var sprite_8: Texture2D
@export var sprite_9: Texture2D
@export var sprite_0: Texture2D

func _ready():
	ryd_skaerm()

# Sletter alle indtastede tal (og billeder) fra den blå skærm
func ryd_skaerm():
	indtastet_kode = ""
	for barn in display.get_children():
		barn.queue_free()

# Denne funktion tager nu både det rigtige tal og det tilhørende billede
func tilfoj_tal(tal_streng: String, tal_billede: Texture2D):
	if indtastet_kode.length() < 3: # Max 3 tal på skærmen
		indtastet_kode += tal_streng
		
		# Her skaber vi billedet direkte i koden og putter det ind i HBoxContaineren
		var nyt_ciffer = TextureRect.new()
		nyt_ciffer.texture = tal_billede
		nyt_ciffer.position = Vector2(-20,-40)
		display.add_child(nyt_ciffer)
		

# --- Signaler fra dine knapper ---
# Husk at sende det rigtige billede (fx sprite_1) med i funktionen

func _on_btn_1_pressed(): tilfoj_tal("1", sprite_1)
func _on_btn_2_pressed(): tilfoj_tal("2", sprite_2)
func _on_btn_3_pressed(): tilfoj_tal("3", sprite_3)
func _on_btn_4_pressed(): tilfoj_tal("4", sprite_4)
func _on_btn_5_pressed(): tilfoj_tal("5", sprite_5)
func _on_btn_6_pressed(): tilfoj_tal("6", sprite_6)
func _on_btn_7_pressed(): tilfoj_tal("7", sprite_7)
func _on_btn_8_pressed(): tilfoj_tal("8", sprite_8)
func _on_btn_9_pressed(): tilfoj_tal("9", sprite_9)
# func _on_btn_0_pressed(): tilfoj_tal("0", sprite_0) # Hvis du har et 0

func _on_btn_enter_pressed():
	print("Koden var: ", indtastet_kode)
	ryd_skaerm()
	queue_free() # Lukker overlayet


func _on_btn_ent_pressed() -> void:
	pass # Replace with function body.
