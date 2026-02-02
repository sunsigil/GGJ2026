extends Node2D

var trigger_area: Area2D;

@export
var trigger_radius: float = 400;
@export
var resource: Resource;
@export
var wait: float = 0.25;

var triggered: bool;
signal trigger;
signal spawn;

func trigger_spawns():
	triggered = true;
	trigger.emit();
	await get_tree().create_timer(wait).timeout;
	var instance = resource.instantiate();
	call_deferred("add_child", instance);
	spawn.emit();
	
func poll_should_trigger(body):
	if triggered:
		return;
	trigger_spawns();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trigger_area = get_node("TriggerArea");
	trigger_area.body_entered.connect(poll_should_trigger);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	trigger_area.get_node("CollisionShape2D").shape.radius = trigger_radius;
	
