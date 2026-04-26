class_name QTEQuestionPool
extends Resource

@export var questions: Array[QTEQuestion] = []

class_name QTEQuestion
extends Resource

@export var id: int = 0
@export var category: String = ""
@export var difficulty: int = 1
@export var question: String = ""
@export var options: Array[String] = []
@export var correct_index: int = 0
