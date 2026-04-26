extends Control

var turn_manager: TurnManager = TurnManager.new()
var skill_parser: SkillParser = SkillParser.new()
var qte_controller: QteController = QteController.new()
var revealer: PostBattleReveal = PostBattleReveal.new()
var monster_instance: Dictionary = {}

func _ready() -> void:
	var monster_data := BattleConfig.pending_monster
	if monster_data == null:
		get_tree().change_scene_to_file("res://scenes/hub_city.tscn")
		return

	monster_instance = BattleConfig.pending_monster_instance.duplicate()
	add_child(turn_manager)
	add_child(qte_controller)
	qte_controller.qte_result.connect(_on_qte_result)
	turn_manager.state_changed.connect(_on_state_changed)
	turn_manager.initialize(monster_data, monster_instance, PlayerData.get_instance())

	$MonsterInfo/NameLabel.text = monster_data.display_name
	$MonsterInfo/HPBar.max_value = monster_instance["current_hp"]
	$MonsterInfo/HPBar.value = monster_instance["current_hp"]
	$MonsterInfo/ChargeLabel.hide()

	$PlayerInfo/HPBar.max_value = PlayerData.get_instance().base_hp
	$PlayerInfo/HPBar.value = turn_manager.player_hp

	$PlayerInfo/AttackButton.pressed.connect(_on_attack)
	$PlayerInfo/DefendButton.pressed.connect(_on_defend)
	$PlayerInfo/FleeButton.pressed.connect(_on_flee)

	$QTEPanel.hide()
	$PostBattlePanel.hide()

	turn_manager.advance_to(TurnManager.BattleState.PLAYER_TURN)
	_enable_player_input(true)

func _on_state_changed(new_state: int) -> void:
	match new_state:
		TurnManager.BattleState.PLAYER_TURN:
			_enable_player_input(true)
			$MonsterInfo/ChargeLabel.hide()
		TurnManager.BattleState.ENEMY_CHARGE:
			$MonsterInfo/ChargeLabel.text = "蓄力中: %s" % turn_manager.charge_skill_pending.display_name
			$MonsterInfo/ChargeLabel.show()
			await get_tree().create_timer(0.5).timeout
			turn_manager.advance_to(TurnManager.BattleState.PLAYER_TURN)
		TurnManager.BattleState.QTE_ALERT:
			$PlayerInfo/StatusLabel.text = "!! 蓄力攻击即将释放 !!"
			await get_tree().create_timer(1.0).timeout
			turn_manager.advance_to(TurnManager.BattleState.QTE_ACTIVE)
		TurnManager.BattleState.QTE_ACTIVE:
			_start_qte()
		TurnManager.BattleState.POST_BATTLE:
			_show_post_battle()

func _on_attack() -> void:
	var input_text: String = $PlayerInfo/SkillInput.text
	if input_text.is_empty(): input_text = "斩击"
	var weapon_type := "sword"
	var wp := PlayerData.get_instance().equipped_weapon
	if wp:
		var types: Array[String] = ["sword", "bow", "staff", "shield"]
		weapon_type = types[wp.weapon_type]
	var creativity := skill_parser.parse_creativity(input_text, BattleConfig.from_region, weapon_type, turn_manager.monster_data.instant_skills[0].damage_type if turn_manager.monster_data.instant_skills.size() > 0 else "physical")
	EventBus.skill_parsed.emit(input_text, creativity)

	var damage := DamageCalculator.calc_player_damage(PlayerData.get_instance().equipped_weapon, creativity, monster_instance["current_def"])
	monster_instance["current_hp"] -= damage
	$MonsterInfo/HPBar.value = max(monster_instance["current_hp"], 0)
	$PlayerInfo/StatusLabel.text = "造成 %d 点伤害! (创意值: %d)" % [damage, creativity]
	await get_tree().create_timer(1.0).timeout
	_after_player_action()

func _on_defend() -> void:
	turn_manager.is_defending = true
	$PlayerInfo/StatusLabel.text = "进入防御姿态 (减伤50%)"
	await get_tree().create_timer(0.5).timeout
	_after_player_action()

