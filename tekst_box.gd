extends MarginContainer

@onready var label = $MarginContainer/Label
@onready var timer = $LetterDisplayTimer
@onready var letter_sound = $LetterSound

@onready var choices = $Choices
@onready var choice1 = $Choices/Choice1
@onready var choice2 = $Choices/Choice2

const MAX_WIDTH = 256

var text = ""
var letter_index = 0

var letter_time = 0.05
var space_time = 0.03
var punctuation_time = 0.2

signal finished_displaying
signal choice_selected(correct: bool)


func _ready():
	timer.one_shot = true
	
	# Skjul svar-knapperne fra starten
	choices.visible = false
	
	if not timer.timeout.is_connected(_on_letter_display_timer_timeout):
		timer.timeout.connect(_on_letter_display_timer_timeout)
	
	if not choice1.pressed.is_connected(_on_choice1_pressed):
		choice1.pressed.connect(_on_choice1_pressed)
	
	if not choice2.pressed.is_connected(_on_choice2_pressed):
		choice2.pressed.connect(_on_choice2_pressed)


func display_text(text_to_display: String):
	text = text_to_display
	letter_index = 0

	label.text = text

	await get_tree().process_frame

	custom_minimum_size.x = min(size.x, MAX_WIDTH)

	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD

		await get_tree().process_frame
		await get_tree().process_frame

		custom_minimum_size.y = size.y

	var box_size = size * scale

	global_position -= Vector2(
		box_size.x / 2,
		box_size.y + 20
	)

	label.text = ""

	if text.length() > 0:
		_display_letter()
	else:
		finished_displaying.emit()


func _display_letter():
	var current_letter = text[letter_index]

	# Vis bogstav
	label.text += current_letter

	# Afspil lyd
	if current_letter != " ":
		letter_sound.stop()
		letter_sound.play()

	letter_index += 1

	# Når hele teksten er skrevet
	if letter_index >= text.length():
		finished_displaying.emit()
		return

	match current_letter:
		"!", ".", ",", "?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)


func _on_letter_display_timer_timeout():
	_display_letter()


# Viser de 2 svarmuligheder
func show_choices(first_choice: String, second_choice: String):
	choice1.text = first_choice
	choice2.text = second_choice
	
	choices.visible = true


# Første svar = rigtigt
func _on_choice1_pressed():
	choices.visible = false
	choice_selected.emit(true)


# Andet svar = forkert
func _on_choice2_pressed():
	choices.visible = false
	choice_selected.emit(false)
