extends Control

@onready var rich_text_label: RichTextLabel = $VBoxContainer2/Panel/MarginContainer/RichTextLabel
@onready var module_name_line_edit: LineEdit = $VBoxContainer2/GridContainer/ModuleNameLineEdit
@onready var server_line_edit: LineEdit = $VBoxContainer2/GridContainer/ServerLineEdit


func _on_print_logs_pressed() -> void:
	rich_text_label.clear()
	var command = ["/C","spacetime","logs"]
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
	var output = []
	OS.execute("CMD.exe", command, output,true) # Replace with function body.
	var text :String = ""
	for line in output:
		text += line
	rich_text_label.add_text(text) # Replace with function body.
