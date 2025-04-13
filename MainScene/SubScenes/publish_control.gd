extends Control

@onready var server_line_edit: LineEdit = $VBoxContainer/GridContainer/ServerLineEdit
@onready var module_name_line_edit: LineEdit = $VBoxContainer/GridContainer/ModuleNameLineEdit
@onready var module_path_line_edit: LineEdit = $VBoxContainer/GridContainer/ModulePathLineEdit
@onready var clear_data_toggle: TextureButton = $VBoxContainer/GridContainer/ClearDataToggle
@onready var publish_button: Button = $VBoxContainer/PublishButton

@onready var cmd_output_label: RichTextLabel = $VBoxContainer/PanelContainer/MarginContainer/CmdOutputLabel
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var cmdPid :Dictionary
var IO: FileAccess
var IOError: FileAccess
var createdBindings : bool = false

func set_disable_buttons(yes : bool = false):
	publish_button.disabled = yes
	


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
