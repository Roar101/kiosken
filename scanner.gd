extends Area2D

var antal_scannede_varer = 0

# @onready sørger for at variablen først henter noden, når spillet er klar
@onready var bip_lyd = $AudioStreamPlayer 

func _on_area_entered(area):
	if "er_scannet" in area and area.er_scannet == false:
		area.er_scannet = true
		antal_scannede_varer += 1
		print("Bip! Varer scannet i alt: ", antal_scannede_varer)
		
		# Afspiller lyden fra AudioStreamPlayer-noden
		bip_lyd.play()

func _on_area_exited(area):
	if "er_scannet" in area:
		area.er_scannet = false
