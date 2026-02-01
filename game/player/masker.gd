extends Node2D

var body: Node2D;

@export
var masks: Array[Resource];
@export
var radius: float = 150;
@export
var delay: float = 0.1;
var prop: Node2D;

enum MaskType {
	NONE,
	DASH,
	SHOOT,
	SPLASH,
	COUNT
};
var mask_collection = [];
var mask_idx: int;
var mask_danger: int;

signal mask_endangered;
signal mask_restored;
signal mask_lost;

func unlock(mask: MaskType):
	if not mask in mask_collection:
		mask_collection.append(mask);

func is_unlocked(mask: MaskType):
	return mask in mask_collection;

func cycle():
	if mask_collection.is_empty():
		mask_idx = 0;
	else:
		mask_idx = (mask_idx+1) % len(mask_collection);

func destabilize():
	mask_danger = clamp(mask_danger+1, 0, 2);
	if mask_danger == 1:
		mask_endangered.emit();
	if mask_danger == 2:
		mask_lost.emit();

func stabilize():
	mask_danger = clamp(mask_danger-1, 0, 2);
	if mask_danger == 0:
		mask_restored.emit();

func get_mask():
	if mask_collection.is_empty() or mask_danger == 2:
		return MaskType.NONE;
	return mask_collection[mask_idx % len(mask_collection)];
func is_mask_stable():
	return mask_danger == 0;

func swing(delta):
	var arm = Vector2.UP.rotated(global_rotation) * radius;
	global_position = body.global_position + arm;
	var leg = get_global_mouse_position() - body.global_position;
	leg = leg.normalized() * radius;
	var arc = arm.angle_to(leg);
	global_rotation += arc * delta / delay;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body = get_parent();
	prop = get_node("Prop");
	swing(0);
	
