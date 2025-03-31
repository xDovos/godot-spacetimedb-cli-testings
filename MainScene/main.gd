extends Control

@onready var logs_control: Control = $HBoxContainer/MarginContainer2/LogsControl
@onready var publish_control: Control = $HBoxContainer/MarginContainer2/PublishControl
@onready var schema_control: Control = $HBoxContainer/MarginContainer2/SchemaControl

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_logs_button_toggled(toggled_on: bool) -> void:
	logs_control.visible = toggled_on


func _on_sql_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.


func _on_publish_button_toggled(toggled_on: bool) -> void:
	publish_control.visible = toggled_on


func _on_reducers_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.


func _on_shema_button_toggled(toggled_on: bool) -> void:
	schema_control.visible = toggled_on # Replace with function body.
