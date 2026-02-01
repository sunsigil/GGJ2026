extends Node2D

var body: CharacterBody2D;

@export 
var damage: float = 25;
@export
var extent: float = 200;
@export
var duration: float = 0.25;
@export_flags_2d_physics
var mask: int;

var splashing: bool;
var cooldown: Timer;
var hitfield: Area2D;
var time: float;
var hit_record: Array[Node2D] = [];
signal landed;

func splash():
	if not cooldown.is_stopped() or splashing:
		return;
	splashing = true;
	time = 0;
	hit_record = [];
	cooldown.start();
	await cooldown.timeout;
	cooldown.stop();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = get_parent();
	hitfield = get_node("Hitfield");	
	hitfield.get_node("CollisionShape2D").shape.radius = extent;
	hitfield.collision_mask = mask;
	cooldown = get_node("Cooldown");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw();

func _physics_process(delta: float) -> void:
	if not splashing:
		return;

	time += delta;
	var t = time / duration;
	var radius = extent * t;
	hitfield.get_node("CollisionShape2D").shape.radius = radius;
	
	for other in hitfield.get_overlapping_bodies():
		if not other is CharacterBody2D:
			continue;
		if other in hit_record:
			continue;
		var attack = Attack.new(
			body,
			body.global_position, other.global_position - body.global_position,
			damage
		);
		other.queue_attack(attack);
		if hit_record.is_empty():
			landed.emit();
		hit_record.append(other);
		
	if time >= duration:
		splashing = false;

func _draw():
	if not splashing:
		return;
	var t = time / duration;
	var radius = extent * t;
	draw_circle(
		Vector2.ZERO, radius,
		Color.WHITE, false
	);
