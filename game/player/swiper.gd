extends Node2D

var body: CharacterBody2D;

@export_flags_2d_physics
var mask: int;
@export
var damage: float = 25;
@export
var extent: float = 400;
@export
var arc: float = PI/2;
@export
var duration: float = 0.25;

var swiping: bool;
var cooldown: Timer;
var direction: Vector2;
var time: float;
var hitfield: Area2D;
var hit_record: Array[Node2D] = [];
signal landed(body);

func swipe(_direction):
	if not cooldown.is_stopped() or swiping:
		return;
	swiping = true;
	direction = _direction.normalized();
	time = 0;
	hit_record = [];
	cooldown.start();
	await cooldown.timeout;
	cooldown.stop();
func is_swiping():
	return swiping;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = get_parent();
	hitfield = get_node("Hitfield");
	hitfield.collision_mask = mask;
	cooldown = get_node("Cooldown");
	
func _process(delta):
	queue_redraw();

func _physics_process(delta: float) -> void:
	if not swiping:
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

		var spoke = other.global_position - body.global_position;
		if spoke.length() > radius:
			continue;
		if abs(spoke.angle_to(direction)) > arc/2:
			continue;

		var attack = Attack.new(
			body,
			body.global_position, direction,
			damage
		);
		other.queue_attack(attack);
		if hit_record.is_empty():
			landed.emit(other);
		hit_record.append(other);
		
	if time >= duration:
		swiping = false;
		
func _draw():
	if not swiping:
		return;
	var t = time / duration;
	var radius = extent * t;
	var attack_angle = direction.angle() - body.rotation;
	draw_arc(
		Vector2.ZERO, radius,
		attack_angle - arc/2,
		attack_angle + arc/2,
		64, Color.WHITE
	);
	
