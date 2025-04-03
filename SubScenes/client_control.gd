extends Control

@onready var spacetime_client_tool: Control = $SpacetimeClient
@onready var module_path_line_edit: LineEdit = $VBoxContainer/GridContainer/ModulePathLineEdit
@onready var client_bindings_line_edit: LineEdit = $VBoxContainer/GridContainer/ClientBindingsLineEdit
@onready var st_client_path_line_edit: LineEdit = $VBoxContainer/GridContainer/StClientPathLineEdit
@onready var rich_text_label: RichTextLabel = $VBoxContainer/PanelContainer/MarginContainer/RichTextLabel
var clientTemplatePath : String = "res://Templates/ClientTemplate.txt"
var godotTypesTemplatePath : String = "res://Templates/GodotTypeTemplate.txt"


func _on_create_button_pressed() -> void:
	update_module_bindings() # Replace with function body.
	#spacetime_client_tool.upate_spacetime_client()
	CreateGodotType()

func update_module_bindings():
	rich_text_label.clear()
	rich_text_label.append_text("Creating module bindings...\n")
	var server_path = module_path_line_edit.text
	var bindings_path = client_bindings_line_edit.text
	var output = []
	var exite_code = OS.execute("spacetime", ["generate", "-y", "--lang", "csharp", "-p", server_path, "-o", bindings_path], output, true)
	for out in output:
		rich_text_label.append_text(out + "\n")
	rich_text_label.append_text("Adding godot to bindings...\n");
	for file_name in DirAccess.open(bindings_path+"/Types").get_files():
		if file_name.substr(len(file_name)-3, 3) == ".cs":
			print("Updating "+ file_name)
			var spacetime_type_name = file_name.substr(0, len(file_name)-5);
			var file = FileAccess.open(bindings_path+"/Types/"+file_name, FileAccess.READ);
			var content = file.get_as_text();
			file = FileAccess.open(bindings_path+"/Types/"+file_name, FileAccess.WRITE);
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

func CreateGodotType():
	rich_text_label.append_text("Creating Godot Types...\n")
	var bindings_path = client_bindings_line_edit.text
	var file = FileAccess.open(godotTypesTemplatePath, FileAccess.READ)
	var typeTemplate: String = file.get_as_text()
	file.close()
	for file_name in DirAccess.open(bindings_path+"/Types").get_files():
		var newTypeContent = typeTemplate
		if file_name.get_extension() != "cs":
			continue
		var stdbFile = FileAccess.open(bindings_path+"/Types/"+ file_name,FileAccess.READ)
		var stdbContent = stdbFile.get_as_text()
		var typeNameStart : int = stdbContent.find("partial class ", 0)
		var typeNameEnd :int = stdbContent.find(":", typeNameStart)
		var typeName : String = stdbContent.substr(typeNameStart + 14, typeNameEnd - typeNameStart - 14 )
		newTypeContent = newTypeContent.replace("//TypeName", typeName)
		var rawstdbParameters : Array = Array(stdbContent.get_slice("{", 2).split("\n", false))
		rawstdbParameters = rawstdbParameters.filter(func(line: String): return line.contains("public") )
		rawstdbParameters.pop_back()
		var stdbParams: Array = []
		for line in rawstdbParameters:
			if(line.contains("DataMember")):
				continue
			var newLine = line.replace("SpacetimeDB", "Godot") \
							.replace("SpacetimeDB", "Godot") \
							.replace("SpacetimeDB", "Godot") \
							.replace("public ", "") \
							.replace(";", "") \
							.replace("        ", "")
							
			#newLine = insert_at_pattern(newLine, "List<", "Godot." ) # needs to only apply on stdb types.
			if(newLine.is_empty()):
				continue
			stdbParams.append(newLine)
		prints(typeName, stdbParams)
		for param :String in stdbParams:
			var paramName = Array(param.split(" ",false))[-1]
			newTypeContent = insert_at_pattern(newTypeContent, "//Exports\n", "		[Export]\n		public " + param + ";\n")
			newTypeContent = insert_at_pattern(newTypeContent, "//Constructor\n", "		this."+paramName + " = row."+ paramName + ";\n")
		var newFile = FileAccess.open(bindings_path+"/GDTypes/"+typeName+".cs",FileAccess.WRITE)
		newFile.store_string(newTypeContent)
		var error = newFile.get_error()
		if(error != OK):
			prints(typeName, error_string(error))
			rich_text_label.append_text("Failed to create: " + typeName + ".cs with error: "+ error_string(error))
		
