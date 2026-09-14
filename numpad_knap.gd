extends Area2D

# FORSIGTIG: Sørg for at stien herunder passer til dit eget filsystem!
# Træk din numpad_overlay.tscn fra FileSystem-fanen op i koden for at få den præcise sti.
const NUMPAD_OVERLAY = preload("res://numpad_overlay.tscn")

func _on_input_event(viewport, event, shape_idx):
	# Tjekker om spilleren trykker venstre musetast ned på apparatet
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		# Skaber en kopi af dit numpad
		var overlay = NUMPAD_OVERLAY.instantiate()
		
		# Tilføjer det til skærmen (øverst)
		get_tree().root.add_child(overlay)
