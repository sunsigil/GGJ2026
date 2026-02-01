extends CharacterBody2D

var walker;
var dasher;
var orbital;
var swiper;
var shooter;
var splasher;
var hitstop: Timer;
var camera;

enum PlayerState {
	WALK,
	DASH
};
var state: PlayerState = PlayerState.WALK;

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
	orbital = get_node("Orbital");
	swiper = get_node("Swiper");
	swiper.landed.connect(start_major_hitstop);
	shooter = get_node("Shooter");
	shooter.landed.connect(start_minor_hitstop);
	splasher = get_node("Splasher");
	splasher.landed.connect(start_major_hitstop);
	hitstop = get_node("Hitstop");
	camera = get_tree().get_root().get_node("Playground/Camera");
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass;
	
func _physics_process(delta):
	match state:
		PlayerState.WALK:
			walker.walk(delta);
			if Input.is_action_just_pressed("game_progress"):
				dasher.dash(velocity);
				state = PlayerState.DASH;
		PlayerState.DASH:
			if not dasher.is_dashing():
				state = PlayerState.WALK;
	move_and_slide();
	
	if Input.is_action_just_pressed("game_attack"):
		var direction = orbital.global_position - global_position;
		#swiper.swipe(direction);
		#shooter.shoot(direction);
		splasher.splash();
