shader_type canvas_item;

render_mode world_vertex_coords;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 base = vec4(vec3(0.25), 1.0);
	vec4 grid_x = vec4(float(int(VERTEX.x) % 100 == 0)) * 0.25;
	vec4 grid_y = vec4(float(int(VERTEX.y) % 100 == 0)) * 0.25;
	vec4 grid_x_2 = vec4(float(int(VERTEX.x) % 50 == 0)) * 0.15;
	vec4 grid_y_2 = vec4(float(int(VERTEX.y) % 50 == 0)) * 0.15;
	COLOR = base + grid_x + grid_y + grid_x_2 + grid_y_2;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
