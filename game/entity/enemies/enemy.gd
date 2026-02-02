extends CharacterBody2D;

var boid: Node2D;
var lifeforce: Node2D;
var hurtbox: Area2D;
var swiper;
var shooter;
var splasher;
var attack_cooldown;
var sprite: AnimatedSprite2D;
var knockback_timer: Timer;

enum EnemyType {
	SWIPE,
	SHOOT,
	SPLASH,
	HUDISON
};
@export
var type: EnemyType;
@export
var swivel: bool;

var attack_queue: Array[Attack];
var knockback: Vector2;
var should_die: bool;
		

func is_in_knockback():
	return not knockback_timer.is_stopped();
func start_knockback(direction, strength):
	if is_in_knockback():
		return;
	knockback = direction * strength;
	knockback_timer.start();
	await knockback_timer.timeout;
	knockback_timer.stop();
func tick_knockback():
	var t = 1 - (knockback_timer.time_left / knockback_timer.wait_time);
	velocity = knockback * (1 - t*t);

func die():
	if is_in_knockback():
		await knockback_timer.timeout;
	sprite.stop();
	sprite.play("death");
	await sprite.animation_finished;
	queue_free();
	
func queue_attack(_attack: Attack):
	attack_queue.append(_attack);	
func handle_attacks():
	while not attack_queue.is_empty():
		var _attack = attack_queue.front();
		lifeforce.queue_damage(_attack.damage);
		start_knockback(_attack.direction, 4000);
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
		EnemyType.HUDISON:
			return swiper.is_swiping();
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
		EnemyType.HUDISON:
			return target_distance() < swiper.extent or target_distance() < boid.visual_range;
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
		EnemyType.HUDISON:
			if target_distance() <= swiper.extent+10:
				swiper.swipe(trajectory);
			else:
				shooter.shoot(trajectory);
			
	attack_cooldown.start();
	await attack_cooldown.timeout;
	attack_cooldown.stop();


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boid = get_node("Boid");
	lifeforce = get_node("Lifeforce");
	hurtbox = get_node("Hurtbox");
	lifeforce.death.connect(die);
	swiper = get_node("Swiper");
	shooter = get_node("Shooter");
	splasher = get_node("Splasher");
	attack_cooldown = get_node("AttackCooldown");
	sprite = get_node("AnimatedSprite2D");
	knockback_timer = get_node("KnockbackTimer");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if PlayerData.player == null:
		return;
	boid.target = PlayerData.player;
	handle_attacks();
	if should_die and not is_in_knockback():
		queue_free();

func _physics_process(delta: float) -> void:
	if PlayerData.player == null:
		return;
	if sprite.animation == "death":
		return;
	if is_in_knockback():
		tick_knockback();
	else:
		attack();
		if is_attacking():
			velocity = Vector2.ZERO;
		else:
			boid.fly(delta);
	if swivel:
		global_rotation = (PlayerData.player.global_position - global_position).angle() - PI/2;
	move_and_slide();
