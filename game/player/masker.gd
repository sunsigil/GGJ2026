extends Node2D

var body: Node2D;
var mask: AnimatedSprite2D;

@export
var radius: float = 150;
@export
var delay: float = 0.1;

enum MaskType {
	PLAIN,
	DASH,
	SHOOT,
	SPLASH,
	NONE,
};
enum DangerLevel {
	SECURE,
	INSECURE,
	LOST
};
var mask_collection: Array[MaskType] = [MaskType.PLAIN];
var mask_idx: int;
var mask_danger: DangerLevel = DangerLevel.SECURE;

func unlock(_mask: MaskType):
	if not _mask in mask_collection:
		mask_collection.append(_mask);

func is_unlocked(_mask: MaskType):
	return _mask in mask_collection;

func get_mask():
	if mask_danger == DangerLevel.LOST:
		return MaskType.NONE;
	return mask_collection[mask_idx % len(mask_collection)];

func destabilize():
	match mask_danger:
		DangerLevel.SECURE:
			mask_danger = DangerLevel.INSECURE;
			mask.toggle_flash(true);
		DangerLevel.INSECURE:
			mask_danger = DangerLevel.LOST;
			mask.change(get_mask());
func stabilize():
	match mask_danger:
		DangerLevel.LOST:
			mask_danger = DangerLevel.INSECURE;
			mask.change(get_mask());
		DangerLevel.INSECURE:
			mask_danger = DangerLevel.SECURE;
			mask.toggle_flash(false);

func cycle():
	if mask_danger == DangerLevel.LOST:
		return;
	mask_idx = (mask_idx+1) % len(mask_collection);
	mask.change(get_mask());

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
	mask = get_node("Mask");
	swing(0);
	
