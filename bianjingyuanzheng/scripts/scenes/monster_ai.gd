class_name MonsterAI
extends Area2D

enum State { WANDER, ALERT, CHASE, FLEE }

var monster_data: MonsterData = null
var state: int = State.WANDER
var _wander_timer: float = 0.0
var _wander_direction: Vector2 = Vector2.ZERO
var _move_speed: float = 50.0
var _chase_speed: float = 120.0
var spawn_origin: Vector2 = Vector2.ZERO

@export var alert_radius: float = 48.0
@export var chase_radius: float = 32.0
@export var wander_radius: float = 150.0

func _ready() -> void:
	spawn_origin = position
	_pick_new_wander_direction()

func _physics_process(delta: float) -> void:
	var player := _find_player()
	if player == null:
		state = State.WANDER
	else:
		var dist := position.distance_to(player.position)
		if dist < chase_radius:
			state = State.CHASE
		elif dist < alert_radius:
			state = State.ALERT
		else:
			state = State.WANDER

	match state:
		State.WANDER:
			_do_wander(delta)
		State.ALERT:
			pass
		State.CHASE:
			_do_chase(player, delta)

func _do_wander(delta: float) -> void:
	_wander_timer -= delta
	if _wander_timer <= 0:
		_pick_new_wander_direction()
	var new_pos := position + _wander_direction * _move_speed * delta
	if new_pos.distance_to(spawn_origin) <= wander_radius:
		position = new_pos
	else:
		_wander_direction = -_wander_direction

func _do_chase(player: Node2D, delta: float) -> void:
	var dir := position.direction_to(player.position)
	position += dir * _chase_speed * delta

func _pick_new_wander_direction() -> void:
	_wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	_wander_timer = randf_range(2.0, 4.0)

func _find_player() -> Node2D:
	var players := get_tree().get_nodes_in_group("player_character")
	if players.is_empty():
		return null
	return players[0]
