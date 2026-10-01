extends CanvasLayer

@onready var background = $ColorRect
@onready var choices_box = $ColorRect/ChoicesBox
@onready var question_label = $ColorRect/ChoicesBox/QuestionLabel
@onready var choice1 = $ColorRect/ChoicesBox/Choice1
@onready var choice2 = $ColorRect/ChoicesBox/Choice2

signal choice_selected(correct: bool)

var answered = false
var timer_active = false
var time_left = 5.0

var timer_label: Label
var timer_bar: ProgressBar


func _ready():
	# Sløret baggrund
	var shader = Shader.new()
	shader.code = """
	shader_type canvas_item;

	uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

	void fragment() {
		vec4 blurred = textureLod(screen_texture, SCREEN_UV, 3.0);
		blurred.rgb *= 0.6;
		COLOR = blurred;
	}
	"""

	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	background.material = shader_material

	choice1.pressed.connect(_on_choice1_pressed)
	choice2.pressed.connect(_on_choice2_pressed)

	# Timer-tekst
	timer_label = Label.new()
	timer_label.text = "5"
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.custom_minimum_size = Vector2(0, 50)

	timer_label.add_theme_font_size_override("font_size", 36)
	timer_label.add_theme_color_override("font_color", Color.RED)

	choices_box.add_child(timer_label)
	choices_box.move_child(timer_label, 1)

	# Timer-bar
	timer_bar = ProgressBar.new()
	timer_bar.min_value = 0
	timer_bar.max_value = 5
	timer_bar.value = 5
	timer_bar.show_percentage = false
	timer_bar.custom_minimum_size = Vector2(300, 30)

	# Rød timer
	var timer_background = StyleBoxFlat.new()
	timer_background.bg_color = Color(0.15, 0.15, 0.15, 1.0)

	var timer_fill = StyleBoxFlat.new()
	timer_fill.bg_color = Color.RED

	timer_bar.add_theme_stylebox_override("background", timer_background)
	timer_bar.add_theme_stylebox_override("fill", timer_fill)

	choices_box.add_child(timer_bar)
	choices_box.move_child(timer_bar, 2)


func setup(
	question: String,
	answer1: String,
	answer2: String
):
	question_label.text = question
	choice1.text = answer1
	choice2.text = answer2

	answered = false
	time_left = 5.0
	timer_active = true

	timer_label.text = "5"
	timer_bar.value = 5


func _process(delta):
	if not timer_active:
		return

	time_left -= delta

	if time_left < 0:
		time_left = 0

	timer_label.text = str(ceil(time_left))
	timer_bar.value = time_left

	if time_left <= 0:
		timer_active = false

		if not answered:
			answered = true
			choice_selected.emit(false)
			queue_free()


func _on_choice1_pressed():
	if answered:
		return

	answered = true
	timer_active = false

	choice_selected.emit(true)
	queue_free()


func _on_choice2_pressed():
	if answered:
		return

	answered = true
	timer_active = false

	choice_selected.emit(false)
	queue_free()
