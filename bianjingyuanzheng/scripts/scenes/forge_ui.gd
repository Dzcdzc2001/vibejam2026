extends Control

func _ready() -> void:
	var weapons := [
		load("res://resources/weapons/obsidian_blade.tres") as WeaponData,
		load("res://resources/weapons/fire_bow.tres") as WeaponData,
		load("res://resources/weapons/volcano_staff.tres") as WeaponData,
		load("res://resources/weapons/magma_shield.tres") as WeaponData
	]
	for wp in weapons:
		if wp == null:
			continue
		var btn := Button.new()
		btn.text = "%s (ATK %d-%d)" % [wp.display_name, wp.base_atk_min, wp.base_atk_max]
		btn.pressed.connect(_forge_weapon.bind(wp))
		$VBoxContainer.add_child(btn)

	var close_btn := Button.new()
	close_btn.text = "返回主城"
	close_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/hub_city.tscn"))
	$VBoxContainer.add_child(close_btn)

func _forge_weapon(weapon: WeaponData) -> void:
	var p := PlayerData.get_instance()
	p.equipped_weapon = weapon
	EventBus.weapon_forged.emit(weapon.weapon_id)
	print("锻造成功: %s" % weapon.display_name)
