extends CharacterBody2D;

var boid: Node2D;
var lifeforce: Node2D;
var hurtbox: Area2D;

var attack_queue: Array[Attack];

func queue_attack(attack: Attack):
	attack_queue.append(attack);

func handle_attacks():
	while not attack_queue.is_empty():
		var attack = attack_queue.front();
		lifeforce.queue_damage(attack.damage);
		attack_queue.pop_front();

func death():
	queue_free();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boid = get_node("Boid");
	lifeforce = get_node("Lifeforce");
	hurtbox = get_node("Hurtbox");
	lifeforce.death.connect(death);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	boid.target = PlayerData.player;
	handle_attacks();
	
func _physics_process(delta: float) -> void:
	move_and_slide();
	pass;
