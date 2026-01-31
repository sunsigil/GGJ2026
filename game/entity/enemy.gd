extends CharacterBody2D;

var boid: Node2D;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boid = get_node("Boid");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	boid.target = PlayerData.player;
	
func _physics_process(delta: float) -> void:
	move_and_slide();
	pass;
