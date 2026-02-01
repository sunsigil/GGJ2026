extends Node2D

@export
var bullet: Resource;
var cooldown: Timer;
signal landed;

func shoot(trajectory):
	if not cooldown.is_stopped():
		return;
		
	var instance = bullet.instantiate();
	call_deferred("add_child", instance);
	instance.sender = self;
	instance.trajectory = trajectory.normalized();

	cooldown.start();
	await cooldown.timeout;
	cooldown.stop();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cooldown = get_node("Cooldown");
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
