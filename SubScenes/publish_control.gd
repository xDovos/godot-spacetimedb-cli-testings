extends Control

@onready var server_line_edit: LineEdit = $VBoxContainer/GridContainer/ServerLineEdit
@onready var module_name_line_edit: LineEdit = $VBoxContainer/GridContainer/ModuleNameLineEdit
@onready var module_path_line_edit: LineEdit = $VBoxContainer/GridContainer/ModulePathLineEdit
@onready var client_path_line_edit: LineEdit = $VBoxContainer/GridContainer/ClientPathLineEdit
@onready var clear_data_toggle: TextureButton = $VBoxContainer/GridContainer/ClearDataToggle
@onready var publish_button: Button = $VBoxContainer/PublishButton
@onready var create_module_bindings_button: Button = $VBoxContainer/CreateModuleBindingsButton

@onready var cmd_output_label: RichTextLabel = $VBoxContainer/PanelContainer/MarginContainer/CmdOutputLabel
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog
@onready var client_language_option_button: OptionButton = $VBoxContainer/GridContainer/ClientLanguageOptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var cmdPid :Dictionary
var IO: FileAccess
var IOError: FileAccess
var createdBindings : bool = false

func set_disable_buttons(yes : bool = false):
	publish_button.disabled = yes
	create_module_bindings_button.disabled = yes


func _process(delta: float) -> void:
	if(cmdPid):
		if(cmdPid.has("pid")):
			var exitcode = OS.get_process_exit_code(cmdPid["pid"])
			if(exitcode != -1):
				print(error_string(exitcode))
				cmd_output_label.append_text("cmd exited with: " + error_string(exitcode))
				IO = null
				IOError = null
				cmdPid.clear()
				set_disable_buttons(false)
				if (createdBindings):
					update_module_bindings()
	if(IO):
		if(IO.is_open()):
			if(IO.get_length() > 0):
				print("getting IO length")
				var buffer:PackedByteArray = IO.get_buffer(IO.get_length())
				var text : String = buffer.get_string_from_utf8()
				cmd_output_label.append_text(text + "\n")
				if(text.contains("y/N")):
					if(not confirmation_dialog.visible):
						confirmation_dialog.popup()
	if(IOError):
		if(IOError.is_open()):
			if(IOError.get_length()>0):
				var buffer:PackedByteArray = IOError.get_buffer(IOError.get_length())
				var text : String = buffer.get_string_from_utf8()
				cmd_output_label.append_text(text + "\n")

func _on_publish_button_pressed() -> void:
	var command : Array = ["/C", "spacetime", "publish"]
	var moduleName : String = module_name_line_edit.text
	var modulePath : String = module_path_line_edit.text
	var serverName : String = server_line_edit.text 
	var clearData : bool = clear_data_toggle.button_pressed
	if not serverName.is_empty():
		if(serverName != "Local"):
			command.append("-s")
			command.append(serverName)
	if not modulePath.is_empty():
		command.append("-p")
		command.append(modulePath)
	if clearData:
		command.append("-c")
	if not moduleName.is_empty():
		command.append(moduleName)
	else:
		cmd_output_label.append_text("module name empty")
		return;
	set_disable_buttons(true)
	print(command)
	#command.clear()
	cmd_output_label.clear()
	cmd_output_label.append_text("running cmd: " + str(command))
	#command.append_array(["/C","spacetime", "logs", "servertest"])
	cmdPid = OS.execute_with_pipe("CMD.exe", command, false)
	IO = cmdPid["stdio"]
	IOError = cmdPid["stderr"]
	if(IOError.get_length()>0):
		var text = IO.get_line()
		cmd_output_label.append_text(text + "\n")

func _on_confirmation_dialog_confirmed() -> void:
	if(IO.is_open()):
		IO.store_line("y\n") # Replace with function body.
		cmd_output_label.add_text("y\n")

func _on_confirmation_dialog_canceled() -> void:
	if(IO.is_open()):
		IO.store_line("N\n") # Replace with function body.
		cmd_output_label.add_text("N\n")


func _on_create_module_bindings_button_pressed() -> void:
	var command : Array = ["/C", "spacetime", "generate", "-y"]
	var language = client_language_option_button.get_item_text(client_language_option_button.get_selected_id())
	var modulePath : String = module_path_line_edit.text
	var clientBindingsPath : String = client_path_line_edit.text
	if language.is_empty():
		return
	command.append("--lang")
	command.append(language)
	if clientBindingsPath.is_empty():
		return
	command.append("--out-dir")
	command.append(clientBindingsPath)
	if modulePath.is_empty():
		return
	command.append("--project-path")
	command.append(modulePath)
	print(command)
	#command.clear()
	set_disable_buttons(true)
	cmd_output_label.clear()
	cmd_output_label.append_text("running cmd: " + str(command))
	#command.append_array(["/C","spacetime", "logs", "servertest"])
	cmdPid = OS.execute_with_pipe("CMD.exe", command, false)
	IO = cmdPid["stdio"]
	IOError = cmdPid["stderr"]
	if(IOError.get_length()>0):
		var text = IO.get_line()
		cmd_output_label.append_text(text + "\n")
	createdBindings = true
	

func update_module_bindings():
	createdBindings = false
	print("\nAdding godot bindings...");
	var module_bindings_folder = client_path_line_edit.text
	for file_name in DirAccess.open(module_bindings_folder + "/Types").get_files():
		if file_name.substr(len(file_name)-3, 3) == ".cs":
			cmd_output_label.append_text("Updating "+ file_name + "\n")
			var spacetime_type_name = file_name.substr(0, len(file_name)-5);
			var file = FileAccess.open(module_bindings_folder + "/Types/"+file_name, FileAccess.READ);
			var content = file.get_as_text();
			if(content.contains("using Godot;")):
				continue
			file = FileAccess.open(module_bindings_folder + "/Types/"+file_name, FileAccess.WRITE);
#			Adding the import
			content = insert_at_pattern(content, "using System.Runtime.Serialization;", "\nusing Godot;");
#			Adding the GodotObject extension class
			content = insert_at_pattern(content, "class "+ spacetime_type_name, ": RefCounted");
			file.store_string(content)

func insert_str(content: String, start_idx: int, value: String) -> String:
	var new_content = content.substr(0, start_idx) + value + content.substr(start_idx, len(content)-start_idx);
	return new_content

func insert_at_pattern(content: String, pattern: String, value: String) -> String:
	var index = content.find(pattern)
	var new_content = content;
	if index > 0:
		var start_idx = index + len(pattern)
		new_content = insert_str(content, start_idx, value);
	return new_content
