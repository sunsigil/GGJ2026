extends Node2D

var trigger_area: Area2D;
var spawn_area: Area2D;

@export
var pool: Array[Resource];
@export
var capacity: int;
@export
var wait: float = 0.25;

var spawn_queue: Array;
var triggered: bool;
signal trigger;
signal spawn;

func trigger_spawns():
	triggered = true;
	
	spawn_queue = [];
	var angle = randf() * 2 * PI;
	for i in capacity:
		var resource = pool.pick_random();
		var radius = randf() * spawn_area.get_node("CollisionShape2D").shape.radius;
		var position = radius * Vector2(cos(angle), sin(angle));
		angle += 2 * PI / capacity;
		spawn_queue.append([resource, position]);
	trigger.emit();
	
	while not spawn_queue.is_empty():
		var pair = spawn_queue.front();
		var resource = pair[0];
		var position = pair[1];
		var instance = resource.instantiate();
		add_child(instance);
		instance.position = position;
		spawn.emit();
		spawn_queue.pop_front();
		await get_tree().create_timer(wait).timeout;
	
func poll_should_trigger(body):
	if triggered:
		return;
	if body.is_in_group("player"):
		trigger_spawns();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trigger_area = get_node("TriggerArea");
	spawn_area = get_node("SpawnArea");
	trigger_area.body_entered.connect(poll_should_trigger);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass;
	
