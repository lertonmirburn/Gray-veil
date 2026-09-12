extends ParallaxBackground
class_name FogController
@onready var fog_content: ParallaxLayer = $ParallaxLayer
func _ready() -> void:
	visible = false
	if fog_content:
		fog_content.visible = false

func set_fog_active(active: bool) -> void:
	visible = active
	if fog_content:
		fog_content.visible = active
