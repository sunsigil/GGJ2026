extends Area2D

@export
var mask: Enums.MaskType;

func collect(body):
	body.masker.unlock(mask);
	queue_free();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(collect);
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
