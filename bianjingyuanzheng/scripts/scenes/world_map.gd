extends Node2D

@export var move_speed: float = 200.0

func _ready() -> void:
	var p := PlayerData.get_instance()
	if p.conquered_regions.has("volcano"):
		$VolcanoEntrance/VolcanoSprite.modulate = Color.GOLD
		$VolcanoEntrance/VolcanoLabel.text = "火山地带 (已征服)"
	$VolcanoEntrance.body_entered.connect(_on_volcano_entered)

func _physics_process(delta: float) -> void:
	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	$PlayerCharacter.velocity = input * move_speed
	$PlayerCharacter.move_and_slide()

func _on_volcano_entered(_body: Node2D) -> void:
	PlayerData.get_instance().current_region_scene = "res://scenes/volcano_region.tscn"
	get_tree().change_scene_to_file("res://scenes/volcano_region.tscn")
