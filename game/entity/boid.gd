@tool
extends Node2D

var body;
var visual_disc: CollisionObject2D;
var protection_disc: CollisionObject2D;

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

var protection_boids: Array[Node2D];
var visual_boids: Array[Node2D];
var separation_velocity: Vector2;
var alignment_velocity: Vector2;
var cohesion_velocity: Vector2;

var target: Node2D;
var targeting_velocity: Vector2;
	
func _on_visual_disc_area_entered(area):
	var candidate = area.get_parent();
	if candidate == self:
		return;
	if not candidate in visual_boids:
		visual_boids.append(candidate);
		print("Visual enter");
func _on_visual_disc_area_exited(area):
	var candidate = area.get_parent();
	if candidate == self:
		return;
	if candidate in visual_boids:
		visual_boids.erase(candidate);
		print("Visual exit");
func _on_protection_disc_area_entered(area):
	var candidate = area.get_parent();
	if candidate == self:
		return;
	if not candidate in protection_boids:
		protection_boids.append(candidate);
		print("Protection enter");
func _on_protection_disc_area_exited(area):
	var candidate = area.get_parent();
	if candidate == self:
		return;
	if candidate in protection_boids:
		protection_boids.erase(candidate);
		print("Protection exit");

func find_discs():
	visual_disc = get_node("VisualDisc");
	protection_disc = get_node("ProtectionDisc");

func resize_discs():
	visual_disc.get_node("CollisionShape2D").shape.radius = visual_range;
	protection_disc.get_node("CollisionShape2D").shape.radius = protection_range;
	
func separation_pass():
	separation_velocity = Vector2.ZERO;
	if protection_boids.is_empty():
		return;
	for boid in protection_boids:
		separation_velocity += body.global_position - boid.body.global_position;
	print("Separation");
	
func alignment_pass():
	alignment_velocity = Vector2.ZERO;
	if visual_boids.is_empty():
		return;
	for boid in visual_boids:
		alignment_velocity += boid.body.velocity;
	alignment_velocity /= len(visual_boids);
	#alignment_velocity -= body.velocity;
	print("Alignment");
	
func cohesion_pass():
	cohesion_velocity = Vector2.ZERO;
	if visual_boids.is_empty():
		return;
	var centroid = Vector2.ZERO;
	for boid in visual_boids:
		centroid += boid.body.global_position;
	centroid /= len(visual_boids);
	cohesion_velocity = (centroid - body.global_position) * cohesion;
	print("Cohesion");
	
func targeting_pass():
	targeting_velocity = Vector2.ZERO;
	if target != null:
		var line = target.global_position - body.global_position;
		if line.length() <= visual_range:		
			targeting_velocity = (target.global_position - body.global_position) * targeting;
	print("Targeting");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = get_parent();
	find_discs();
	resize_discs();
	visual_disc.area_entered.connect(_on_visual_disc_area_entered);
	visual_disc.area_exited.connect(_on_visual_disc_area_exited);
	protection_disc.area_entered.connect(_on_protection_disc_area_entered);
	protection_disc.area_exited.connect(_on_protection_disc_area_exited);
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		find_discs();
		resize_discs();

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		#separation_pass();
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
		
