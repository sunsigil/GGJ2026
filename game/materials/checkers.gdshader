shader_type canvas_item;

render_mode world_vertex_coords;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 dark = vec4(vec3(0.25), 1.0);
	vec4 light = vec4(vec3(0.5), 1.0);
	int grid_x = int(UV.x * 2.0);
	int grid_y = int(UV.y * 2.0);
	bool key = (grid_x % 2 == 0) != (grid_y % 2 == 0);
	COLOR = key ? light : dark;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
