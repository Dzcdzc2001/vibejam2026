extends Node2D

@export var move_speed: float = 400.0

func _ready() -> void:
	var p := PlayerData.get_instance()
	if p.conquered_regions.has("volcano"):
		$VolcanoEntrance/VolcanoSprite.modulate = Color.GOLD
		$VolcanoEntrance/VolcanoLabel.text = "火山地带 (已征服)"
	$VolcanoEntrance.body_entered.connect(_on_volcano_entered)
	$HUD/BackToHubButton.pressed.connect(_on_back_to_hub_pressed)

func _physics_process(delta: float) -> void:
	var input := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	$PlayerCharacter.velocity = input * move_speed
	$PlayerCharacter.move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_B:
		_return_to_hub()

func _on_back_to_hub_pressed() -> void:
	_return_to_hub()

func _return_to_hub() -> void:
	get_tree().change_scene_to_file("res://scenes/hub_city.tscn")

func _on_volcano_entered(_body: Node2D) -> void:
	PlayerData.get_instance().current_region_scene = "res://scenes/volcano_region.tscn"
	get_tree().change_scene_to_file("res://scenes/volcano_region.tscn")
