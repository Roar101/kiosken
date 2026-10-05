extends Area2D

const BOG_OVERLAY = preload("res://bog_overlay.tscn")

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	# Tjekker om spilleren trykker venstre musetast ned på apparatet
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		# Skaber en kopi af dit numpad
		var overlay = BOG_OVERLAY.instantiate()
		
		# Tilføjer det til skærmen (øverst)
		get_tree().root.add_child(overlay)