func _on_flee() -> void:
	var flee_chance: float = 0.5
	if turn_manager.monster_data.monster_type == 1: flee_chance = 0.2
	elif turn_manager.monster_data.monster_type == 2:
		$PlayerInfo/StatusLabel.text = "BOSS战无法逃跑!"
		return
	if randf() < flee_chance:
		$PlayerInfo/StatusLabel.text = "逃跑成功!"
		await get_tree().create_timer(1.0).timeout
		BattleConfig.clear()
		get_tree().change_scene_to_file("res://scenes/volcano_region.tscn")
	else:
		$PlayerInfo/StatusLabel.text = "逃跑失败!"
		await get_tree().create_timer(0.5).timeout
		_after_player_action()

func _after_player_action() -> void:
	if monster_instance["current_hp"] <= 0:
		turn_manager.advance_to(TurnManager.BattleState.POST_BATTLE)
		return
	_enemy_act()

func _enemy_act() -> void:
	var ai := EnemyAI.new()
	var decision := ai.decide_action(turn_manager.monster_data, monster_instance["current_hp"], turn_manager.monster_data.base_hp, turn_manager.charge_skill_pending)

	match decision["action"]:
		"instant":
			var skill: SkillData = decision["skill"]
			var atk_val: int = monster_instance["current_atk"] + (skill.base_damage if skill else 0)
			var damage := DamageCalculator.calc_enemy_damage(atk_val, turn_manager.player_def, turn_manager.is_defending)
			turn_manager.player_hp -= damage
			$PlayerInfo/StatusLabel.text = "%s造成 %d 点伤害!" % [turn_manager.monster_data.display_name, damage]
		"charge":
			turn_manager.charge_skill_pending = decision["skill"]
			turn_manager.advance_to(TurnManager.BattleState.ENEMY_CHARGE)
			return
		"release_charge":
			var skill := turn_manager.charge_skill_pending
			turn_manager.charge_skill_pending = null
			if skill and skill.charge_turns >= 2:
				turn_manager.advance_to(TurnManager.BattleState.QTE_ALERT)
				return
			else:
				var atk_val: int = monster_instance["current_atk"] + (skill.base_damage * 2 if skill else 0)
				var damage := DamageCalculator.calc_enemy_damage(atk_val, turn_manager.player_def, turn_manager.is_defending)
				turn_manager.player_hp -= damage
				$PlayerInfo/StatusLabel.text = "%s释放蓄力攻击! 造成 %d 伤害!" % [turn_manager.monster_data.display_name, damage]

	$PlayerInfo/HPBar.value = turn_manager.player_hp
	turn_manager.is_defending = false
	await get_tree().create_timer(1.0).timeout
	if turn_manager.player_hp <= 0:
		EventBus.battle_lost.emit(turn_manager.monster_data.id)
		get_tree().change_scene_to_file("res://scenes/hub_city.tscn")
		return
	turn_manager.advance_to(TurnManager.BattleState.PLAYER_TURN)

func _start_qte() -> void:
	var diff_min: int = 1
	var diff_max: int = 2
	if turn_manager.charge_skill_pending:
		match turn_manager.charge_skill_pending.charge_turns:
			2: diff_max = 2
			3: diff_min = 2; diff_max = 3
	qte_controller.start_qte(diff_min, diff_max)
	if qte_controller.current_question == null:
		return
	$QTEPanel.show()
	$QTEPanel/QuestionLabel.text = qte_controller.current_question.question
	$QTEPanel/TimerBar.max_value = 5.0
	$QTEPanel/TimerBar.value = 5.0
	var shuffled := qte_controller.get_shuffled_options()
	for i in range(4):
		if i < shuffled.size():
			$QTEPanel/Options.get_child(i).text = "[%d] %s" % [i + 1, shuffled[i]]

func _process(delta: float) -> void:
	if qte_controller.is_active:
		qte_controller.process_qte(delta)
		$QTEPanel/TimerBar.value = qte_controller.time_remaining

