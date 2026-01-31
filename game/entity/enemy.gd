extends CharacterBody2D;

var boid: Node2D;
var lifeforce: Node2D;
var hurtbox: Area2D;

func receive_hit(damage):
	lifeforce.queue_damage(damage);

func resolve_hurt(damage):
	print("Ouch! x", damage);

func death():
	print("Death!");
	queue_free();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boid = get_node("Boid");
	lifeforce = get_node("Lifeforce");
	hurtbox = get_node("Hurtbox");
	lifeforce.hurt.connect(resolve_hurt);
	lifeforce.death.connect(death);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	boid.target = PlayerData.player;
	
func _physics_process(delta: float) -> void:
	move_and_slide();
	pass;
