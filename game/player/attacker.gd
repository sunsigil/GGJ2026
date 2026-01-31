extends Node2D

var body: CharacterBody2D;

@export_flags_2d_physics
var mask: int;
@export
var damage: float;
@export
var range: float;

var last_start;
var last_ray;

func launch(direction):
	var space = get_world_2d().direct_space_state;
	var start = body.global_position;
	var ray = direction.normalized() * range;
	var query = PhysicsRayQueryParameters2D.create(start, start+ray, mask);
	var result = space.intersect_ray(query);
	if result:
		result.collider.receive_hit(damage);
	last_start = body.global_position;
	last_ray = ray;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = get_parent();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _draw():
	pass;