func _input(event: InputEvent) -> void:
	if not qte_controller.is_active: return
	if event is InputEventKey and event.pressed:
		var key_map := {KEY_1: 0, KEY_2: 1, KEY_3: 2, KEY_4: 3}
		if event.keycode in key_map:
			qte_controller.submit_answer(key_map[event.keycode])

func _on_qte_result(success: bool, value: float) -> void:
	$QTEPanel.hide()
	if success:
		monster_instance["current_hp"] -= int(value)
		$MonsterInfo/HPBar.value = max(monster_instance["current_hp"], 0)
		$PlayerInfo/StatusLabel.text = "弹反成功! 反击 %d 伤害! 怪物眩晕!" % int(value)
		if monster_instance["current_hp"] <= 0:
			await get_tree().create_timer(1.0).timeout
			turn_manager.advance_to(TurnManager.BattleState.POST_BATTLE)
			return
		await get_tree().create_timer(1.0).timeout
		turn_manager.advance_to(TurnManager.BattleState.PLAYER_TURN)
	else:
		turn_manager.player_hp -= int(value)
		$PlayerInfo/HPBar.value = turn_manager.player_hp
		$PlayerInfo/StatusLabel.text = "弹反失败! 受到 %d 伤害!" % int(value)
		if turn_manager.player_hp <= 0:
			await get_tree().create_timer(1.0).timeout
			EventBus.battle_lost.emit(turn_manager.monster_data.id)
			get_tree().change_scene_to_file("res://scenes/hub_city.tscn")
			return
		await get_tree().create_timer(1.0).timeout
		turn_manager.advance_to(TurnManager.BattleState.PLAYER_TURN)

func _show_post_battle() -> void:
	EventBus.battle_won.emit(turn_manager.monster_data.id, turn_manager.monster_data.drop_table)
	var p := PlayerData.get_instance()
	p.add_exp(turn_manager.monster_data.exp_reward)
	p.unlock_bestiary(turn_manager.monster_data.extinct_species_id)

	for item_id in turn_manager.monster_data.drop_table:
		var entry: Dictionary = turn_manager.monster_data.drop_table[item_id]
		if randf() < entry.get("rate", 0.0):
			var count: int = randi_range(entry.get("count_min", 1), entry.get("count_max", 1))
			p.add_item(item_id, count)

	var data := revealer.get_reveal_data(turn_manager.monster_data)
	if data.is_empty():
		_return_from_battle()
		return

	$PostBattlePanel.show()
	$PostBattlePanel/NameLabel.text = "%s (%s)" % [data.get("common_name", ""), data.get("scientific_name", "")]
	$PostBattlePanel/ExtinctLabel.text = "灭绝于 %d 年" % data.get("extinct_year", 0)
	$PostBattlePanel/CauseLabel.text = "原因: %s" % data.get("extinct_cause", "")
	$PostBattlePanel/WarningLabel.text = data.get("warning_message", "")

	if data.get("monster_type", 0) >= 1:
		$PostBattlePanel/HabitatLabel.text = "栖息: %s" % data.get("habitat_detail", "")
		$PostBattlePanel/HabitatLabel.show()

	if data.get("monster_type", 0) == 2:
		p.conquer_region(BattleConfig.from_region)
		$PostBattlePanel/TimelineLabel.text = data.get("human_timeline", "")
		$PostBattlePanel/TimelineLabel.show()

	if data.get("monster_type", 0) == 0:
		await get_tree().create_timer(3.0).timeout
		if is_inside_tree():
			_return_from_battle()
	else:
		$PostBattlePanel/ContinueButton.pressed.connect(_return_from_battle)
		$PostBattlePanel/ContinueButton.show()

func _return_from_battle() -> void:
	BattleConfig.clear()
	var p := PlayerData.get_instance()
	var target := p.current_region_scene if not p.current_region_scene.is_empty() else "res://scenes/world_map.tscn"
	get_tree().change_scene_to_file(target)

func _enable_player_input(enabled: bool) -> void:
	$PlayerInfo/SkillInput.editable = enabled
	$PlayerInfo/AttackButton.disabled = not enabled
	$PlayerInfo/DefendButton.disabled = not enabled
	$PlayerInfo/FleeButton.disabled = not enabled
