class_name TurnManager
extends Node

enum BattleState {
    INTRO, PLAYER_TURN, SKILL_PARSE, DAMAGE_CALC,
    CHECK_WIN, ENEMY_THINK, ENEMY_CHARGE,
    QTE_ALERT, QTE_ACTIVE, CHECK_LOSE, POST_BATTLE
}

var current_state: int = BattleState.INTRO
var monster_data: MonsterData = null
var monster_instance: Dictionary = {}
var player_hp: int = 0
var player_atk: int = 0
var player_def: int = 0
var is_defending: bool = false
var charge_skill_pending: SkillData = null
var charge_turns_remaining: int = 0

signal state_changed(new_state: int)

func initialize(monster: MonsterData, instance: Dictionary, player: PlayerData) -> void:
    monster_data = monster
    monster_instance = instance.duplicate()
    player_hp = player.base_hp
    player_atk = player.base_atk + (player.equipped_weapon.base_atk_min if player.equipped_weapon else 0)
    player_def = player.base_def
    charge_skill_pending = null
    charge_turns_remaining = 0
    current_state = BattleState.INTRO

func advance_to(state: int) -> void:
    current_state = state
    state_changed.emit(state)

func get_creativity_bonus() -> int:
    var p := PlayerData.get_instance()
    return p.parsing_power / 10 * 5
