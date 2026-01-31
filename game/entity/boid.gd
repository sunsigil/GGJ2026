@tool
extends Node2D

var body;
var visual_disc: Area2D;
var protection_disc: Area2D;

@export
var group: String;

@export
var min_speed: float = 100;
@export
var max_speed: float = 800;

@export
var protection_range: float;
@export
var visual_range: float;

@export
var separation: float;
@export
var alignment: float;
@export
var cohesion: float;
@export
var targeting: float;

var flock: Array[Node2D];
var separation_velocity: Vector2;
var alignment_velocity: Vector2;
var cohesion_velocity: Vector2;

var target: Node2D;
var targeting_velocity: Vector2;
	
func poll_flock():
	flock = [];
	var candidates = visual_disc.get_overlapping_bodies();
	for item in candidates:
		if item.is_in_group("boid"):
			flock.append(item);
			
func is_in_visual(boid):
	var sep = body.global_position - boid.global_position;
	return sep.length() <= visual_range;
func is_in_protection(boid):
	var sep = body.global_position - boid.global_position;
	return sep.length() <= protection_range;
	
func find_discs():
	visual_disc = get_node("VisualDisc");
	protection_disc = get_node("ProtectionDisc");
func resize_discs():
	visual_disc.get_node("CollisionShape2D").shape.radius = visual_range;
	protection_disc.get_node("CollisionShape2D").shape.radius = protection_range;
	
func separation_pass():
	separation_velocity = Vector2.ZERO;
	for boid in flock:
		if is_in_protection(boid):
			var sep = body.global_position - boid.global_position;
			separation_velocity += sep * separation;
	
func alignment_pass():
	alignment_velocity = Vector2.ZERO;
	var mean = Vector2.ZERO;
	var count = 0;
	for boid in flock:
		if is_in_visual(boid) and not is_in_protection(boid):
			mean += boid.velocity;
			count += 1;
	if count != 0:
		mean /= count;
		alignment_velocity = (mean - body.velocity) * alignment;
	
func cohesion_pass():
	cohesion_velocity = Vector2.ZERO;		
	var centroid = Vector2.ZERO;
	var count = 0;
	for boid in flock:
		if is_in_visual(boid) and not is_in_protection(boid):
			centroid += boid.global_position;
			count += 1;
	if count != 0:
		centroid /= count;
		cohesion_velocity = (centroid - body.global_position) * cohesion;
	
func targeting_pass():
	targeting_velocity = Vector2.ZERO;
	if target != null:
		var line = target.global_position - body.global_position;
		if line.length() <= visual_range:
			targeting_velocity = (target.global_position - body.global_position) * targeting;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = get_parent();
	find_discs();
	resize_discs();
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		find_discs();
		resize_discs();

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		poll_flock();
		
		separation_pass();
		alignment_pass();
		cohesion_pass();
		targeting_pass();
		
		var velocity = (
			separation_velocity +
			alignment_velocity +
			cohesion_velocity +
			targeting_velocity
		);
		var speed = velocity.length();
		if speed < min_speed:
			velocity = velocity.normalized() * min_speed;
		if speed > max_speed:
			velocity = velocity.normalized() * max_speed;
		body.velocity = velocity;
		
