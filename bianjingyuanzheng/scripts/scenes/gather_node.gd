class_name GatherNode
extends Area2D

@export var material_id: String = "obsidian"
@export var min_count: int = 1
@export var max_count: int = 3
@export var cooldown_seconds: float = 120.0

var _on_cooldown: bool = false

func _ready() -> void:
	var label := Label.new()
	label.name = "Prompt"
	label.text = "F 采集"
	label.position = Vector2(-20, -20)
	add_child(label)
	label.hide()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "PlayerCharacter" and not _on_cooldown:
		$Prompt.show()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "PlayerCharacter":
		$Prompt.hide()

func _input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and event.keycode == KEY_F):
		return
	if _on_cooldown:
		return
	var bodies := get_overlapping_bodies()
	var player_nearby := false
	for b in bodies:
		if b.name == "PlayerCharacter":
			player_nearby = true
			break
	if not player_nearby:
		return

	var count := randi_range(min_count, max_count)
	PlayerData.get_instance().add_item(material_id, count)
	print("采集: %s x%d" % [material_id, count])
	_on_cooldown = true
	$Prompt.text = "冷却中..."
	await get_tree().create_timer(cooldown_seconds).timeout
	_on_cooldown = false
	$Prompt.text = "F 采集"
