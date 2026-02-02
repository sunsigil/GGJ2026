extends CharacterBody2D

@export
var rally_mark: Resource;

var walker;
var dasher;
var swiper;
var shooter;
var splasher;
var masker;
var hitstop: Timer;
var camera;
var hurt_cooldown: Timer;
var rally_timeout: Timer;
var relief_timeout: Timer;

var core_sprite: Sprite2D;
var flame_sprite: AnimatedSprite2D;
var leg_sprite: AnimatedSprite2D;

var attack_queue: Array[Attack];
var rally_targets: Array[Node2D];

var alive: bool;
var living: bool;
var dying: bool;

func get_universal_cooldown():
	var object = null;
	match masker.get_mask():
		Enums.MaskType.PLAIN:
			object = swiper;
		Enums.MaskType.DASH:
			object = dasher;
		Enums.MaskType.SHOOT:
			object = shooter;
		Enums.MaskType.SPLASH:
			object = splasher;
	if object == null:
		return 0.0;
	return 1.0 - (object.cooldown.time_left/object.cooldown.wait_time);

func start_hitstop(slow, slow_time, shake, shake_time):
	if slow_time > 0:
		Engine.time_scale = slow;
		hitstop.wait_time = slow_time;
		hitstop.start();
		await hitstop.timeout;
	Engine.time_scale = 1;
	camera.start_shake(shake, shake_time);
func major_hitstop_callback(body):
	start_hitstop(0, 0.1, 20, 0.15);
func minor_hitstop_callback(body):
	start_hitstop(0, 0.05, 10, 0.005);
func hurtstop_callback():
	start_hitstop(0.5, 0.25, 10, 0.25);

func rally_callback(body):
	if body in rally_targets:
		masker.stabilize();
		var mark = body.get_node("RallyMark");
		mark.queue_free();
		rally_targets.erase(body);
func rally_against(targets):
	for target in targets:
		if is_instance_valid(target) and not target in rally_targets:
			var mark = rally_mark.instantiate();
			target.add_child(mark);
			rally_targets.append(target);
	rally_timeout.start();
	relief_timeout.start();
	await rally_timeout.timeout;
	for target in rally_targets:
		if is_instance_valid(target):
			var mark = target.get_node("RallyMark");
			mark.queue_free();
	rally_targets = [];
	await relief_timeout.timeout;
	masker.stabilize();
	
func live():
	if living:
		return;
	living = true;

	flame_sprite.visible = true;
	flame_sprite.stop();
	flame_sprite.play_backwards("death");
	await flame_sprite.animation_finished;

	core_sprite.visible = true;
	leg_sprite.visible = true;
	masker.visible = true;
	alive = true;
	flame_sprite.play("default");
	
func die():
	if dying:
		return;
	dying = true;

	core_sprite.visible = false;
	leg_sprite.visible = false;
	if not hitstop.is_stopped():
		await hitstop.timeout;
	
	flame_sprite.stop();
	flame_sprite.play("death");
	await flame_sprite.animation_finished;
	
	get_tree().reload_current_scene();

func queue_attack(attack: Attack):
	if not dasher.is_dashing():
		attack_queue.append(attack);	
func handle_attacks():
	if attack_queue.is_empty():
		return;
		
	if not hurt_cooldown.is_stopped():
		return;
	
	var rally_candidates = [];
	while not attack_queue.is_empty():
		var attack = attack_queue.front();
		rally_candidates.append(attack.owner);
		attack_queue.pop_front();
	hurtstop_callback();
	if masker.get_mask() == Enums.MaskType.NONE:
		die();
	else:
		masker.destabilize();
		rally_against(rally_candidates);
	
	hurt_cooldown.start();
	await hurt_cooldown.timeout;
	hurt_cooldown.stop();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	walker = get_node("Walker");
	dasher = get_node("Dasher");

	swiper = get_node("Swiper");
	swiper.landed.connect(major_hitstop_callback);
	swiper.landed.connect(rally_callback);

	shooter = get_node("Shooter");
	shooter.landed.connect(minor_hitstop_callback);

	splasher = get_node("Splasher");
	splasher.landed.connect(major_hitstop_callback);

	masker = get_node("Masker");

	camera = get_tree().get_root().get_node("Playground/Camera");
	hitstop = get_node("Hitstop");
	hurt_cooldown = get_node("HurtCooldown");
	rally_timeout = get_node("RallyTimeout");
	relief_timeout = get_node("ReliefTimeout");
	core_sprite = get_node("Body");
	flame_sprite = get_node("Flames");
	leg_sprite = get_node("Legs");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if masker.is_mask_lost():
		core_sprite.material.set_shader_parameter("flash_colour", Vector4(1.0, 0.0, 0.5, 1.0));
		core_sprite.material.set_shader_parameter("flash_period", 0.25);
	elif masker.is_mask_endangered():
		core_sprite.material.set_shader_parameter("flash_colour", Vector4(0.25, 0.75, 0.85, 1.0));
		core_sprite.material.set_shader_parameter("flash_period", 0.5);
	else:
		core_sprite.material.set_shader_parameter("flash_colour", Vector4(1.0, 1.0, 1.0, 1.0));
		core_sprite.material.set_shader_parameter("flash_period", 0.0);
	
func _physics_process(delta):
	if not alive:
		if Input.is_action_just_pressed("game_progress"):
			live();
		return;
	if dying:
		return;
	
	handle_attacks();
	
	masker.swing(delta);
	if not dasher.is_dashing():
		walker.walk(delta);
		var mask_direction = masker.global_position - global_position;
		if Input.is_action_just_pressed("game_attack"):
			swiper.swipe(mask_direction);
		if Input.is_action_just_pressed("game_cycle"):
			masker.cycle();
		if Input.is_action_just_pressed("game_progress"):
			match masker.get_mask():
				Enums.MaskType.DASH:
					dasher.dash(velocity);
				Enums.MaskType.SHOOT:
					shooter.shoot(mask_direction);
				Enums.MaskType.SPLASH:
					splasher.splash();
				_:
					swiper.swipe(mask_direction);				
	move_and_slide();
	
	
