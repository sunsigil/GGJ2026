extends Node2D

var body: Node2D;

@export
var radius: float = 0;
@export
var delay: float = 0.1;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = get_parent();
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	if body == null:
		return;
	var arm = Vector2.UP.rotated(global_rotation) * radius;
	global_position = body.global_position + arm;
	var leg = get_global_mouse_position() - body.global_position;
	leg = leg.normalized() * radius;
	var arc = arm.angle_to(leg);
	global_rotation += arc * delta / delay;
	pass;
