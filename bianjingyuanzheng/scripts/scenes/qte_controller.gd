class_name QteController
extends Node

var question_pool: QTEQuestionPool = null
var current_question: QTEQuestion = null
var time_remaining: float = 5.0
var is_active: bool = false
var used_questions: Array[int] = []
var _shuffled_options: Array[String] = []

signal qte_result(success: bool, value: float)

func _ready() -> void:
    question_pool = load("res://resources/qte/qte_question_pool.tres")

func start_qte(difficulty_min: int, difficulty_max: int) -> void:
    if question_pool == null or question_pool.questions.is_empty():
        qte_result.emit(false, 0.0)
        return

    var candidates: Array[QTEQuestion] = []
    for q in question_pool.questions:
        if q.difficulty >= difficulty_min and q.difficulty <= difficulty_max and not used_questions.has(q.id):
            candidates.append(q)

    if candidates.is_empty():
        used_questions.clear()
        for q in question_pool.questions:
            if q.difficulty >= difficulty_min and q.difficulty <= difficulty_max:
                candidates.append(q)

    if candidates.is_empty():
        qte_result.emit(false, 0.0)
        return

    current_question = candidates[randi() % candidates.size()]
    used_questions.append(current_question.id)
    _shuffled_options = current_question.options.duplicate()
    _shuffled_options.shuffle()
    time_remaining = 5.0
    is_active = true
    EventBus.qte_triggered.emit(current_question.id, current_question.difficulty)

func process_qte(delta: float) -> void:
    if not is_active: return
    time_remaining -= delta
    if time_remaining <= 0:
        _on_timeout()

func get_shuffled_options() -> Array:
    return _shuffled_options

func submit_answer(selected_index: int) -> void:
    if not is_active: return
    is_active = false
    var correct_text := current_question.options[current_question.correct_index]
    if selected_index < _shuffled_options.size() and _shuffled_options[selected_index] == correct_text:
        var counter_dmg := DamageCalculator.calc_counter_damage(50, current_question.difficulty)
        EventBus.qte_success.emit(counter_dmg)
        qte_result.emit(true, counter_dmg)
    else:
        var incoming := DamageCalculator.calc_enemy_damage(80, 10, false) * float(current_question.difficulty)
        EventBus.qte_failed.emit(incoming)
        qte_result.emit(false, incoming)

func _on_timeout() -> void:
    is_active = false
    var incoming := DamageCalculator.calc_enemy_damage(80, 10, false) * float(current_question.difficulty if current_question else 1)
    EventBus.qte_failed.emit(incoming)
    qte_result.emit(false, incoming)
