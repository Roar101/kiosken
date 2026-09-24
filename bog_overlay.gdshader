shader_type canvas_item;

// Henter skærmbilledet bagved og gør det klar til at blive sløret
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
// Gør det muligt for dig at justere styrken ude i menuen!
uniform float blur_amount : hint_range(0.0, 5.0) = 2.5;

void fragment() {
	// Pålægger sløringen
	COLOR = textureLod(screen_texture, SCREEN_UV, blur_amount);
}