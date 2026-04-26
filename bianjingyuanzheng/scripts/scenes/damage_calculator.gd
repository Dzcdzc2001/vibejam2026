class_name DamageCalculator
extends RefCounted

static func calc_player_damage(weapon: WeaponData, creativity: int, monster_def: int) -> int:
    var weapon_atk: float = (weapon.base_atk_min + weapon.base_atk_max) / 2.0 if weapon else 50.0
    var weapon_mult: float = 1.0
    if weapon:
        weapon_mult = 1.0 + (weapon.level - 1) * 0.05 + weapon.element_bonus - 1.0
    var skill_mult: float = 1.0
    var raw := (weapon_atk * weapon_mult + creativity * skill_mult * 10.0)
    return max(int(raw - monster_def), 1)

static func calc_enemy_damage(base_atk: int, defense: int, is_defending: bool) -> int:
    var raw := base_atk - defense
    if is_defending: raw = int(raw * 0.5)
    return max(raw, 1)

static func calc_counter_damage(base_atk: int, difficulty: int) -> int:
    var ratio := [0.3, 0.6, 1.0][clampi(difficulty - 1, 0, 2)]
    return int(base_atk * ratio * 1.5)
