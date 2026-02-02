extends Node2D

var body: CharacterBody2D;
var animation: AnimatedSprite2D;

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

	animation.visible = true;
	animation.play();
	await animation.animation_finished;
	animation.visible = false;

	cooldown.start();
	await cooldown.timeout;
	cooldown.stop();

func is_swiping():
	return swiping;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = get_parent();
	animation = get_node("AnimatedSprite2D");
	hitfield = get_node("Hitfield");
	hitfield.collision_mask = mask;
	cooldown = get_node("Cooldown");

func _physics_process(delta: float) -> void:
	if not swiping:
		return;
	
	var t = time / duration;
	var central_angle = direction.angle();
	var angle = lerp(central_angle + arc/2, central_angle - arc/2, t);
	var ray_start = body.global_position;
	var ray_end = ray_start + Vector2.from_angle(angle) * extent;
	var space = get_world_2d().direct_space_state;
	var query = PhysicsRayQueryParameters2D.create(ray_start, ray_end, mask);

	var result = space.intersect_ray(query);
	if result and result.collider is CharacterBody2D and not result.collider in hit_record:
		var attack = Attack.new(
			body,
			body.global_position, direction,
			damage
		);
		result.collider.queue_attack(attack);
		if hit_record.is_empty():
			landed.emit(result.collider);
		hit_record.append(result.collider);
		
	time += delta;
	if time >= duration:
		swiping = false;

	global_rotation = direction.angle();
	
