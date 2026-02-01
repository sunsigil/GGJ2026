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
var cooldown: Timer;

func dash(direction):
	if dashing or not cooldown.is_stopped():
		return;
	start = position;
	end = position + direction;
	dashing = true;
	body.velocity = (end-start).normalized() * range/duration;
	time = 0;

	cooldown.start();
	await cooldown.timeout;
	cooldown.stop();
	
func is_dashing():
	return dashing;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = get_parent();
	cooldown = get_node("Cooldown");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if dashing:
		time += delta;
		if time >= duration:
			dashing = false;
