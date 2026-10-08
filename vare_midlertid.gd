extends Area2D

var is_dragging = false
var drag_offset = Vector2.ZERO
var er_scannet = false

var baand_fart = -100.0
var genstand_foran = null
var er_paa_midten = false

var scan_laas_aktiv = false
var scan_laas_x = 0.0

@onready var min_kollision = $CollisionShape2D

@export var skal_tastes: bool = false
@export var stregkode: String = ""

# BARRIERE VED STARTEN AF BÅNDET
# Højre side hvor varerne kommer fra
@export var start_barriere_x: float = 1920.0

var baand_top = 780.0
var baand_bund = 1110.0


func _ready():
	add_to_group("hojre_baand")
	add_to_group("vare")


func saet_fart(ny_fart):
	baand_fart = ny_fart


func _input_event(viewport, event, shape_idx):
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
	):
		if event.pressed:
			is_dragging = true

			drag_offset = (
				global_position
				- get_global_mouse_position()
			)


func _input(event):
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
	):
		if not event.pressed:
			is_dragging = false


func _process(delta):
	if not is_instance_valid(min_kollision):
		return

	if min_kollision.shape == null:
		return

	var boks_stoerrelse = min_kollision.shape.size

	var margin_x = boks_stoerrelse.x / 2.0
	var margin_y = boks_stoerrelse.y / 2.0

	# Varen må ikke komme forbi starten
	# af båndet mod højre.
	var maksimum_x = start_barriere_x - margin_x


	# Scanner-lås
	if has_meta("scannet"):
		if not scan_laas_aktiv:
			scan_laas_aktiv = true
			scan_laas_x = global_position.x


	if is_dragging:
		var target_pos = (
			get_global_mouse_position()
			+ drag_offset
		)

		# BARRIERE VED STARTEN
		if target_pos.x > maksimum_x:
			target_pos.x = maksimum_x

		# Hold varen på selve båndet lodret
		target_pos.y = clamp(
			target_pos.y,
			baand_top + margin_y,
			baand_bund - margin_y
		)

		# Når varen først er scannet,
		# må den heller ikke trækkes tilbage
		# mod højre over scanneren.
		if scan_laas_aktiv:
			target_pos.x = min(
				target_pos.x,
				scan_laas_x
			)

		global_position = target_pos


	else:
		if genstand_foran != null:

			if not is_instance_valid(genstand_foran):
				genstand_foran = null

			else:
				global_position.x += (
					genstand_foran.baand_fart
					* delta
				)

				var min_halve_bredde = (
					min_kollision.shape.size.x
					/ 2.0
				)

				var foran_kollision = (
					genstand_foran.get_node_or_null(
						"CollisionShape2D"
					)
				)

				if (
					foran_kollision != null
					and foran_kollision.shape != null
				):
					var foran_halve_bredde = (
						foran_kollision.shape.size.x
						/ 2.0
					)

					var min_afstand = (
						min_halve_bredde
						+ foran_halve_bredde
						- 5.0
					)

					if (
						global_position.x
						<
						genstand_foran.global_position.x
						+ min_afstand
					):
						global_position.x = (
							genstand_foran.global_position.x
							+ min_afstand
						)

		else:
			global_position.x += (
				baand_fart
				* delta
			)


	# EKSTRA SIKKERHED:
	# Den kan aldrig komme ud bag starten
	# af båndet mod højre.
	if global_position.x > maksimum_x:
		global_position.x = maksimum_x


	# Scannet vare må ikke tilbage
	# over scanneren.
	if scan_laas_aktiv:
		if global_position.x > scan_laas_x:
			global_position.x = scan_laas_x


func _on_area_entered(area: Area2D) -> void:
	if (
		"baand_fart" in area
		and area.global_position.x < global_position.x
	):
		genstand_foran = area


func _on_area_exited(area: Area2D) -> void:
	if area == genstand_foran:
		genstand_foran = null


func frys_paa_midten(skal_fryse: bool):
	if skal_fryse:
		baand_fart = 0
		genstand_foran = null
	else:
		baand_fart = -100.0
