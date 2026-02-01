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

var target: Node2D;
var flock: Array[Node2D];
	
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
	var separation_velocity = Vector2.ZERO;
	for boid in flock:
		if is_in_protection(boid):
			var sep = body.global_position - boid.global_position;
			separation_velocity += sep;
	body.velocity += separation_velocity * separation;
	
func alignment_pass():
	var alignment_velocity = Vector2.ZERO;
	var count = 0;
	for boid in flock:
		if is_in_visual(boid) and not is_in_protection(boid):
			alignment_velocity += boid.velocity;
			count += 1;
	if count != 0:
		alignment_velocity /= count;
	body.velocity += (alignment_velocity - body.velocity) * alignment;
	
func cohesion_pass():
	var cohesion_velocity = Vector2.ZERO;		
	var centroid = Vector2.ZERO;
	var count = 0;
	for boid in flock:
		if is_in_visual(boid) and not is_in_protection(boid):
			centroid += boid.global_position;
			count += 1;
	if count != 0:
		centroid /= count;
		cohesion_velocity = centroid - body.global_position;
	body.velocity += cohesion_velocity * cohesion;
	
func targeting_pass():
	if target != null:
		var line = target.global_position - body.global_position;
		if line.length() <= (visual_range * 2):
			body.velocity += (target.global_position - body.global_position) * targeting;

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
	queue_redraw();

func _draw():
	if not Engine.is_editor_hint():
		#draw_line(Vector2.ZERO, body.velocity.normalized() * 400, Color.RED);
		pass;

func fly(delta):
	poll_flock();
	
	separation_pass();
	alignment_pass();
	cohesion_pass();
	targeting_pass();
	
	var speed = body.velocity.length();
	if speed < min_speed:
		body.velocity = body.velocity.normalized() * min_speed;
	if speed > max_speed:
		body.velocity = body.velocity.normalized() * max_speed;
		
