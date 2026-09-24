extends CanvasLayer


func _on_button_pressed() -> void:
	queue_free() # Sletter bogen fuldstændig, indtil du klikker på apparatet igen
