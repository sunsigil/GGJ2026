extends CharacterBody2D

var walker;
var dasher;

enum PlayerState {
	WALK,
	DASH
};
var state: PlayerState = PlayerState.WALK;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	walker = get_node("Walker");
	dasher = get_node("Dasher");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
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
	rotation = velocity.angle();
	move_and_slide();
