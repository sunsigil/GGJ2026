extends Area2D;

func _collide(body):
	body.die();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_collide);
	pass # Replace with function body.
