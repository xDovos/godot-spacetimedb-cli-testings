extends Control

@onready var module_name_line_edit: LineEdit = $VBoxContainer/GridContainer/ModuleNameLineEdit
@onready var server_line_edit: LineEdit = $VBoxContainer/GridContainer/ServerLineEdit
@onready var sql_line_edit: LineEdit = $VBoxContainer/GridContainer/SQLLineEdit
@onready var rich_text_label: RichTextLabel = $VBoxContainer/PanelContainer/MarginContainer/RichTextLabel



func _on_button_pressed() -> void:
	rich_text_label.clear()
	var command = ["/C","spacetime","sql"]
	var moduleName = module_name_line_edit.text
	if(moduleName.is_empty()):
		rich_text_label.append_text("Module name emtpy")
		return
	command.append(moduleName)
	var serverName = server_line_edit.text
	if(serverName.is_empty()):
		rich_text_label.append_text("server name emtpy")
		return
	if(serverName != "Local"):
		command.append("-s")
		command.append(serverName)
	var sqlQuery = sql_line_edit.text
	if(sqlQuery.is_empty()):
		rich_text_label.append_text("query is emtpy")
		return
	command.append(sqlQuery)
	var output = []
	rich_text_label.append_text(str(command))
	OS.execute("CMD.exe", command, output,true) # Replace with function body.
	var text :String = ""
	for line in output:
		text += line
	rich_text_label.add_text(text) # Replace with function body.
 # Replace with function body.
