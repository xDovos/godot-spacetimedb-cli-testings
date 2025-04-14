@tool
extends CheckBox


@export_tool_button("Reset Client") var reset = reset_client
const AUTOLOAD_TEMPLATE = "res://Templates/SpacetimeClientAutoloadTemplate.txt"
const CLIENT_TEMPLATE = "res://Templates/EmtyBaseSpacetimeClientTemplate.txt"
const IDENTITY = "res://Templates/BaseTypes/Identity.txt"
const SCHEDULE_AT = "res://Templates/BaseTypes/ScheduleAt.txt"
const TIME_DURATION = "res://Templates/BaseTypes/TimeDuration.txt"
const TIMESTAMP = "res://Templates/BaseTypes/Timestamp.txt"
@onready var client_bindings_line_edit: LineEdit = $"../ClientBindingsLineEdit"
@onready var st_client_path_line_edit: LineEdit = $"../StClientPathLineEdit"
@onready var rich_text_label: RichTextLabel = $"../../PanelContainer/MarginContainer/RichTextLabel"

func reset_client() -> bool:
	var bindingsPath = client_bindings_line_edit.text
	var autoload_path = st_client_path_line_edit.text
	if bindingsPath.is_empty():
		rich_text_label.append_text("bindings path empty.")
		return false
	if autoload_path.is_empty():
		rich_text_label.append_text("autoload path empty.")
		return false
	
	var err = DirAccess.dir_exists_absolute(bindingsPath)
	if not err:
		rich_text_label.append_text(bindingsPath +" failed with: " + error_string(err))
		return false
	err = OS.move_to_trash(bindingsPath)
	print(error_string(err))
	DirAccess.make_dir_absolute(bindingsPath)
	DirAccess.make_dir_absolute(bindingsPath + "/GDTypes")
	DirAccess.make_dir_absolute(bindingsPath + "/GDTypes/BaseTypes")
	
	copyTemplate(IDENTITY, bindingsPath + "/GDTypes/BaseTypes/", "Identity.cs" )
	copyTemplate(SCHEDULE_AT, bindingsPath + "/GDTypes/BaseTypes/", "ScheduleAt.cs" )
	copyTemplate(TIME_DURATION, bindingsPath + "/GDTypes/BaseTypes/", "TimeDuration.cs" )
	copyTemplate(TIMESTAMP, bindingsPath + "/GDTypes/BaseTypes/", "Timestamp.cs" )
	copyTemplate(CLIENT_TEMPLATE, bindingsPath + "/" , "BaseSpacetimeClient.cs" )
	copyTemplate(AUTOLOAD_TEMPLATE, autoload_path , "" )
	print("resetted client")
	return true
	

func copyTemplate(templatePath :String, ToFolder: String, fileName : String):
	var file = FileAccess.open(templatePath, FileAccess.READ)
	var filetext = file.get_buffer(file.get_length()-1)
	file.close()
	file = FileAccess.open(ToFolder + fileName, FileAccess.WRITE)
	file.store_buffer(filetext)
	file.close()
