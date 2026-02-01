extends Node2D

@export 
var damage: float;
@export
var speed: float;
var hitbox: Area2D;
var homing_area: Area2D

var sender;
var trajectory;
var mask: int;

func _collide(body):
	if body is CharacterBody2D:
		var attack = Attack.new(
			sender.get_parent(),
			sender.global_position, trajectory,
			damage
		);
		body.queue_attack(attack);
		sender.landed.emit(body);
	queue_free();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitbox = get_node("Hitbox");
	hitbox.collision_mask = mask;
	hitbox.body_entered.connect(_collide);
	homing_area = get_node("HomingArea");
	homing_area.collision_mask = mask;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta):
	position += trajectory * speed * delta;
