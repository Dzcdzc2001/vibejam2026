extends Control

var extinct_db: ExtinctSpeciesDB = null

func _ready() -> void:
    extinct_db = load("res://resources/bestiary/extinct_species_db.tres")
    if extinct_db == null: return
    _build_list()

func _build_list() -> void:
    var p := PlayerData.get_instance()
    var title := Label.new()
    title.text = "灭绝动物图鉴 (%d/%d)" % [p.bestiary.size(), extinct_db.entries.size()]
    title.add_theme_font_size_override("font_size", 24)
    $VBoxContainer.add_child(title)

    var scroll := ScrollContainer.new()
    scroll.size = Vector2(700, 400)
    var grid := GridContainer.new()
    grid.columns = 3
    scroll.add_child(grid)

    for entry in extinct_db.entries:
        var card := Panel.new()
        var card_vbox := VBoxContainer.new()
        var name_label := Label.new()
        name_label.text = entry.common_name

        var status_label := Label.new()
        if p.bestiary.has(entry.species_id):
            status_label.text = "已解锁"
            status_label.modulate = Color.GREEN
            card.gui_input.connect(_on_card_clicked.bind(entry))
        else:
            status_label.text = "???"
            status_label.modulate = Color.GRAY

        card_vbox.add_child(name_label)
        card_vbox.add_child(status_label)
        card.add_child(card_vbox)
        grid.add_child(card)

    $VBoxContainer.add_child(scroll)

    var back_btn := Button.new()
    back_btn.text = "返回主城"
    back_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/hub_city.tscn"))
    $VBoxContainer.add_child(back_btn)

func _on_card_clicked(event: InputEvent, entry: ExtinctSpeciesEntry) -> void:
    if not (event is InputEventMouseButton and event.pressed): return
    _show_detail(entry)

func _show_detail(entry: ExtinctSpeciesEntry) -> void:
    for child in get_children():
        if child is Panel and child.name == "DetailPanel":
            child.queue_free()

    var detail := Panel.new()
    detail.name = "DetailPanel"
    detail.size = Vector2(500, 350)
    detail.position = Vector2(230, 100)
    var vbox := VBoxContainer.new()
    detail.add_child(vbox)

    for line in [
        "%s (%s)" % [entry.common_name, entry.scientific_name],
        "灭绝时间: %s (%s)" % [entry.extinct_year, entry.years_ago],
        "灭绝原因: %s" % entry.extinct_cause,
        entry.cause_detail,
        "栖息环境: %s" % entry.habitat,
        "食性: %s" % entry.diet
    ]:
        var lbl := Label.new(); lbl.text = line; vbox.add_child(lbl)

    var warning := Label.new()
    warning.text = entry.warning_message
    warning.add_theme_font_size_override("font_size", 16)
    warning.modulate = Color.RED
    vbox.add_child(warning)

    var close_btn := Button.new()
    close_btn.text = "关闭"
    close_btn.pressed.connect(detail.queue_free)
    vbox.add_child(close_btn)

    add_child(detail)
