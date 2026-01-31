extends Node2D

var body: Node2D;

@export
var speed: float = 600;
@export
var heading_weight: float = 2;
@export
var heading_delay: float = 1;
@export
var velocity_delay: float = 0.1;

var input: Vector2;
var input_last: Vector2;
var input_delta: Vector2;
var input_weight: Vector2;
var weight_time: float;
var heading: Vector2;

var gizmos_dirty = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = get_parent();
	pass;
	
func _process(delta):
	queue_redraw();
	
func walk(delta):
	input_last = input;
	input = Vector2.ZERO;
	if Input.is_action_pressed("game_right"):
		input.x += 1;
	if Input.is_action_pressed("game_up"):
		input.y -= 1;
	if Input.is_action_pressed("game_left"):
		input.x -= 1;
	if Input.is_action_pressed("game_down"):
		input.y += 1;
	input_delta = input - input_last;
	
	heading = input.normalized();
	if input_delta != Vector2.ZERO:
		input_weight = abs(input_delta) * heading * heading_weight;
		weight_time = 0;
	if weight_time <= heading_delay:
		heading += input_weight;
		input_weight = lerp(input_weight, Vector2.ZERO, weight_time/heading_delay);
		weight_time += delta;
		
	body.velocity = lerp(body.velocity, heading*speed, delta/velocity_delay);
	gizmos_dirty = true;
	
func _draw():
	if not gizmos_dirty:
		return;
	var scale_factor = 200;
	draw_line(Vector2.ZERO, input.rotated(-body.rotation) * scale_factor, Color.BLUE);
	draw_line(Vector2.ZERO, heading.rotated(-body.rotation) * scale_factor, Color.RED);
	draw_line(Vector2.ZERO, body.velocity.normalized().rotated(-body.rotation) * scale_factor, Color.GREEN);
	gizmos_dirty = false;
