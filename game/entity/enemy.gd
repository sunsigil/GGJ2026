extends CharacterBody2D;

var boid: Node2D;
var lifeforce: Node2D;
var hurtbox: Area2D;

var attack_queue: Array[Attack];
var knockback: Vector2;
var knockback_duration: float = 0.1;
var knockback_time: float = 0;
var should_die: bool;
		
func start_hit_react(direction):
	knockback = direction * 4000;
	knockback_time = 0;
func tick_hit_react(delta):
	var t = knockback_time / knockback_duration;
	velocity = knockback * (1 - t*t);
	knockback_time += delta;
func in_hit_react():
	return knockback_time < knockback_duration;
	
func accept_death():
	should_die = true;
	
func queue_attack(attack: Attack):
	attack_queue.append(attack);	
func handle_attacks():
	while not attack_queue.is_empty():
		var attack = attack_queue.front();
		lifeforce.queue_damage(attack.damage);
		start_hit_react(attack.direction);
		attack_queue.pop_front();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boid = get_node("Boid");
	lifeforce = get_node("Lifeforce");
	hurtbox = get_node("Hurtbox");
	lifeforce.death.connect(accept_death);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	boid.target = PlayerData.player;
	handle_attacks();
	if should_die and not in_hit_react():
		queue_free();

func _physics_process(delta: float) -> void:
	if in_hit_react():
		tick_hit_react(delta);
	else:
		boid.fly(delta);
	move_and_slide();
