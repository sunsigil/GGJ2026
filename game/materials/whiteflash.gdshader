shader_type canvas_item;

uniform vec4 flash_colour = vec4(1);
uniform float flash_period = 0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(TEXTURE, UV);
	if((flash_period > 0.0) && (sin(TIME/flash_period*2.0*PI) >= 0.0))
		COLOR = vec4(flash_colour.xyz, COLOR.w);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
