extends Area2D

var antal_scannede_varer = 0


func _on_area_entered(area):
	if not area.is_in_group("vare"):
		return

	if area.has_meta("scanner_talt"):
		return

	area.set_meta("scanner_talt", true)

	if "er_scannet" in area:
		area.er_scannet = true

	antal_scannede_varer += 1

	print(
		"Bip! Varer scannet i alt: ",
		antal_scannede_varer
	)


func _on_area_exited(area):
	pass
