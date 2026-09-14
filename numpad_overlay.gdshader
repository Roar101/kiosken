shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Tallet 2.5 til sidst bestemmer hvor meget den slører. Gør det højere for mere sløring!
    COLOR = textureLod(screen_texture, SCREEN_UV, 2.5); 
}