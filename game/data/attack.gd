class_name Attack;

var owner: Node2D;
var start: Vector2;
var direction: Vector2;
var range: float;
var damage: float;

func _init(_owner, _start, _direction, _range, _damage):
	owner = _owner;
	start = _start;
	direction = _direction;
	range = _range;
	damage = _damage;
