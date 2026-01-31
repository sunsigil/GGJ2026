extends Node2D

enum LifeStatus {
	ALIVE,
	DEAD
};
var status: LifeStatus = LifeStatus.ALIVE;
signal death;

@export
var max_health: float = 100;
var health: float = max_health;

var damage_queue: Array[int] = [];

func queue_damage(damage):
	damage_queue.append(health);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match status:
		LifeStatus.ALIVE:
			while not damage_queue.is_empty():
				var damage = damage_queue.front();
				health -= damage;
				damage_queue.pop_front();
			if health <= 0:
				status = LifeStatus.DEAD;
				death.emit();
		LifeStatus.DEAD:
			pass;
