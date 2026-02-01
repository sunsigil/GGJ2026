extends CharacterBody2D

var walker;
var dasher;
var swiper;
var shooter;
var splasher;
var masker;
var hitstop: Timer;
var camera;

func start_hitstop(stop_time, shake, shake_time):
	Engine.time_scale = 0;
	hitstop.wait_time = stop_time;
	hitstop.start();
	await hitstop.timeout;
	Engine.time_scale = 1;
	camera.start_shake(shake, shake_time);
func start_major_hitstop():
	start_hitstop(0.1, 20, 0.15);
func start_minor_hitstop():
	start_hitstop(0.05, 10, 0.005);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	walker = get_node("Walker");
	dasher = get_node("Dasher");
	swiper = get_node("Swiper");
	swiper.landed.connect(start_major_hitstop);
	shooter = get_node("Shooter");
	shooter.landed.connect(start_minor_hitstop);
	splasher = get_node("Splasher");
	splasher.landed.connect(start_major_hitstop);
	masker = get_node("Masker");
	hitstop = get_node("Hitstop");
	camera = get_tree().get_root().get_node("Playground/Camera");
	
	masker.unlock_mask(masker.MaskType.DASH);
	masker.unlock_mask(masker.MaskType.SHOOT);
	masker.unlock_mask(masker.MaskType.SPLASH);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass;
	
func _physics_process(delta):
	if not dasher.is_dashing():
		walker.walk(delta);
		
		var mask_direction = masker.global_position - global_position;
		if Input.is_action_just_pressed("game_attack"):
			swiper.swipe(mask_direction);
		if Input.is_action_just_pressed("game_cycle"):
			masker.cycle_mask();
		if Input.is_action_just_pressed("game_progress"):
			match masker.get_mask():
				masker.MaskType.DASH:
					dasher.dash(mask_direction);
				masker.MaskType.SHOOT:
					shooter.shoot(mask_direction);
				masker.MaskType.SPLASH:
					splasher.splash();
				_:
					swiper.swipe(mask_direction);
					
	move_and_slide();
	
	
