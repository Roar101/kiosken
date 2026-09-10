extends Area2D

var is_dragging = false
var drag_offset = Vector2.ZERO
var er_scannet = false

# Henter CollisionShape2D-noden automatisk
@onready var min_kollision = $CollisionShape2D

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
