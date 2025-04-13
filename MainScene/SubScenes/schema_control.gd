extends Control

@onready var rich_text_label: RichTextLabel = $VBoxContainer/PanelContainer/MarginContainer/RichTextLabel
@onready var get_schema_button: Button = $VBoxContainer/GetSchemaButton
@onready var module_name_line_edit: LineEdit = $VBoxContainer/GridContainer/ModuleNameLineEdit
@onready var server_line_edit: LineEdit = $VBoxContainer/GridContainer/ServerLineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_get_schema_button_pressed() -> void:
	rich_text_label.clear()
	var command = ["/C","spacetime","describe", "--json"]
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
	var rawtext :String = ""
	print(output.size())
	for line: String in output:
		rawtext += line
	rawtext = rawtext.replace("WARNING: This command is UNSTABLE and subject to breaking changes.\n\n", "")
	rich_text_label.append_text(rawtext)
	#var json = JSON.new()
	#var error = json.parse(rawtext)
	#if error == OK:
		#var data_received = json.data
		#rich_text_label.append_text(JSON.stringify(data_received["typespace"]))
		#generate_table(data_received)
		#
	#else:
		#print("JSON Parse Error: ", json.get_error_message(), "at line ", json.get_error_line())
	#
#
#func generate_table(data :Dictionary):
	#if(data.has("typespace")):
		#var temp : SchemaTypespace = SchemaTypespace.new()
		#temp.types = data["typespace"]["types"]
		#ResourceSaver.save(temp,"res://ParsedSchema/Typespace/typespace.tres")
	#if(data.has("tables")):
		#for table in data["tables"]:
			#var temp :SchemaTable = SchemaTable.new()
			#for key in table:
				#temp[key] = table[key]
			#ResourceSaver.save(temp,"res://ParsedSchema/Tables/"+ temp.name + ".tres")
	#if(data.has("reducers")):
		#for reducer in data["reducers"]:
			#var temp :SchemaReducer = SchemaReducer.new()
			#for key in reducer:
				#temp[key] = reducer[key]
			#ResourceSaver.save(temp,"res://ParsedSchema/Reducers/"+ temp.name + ".tres")
	#if(data.has("types")):
		#for type in data["types"]:
			#var temp :SchemaType = SchemaType.new()
			#for key in type:
				#temp[key] = type[key]
			#ResourceSaver.save(temp,"res://ParsedSchema/Types/"+ temp.name["name"] + ".tres")
		#
		
		
		
		
