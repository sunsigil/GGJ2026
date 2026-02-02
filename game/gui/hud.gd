extends Node

@export
var plain_mask: Resource;
@export
var dash_mask: Resource;
@export
var shoot_mask: Resource;
@export
var splash_mask: Resource;

@export
var cooldown_bar: ColorRect;
@export
var mask_holder: TextureRect;
@export
var mask_img: TextureRect;
@export
var resurrect_img: TextureRect;

var player;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player == null:
		player = PlayerData.player;
		return;
		
	if player.living:
		resurrect_img.visible = false;
		mask_holder.visible = true;
		
		match player.masker.get_mask():
			Enums.MaskType.PLAIN:
				mask_img.texture = plain_mask;
			Enums.MaskType.DASH:
				mask_img.texture = dash_mask;
			Enums.MaskType.SHOOT:
				mask_img.texture = shoot_mask;
			Enums.MaskType.SPLASH:
				mask_img.texture = splash_mask;
		cooldown_bar.size.x = 1920 * player.get_universal_cooldown();
	else:
		resurrect_img.visible = true;
		mask_holder.visible = false;
