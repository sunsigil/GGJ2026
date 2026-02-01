extends AnimatedSprite2D;

@export
var none_mask: Resource;
@export
var plain_mask: Resource;
@export
var dash_mask: Resource;
@export
var shoot_mask: Resource;
@export
var splash_mask: Resource;

func toggle_flash(value):
	var period = 0.25 if value else 0.0;
	material.set_shader_parameter("flash_period", period);

func change(type):
	stop();
	play("dissolve");
	if is_playing():
		await animation_finished;
	match type:
		0:
			sprite_frames = plain_mask;
		1:
			sprite_frames = dash_mask;
		2:
			sprite_frames = shoot_mask;
		3:
			sprite_frames = splash_mask;
		_:
			sprite_frames = none_mask;
	play_backwards("dissolve");
	if is_playing():
		await animation_finished;
	play("default");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change(0);
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
