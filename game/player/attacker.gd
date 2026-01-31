extends Node2D

var body: CharacterBody2D;

@export_flags_2d_physics
var mask: int;
@export
var damage: float;
@export
var range: float;

func launch(direction):
	var space = get_world_2d().direct_space_state;
	var start = body.global_position;
	var ray = start + direction * range;
	var query = PhysicsRayQueryParameters2D.create(start, start+ray, mask);
	var result = space.intersect_ray(query);
	if result:
		var attack = Attack.new(
			body,
			start, direction,
			range,
			damage
		);
		result.collider.queue_attack(attack);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = get_parent();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass;
	
func _draw():
	pass;
