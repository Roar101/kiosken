extends Node

@onready var text_box_scene = preload("res://tekst box.tscn")

signal dialog_finished

var is_dialog_active = false


func start_dialog(position: Vector2, lines: Array[String]):
	if is_dialog_active:
		return

	is_dialog_active = true

	for line in lines:
		var text_box = text_box_scene.instantiate()
		get_tree().root.add_child(text_box)

		text_box.global_position = position
		text_box.display_text(line)

		await get_tree().create_timer(3.0).timeout

		if is_instance_valid(text_box):
			text_box.queue_free()

		await get_tree().process_frame

	is_dialog_active = false
	
	# Fortæl at dialogen er færdig
	dialog_finished.emit()


func start_choice_dialog(
	position: Vector2,
	question: String,
	first_choice: String,
	second_choice: String,
	correct_response: String,
	wrong_response: String
):
	if is_dialog_active:
		return

	is_dialog_active = true

	var text_box = text_box_scene.instantiate()
	get_tree().root.add_child(text_box)

	text_box.global_position = position

	# Vis spørgsmålet
	text_box.display_text(question)

	# Vent til spørgsmålet er skrevet færdigt
	await text_box.finished_displaying

	# Vis de 2 svar
	text_box.show_choices(first_choice, second_choice)

	# Vent på spillerens valg
	var correct = await text_box.choice_selected

	# Fjern den gamle tekstboks
	if is_instance_valid(text_box):
		text_box.queue_free()

	await get_tree().process_frame

	# Lav en ny tekstboks til kundens svar
	var response_box = text_box_scene.instantiate()
	get_tree().root.add_child(response_box)

	response_box.global_position = position

	if correct:
		response_box.display_text(correct_response)
	else:
		response_box.display_text(wrong_response)

	# Vent 3 sekunder
	await get_tree().create_timer(3.0).timeout

	if is_instance_valid(response_box):
		response_box.queue_free()

	is_dialog_active = false
	
	# Fortæl at dialogen er færdig
	dialog_finished.emit()
