extends Area2D

var is_dragging = false
var drag_offset = Vector2.ZERO # Ny variabel til at huske afstanden
var er_scannet = false # Variablel til at huske om varen er scannet

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			# Gem forskellen mellem figurens position og musens position
			drag_offset = global_position - get_global_mouse_position()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			is_dragging = false

func _process(delta):
	if is_dragging:
		var target_pos = get_global_mouse_position() + drag_offset
		
		# Skift disse tal ud med kassebåndets faktiske koordinater i dit projekt
		var baand_venstre = 0
		var baand_hoejre = 1920
		var baand_top = 673
		var baand_bund = 1080
		
		# Tvinger figuren til at blive inden for disse fire rammer
		target_pos.x = clamp(target_pos.x, baand_venstre, baand_hoejre)
		target_pos.y = clamp(target_pos.y, baand_top, baand_bund)
		
		global_position = target_pos
