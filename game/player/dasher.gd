extends Node2D

var body;

@export
var range: float = 400;
@export
var duration: float = 0.1;
var start: Vector2;
var end: Vector2 = Vector2.ZERO;

var dashing: bool;
var time: float;

func dash(direction):
	start = position;
	end = position + direction;
	
	dashing = true;
	body.velocity = (end-start).normalized() * range/duration;
	time = 0;
	
func is_dashing():
	return dashing;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = get_parent();
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if body == null:
		return;
	if dashing:
		time += delta;
		if time >= duration:
			dashing = false;
