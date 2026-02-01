extends CharacterBody2D;

var boid: Node2D;
var lifeforce: Node2D;
var hurtbox: Area2D;
var swiper;
var shooter;
var splasher;
var attack_cooldown;

enum EnemyType {
	SWIPE,
	SHOOT,
	SPLASH,
};
@export
var type: EnemyType;

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
func is_hit_reacting():
	return knockback_time < knockback_duration;


func accept_death():
	should_die = true;
	
func queue_attack(_attack: Attack):
	attack_queue.append(_attack);	
func handle_attacks():
	while not attack_queue.is_empty():
		var _attack = attack_queue.front();
		lifeforce.queue_damage(_attack.damage);
		start_hit_react(_attack.direction);
		attack_queue.pop_front();

func target_vector():
	return PlayerData.player.global_position - global_position;
func target_distance():
	return target_vector().length();

func is_attacking():
	match type:
		EnemyType.SWIPE:
			return swiper.is_swiping();
		EnemyType.SHOOT:
			return false;
		EnemyType.SPLASH:
			return splasher.is_splashing();
	return false;

func should_attack():
	if is_attacking():
		return false;
	if not attack_cooldown.is_stopped():
		return false;

	match type:
		EnemyType.SWIPE:
			return target_distance() < swiper.extent;
		EnemyType.SHOOT:
			return target_distance() < boid.visual_range;
		EnemyType.SPLASH:
			return target_distance() < splasher.extent;
	return false;

func attack():
	if not should_attack():
		return;

	var trajectory = target_vector();
	match type:
		EnemyType.SWIPE:
			swiper.swipe(trajectory);
		EnemyType.SHOOT:
			shooter.shoot(trajectory);
		EnemyType.SPLASH:
			splasher.splash();
			
	attack_cooldown.start();
	await attack_cooldown.timeout;
	attack_cooldown.stop();


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boid = get_node("Boid");
	lifeforce = get_node("Lifeforce");
	hurtbox = get_node("Hurtbox");
	lifeforce.death.connect(accept_death);
	swiper = get_node("Swiper");
	shooter = get_node("Shooter");
	splasher = get_node("Splasher");
	attack_cooldown = get_node("AttackCooldown");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	boid.target = PlayerData.player;
	handle_attacks();
	if should_die and not is_hit_reacting():
		queue_free();

func _physics_process(delta: float) -> void:
	if is_hit_reacting():
		tick_hit_react(delta);
	else:
		attack();
		if is_attacking():
			velocity = Vector2.ZERO;
		else:
			boid.fly(delta);
	global_rotation = velocity.angle() - PI/2;
	move_and_slide();
