extends Control

@onready var spacetime_client_tool: Control = $SpacetimeClient
@onready var module_path_line_edit: LineEdit = $VBoxContainer/GridContainer/ModulePathLineEdit
@onready var client_bindings_line_edit: LineEdit = $VBoxContainer/GridContainer/ClientBindingsLineEdit
@onready var st_client_path_line_edit: LineEdit = $VBoxContainer/GridContainer/StClientPathLineEdit
@onready var rich_text_label: RichTextLabel = $VBoxContainer/PanelContainer/MarginContainer/RichTextLabel
var clientTemplatePath : String = "res://Templates/ClientTemplate.txt"
var godotTypesTemplatePath : String = "res://Templates/GodotTypeTemplate.txt"
const csharp_data_types: Array[String] = [
	"bool",
	"byte",
	"sbyte",
	"char",
	"decimal",
	"double",
	"float",
	"int",
	"uint",
	"nint",
	"nuint",
	"long",
	"ulong",
	"short",
	"ushort",
	"string"
]

func _on_create_button_pressed() -> void:
	#update_module_bindings() # Replace with function body.
	CreateGodotTypes()
	#upate_spacetime_client()
	


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

func CreateGodotTypes():
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
							.replace("public ", "") \
							.replace(";", "") \
							.replace("        ", "")
							
			#newLine = insert_at_pattern(newLine, "List<", "Godot." ) # needs to only apply on stdb types.
			if(newLine.is_empty()):
				continue
			stdbParams.append(newLine)
		stdbParams.reverse()
		prints(typeName, stdbParams)
		for param :String in stdbParams:
			var paramString = Array(param.split(" ",false))
			var paramName = paramString[-1]
			var paramType = paramString[-2]
			print(paramType)
			newTypeContent = insert_at_pattern(newTypeContent, "//Exports\n", exportString(paramType, paramName))
			newTypeContent = insert_at_pattern(newTypeContent, "//Constructor\n", constructorString(paramType, paramName))
			newTypeContent = insert_at_pattern(newTypeContent, "//ToStdb\n", tostdbString(paramType, paramName))
		var newFile = FileAccess.open(bindings_path+"/GDTypes/"+typeName+".cs",FileAccess.WRITE)
		newFile.store_string(newTypeContent)
		var error = newFile.get_error()
		if(error != OK):
			prints(typeName, error_string(error))
			rich_text_label.append_text("Failed to create: " + typeName + ".cs with error: "+ error_string(error))
		

func exportString(paramType : String, paramName : String) -> String:
	var string : String = "		[Export]\n		public "
	if(paramType.contains("List<")):
		var paramTypeName = getSubstring(paramType, "List<", ">")
		if(not csharp_data_types.any(func(type): return paramType.contains(type))):
			
			string += "Godot.Collections.Array<Godot." + paramTypeName + "> " + paramName + " = new();\n"
		else:
			string += "Godot.Collections.Array<" + paramTypeName + "> " + paramName + " = new();\n"
	else:
		string += paramType + " " + paramName + ";\n"
	return string

func constructorString(paramType : String, paramName : String) -> String:
	var string : String = "			this." + paramName + " = "
	if (csharp_data_types.any(func(type): return paramType.contains(type))):
		string += "row."+paramName+";\n"
	elif(paramType.contains("List<")):
		var paramTypeName = getSubstring(paramType, "List<", ">")
		string = ""
		string += "			Godot.Collections.Array<Godot."+ paramTypeName + "> Godot" + paramName +" = new();\n"
		if csharp_data_types.any(func(type): return paramTypeName.contains(type)):
			string += "			row." + paramName + ".ForEach(x => {Godot" + paramName +".Add(x);});\n"
		else:
			string += "			row." + paramName + ".ForEach(x => {Godot" + paramName +".Add(new(x));});\n"
		string += "			this."+ paramName + " = Godot" + paramName + ";\n"
	else:
		string += "new(row."+paramName+");\n"
	return string
	

func tostdbString(paramType : String, paramName : String) -> String:
	var string : String = "			type." + paramName + " = "
	if (csharp_data_types.any(func(type): return paramType.contains(type))):
		string += "this." + paramName +";\n"
	elif(paramType.contains("List<")):
		string = ""
		string += "			" +insert_at_pattern(paramType, "List<", "SpacetimeDB.Types.") + " Stdb" + paramName +" = new();\n"
		if csharp_data_types.any(func(type): return paramType.contains(type)):
			string += "			this." + paramName + ".ToList().ForEach(x => { Stdb" + paramName + ".Add(x);});\n"
		else:
			string += "			this." + paramName + ".ToList().ForEach(x => { Stdb" + paramName + ".Add(x.ToStdb());});\n"
		string += "			type." + paramName + " = Stdb"+ paramName + ";\n"
	elif(paramType.contains("Godot.")):
		string += "this." + paramName + ".ToStdb();\n"
	return string

func getSubstring(text : String, patternStart : String, patternEnd : String):
	var Start : int = text.find(patternStart,0)
	var End : int = text.find(patternEnd, Start + 1)
	var string : String = text.substr(Start+ patternStart.length(), End - Start -patternStart.length())
	return string


func upate_spacetime_client():
	print("\nModifying the BaseSpacetimeClient...");
	rich_text_label.append_text("Creating Godot Types...\n")
	var bindings_path = client_bindings_line_edit.text
	var file = FileAccess.open(clientTemplatePath, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	content = insert_at_pattern(content, "HOST", " = ");
	content = insert_at_pattern(content, "MODULE", " = \"" + $Module.text+"\"");
#	Adding all the callbacks signals for each table
	for file_name in DirAccess.open(bindings_path+"/Tables").get_files():
		#print(file_name)
		if file_name.get_extension() == "cs":
			file = FileAccess.open(bindings_path+"/Tables/"+file_name, FileAccess.READ)
			if(file.get_error() != OK):
				print(error_string(file.get_error()))
			var text = file.get_as_text()
			file.close()
			#print(text)
			var tableNameStart : int = text.find('"', 0)
			var tableNameEnd : int = text.find('"', tableNameStart +1)
			prints(tableNameStart, tableNameEnd)
			var tableName :String = text.substr(tableNameStart+1, tableNameEnd-tableNameStart-1)
			print(tableName)
			var parametersStart : int = text.find("GetKey(",0)
			var parametersEnd : int = text.find("row)", parametersStart + 1)
			var parameterName : String = text.substr(parametersStart+ 7, parametersEnd - parametersStart -8)
			print(parameterName)
			
			content = insert_at_pattern(content, "// Insert Signals", "\n	[Signal]\n	public delegate void "+tableName+"InsertedEventHandler(Godot."+parameterName+" inserted_row);");
			content = insert_at_pattern(content, "// Update Signals", "\n	[Signal]\n	public delegate void "+tableName+"UpdatedEventHandler(Godot."+parameterName+" old_row, SpacetimeDB.Types."+parameterName+" new_row);");
			content = insert_at_pattern(content, "// Delete Signals", "\n	[Signal]\n	public delegate void "+tableName+"DeletedEventHandler(Godot."+parameterName+" deleted_row);");
			
#			Adding callbacks
			content = insert_at_pattern(content, "// Add Insert Callbacks", "\n		conn.Db."+tableName+".OnInsert += "+tableName+"_OnInsert;");
			content = insert_at_pattern(content, "// Add Update Callbacks", "\n		conn.Db."+tableName+".OnUpdate += "+tableName+"_OnUpdate;");
			content = insert_at_pattern(content, "// Add Delete Callbacks", "\n		conn.Db."+tableName+".OnDelete += "+tableName+"_OnDelete;");
			
#			Creating callbacks
			content = insert_at_pattern(content, "// Insert Callbacks", "\n	void "+tableName+"_OnInsert(EventContext ctx, SpacetimeDB.Types."+parameterName+" inserted_row){\n		EmitSignal(SignalName."+tableName+"Inserted, inserted_row);\n	}");
			content = insert_at_pattern(content, "// Update Callbacks", "\n	void "+tableName+"_OnUpdate(EventContext ctx, SpacetimeDB.Types."+parameterName+" old_row, SpacetimeDB.Types."+parameterName+" new_row){\n		EmitSignal(SignalName."+tableName+"Updated, old_row, new_row);\n	}");
			content = insert_at_pattern(content, "// Delete Callbacks", "\n	void "+tableName+"_OnDelete(EventContext ctx, SpacetimeDB.Types."+parameterName+" deleted_row){\n		EmitSignal(SignalName."+tableName+"Deleted, deleted_row);\n	}");
			
	#Adding the reducers
	var reducers_name = [];
	for file_name in DirAccess.open(bindings_path +"/Reducers").get_files():
		if file_name.get_extension() == "cs":
			var reducer_name = file_name.substr(0, len(file_name)-5);
			var reducer_file = FileAccess.open(bindings_path+"/Reducers/"+reducer_name+".g.cs", FileAccess.READ);
			var reducer_content = reducer_file.get_as_text();
			var pattern = "public void "+reducer_name+"(";
			var start_reducer_method_index = reducer_content.find(pattern);
			if start_reducer_method_index >= 0:
				reducers_name.append(reducer_name);
	
	for reducer_name in reducers_name:
		var reducer_file = FileAccess.open(bindings_path+"/Reducers/"+reducer_name+".g.cs", FileAccess.READ);
		var reducer_content = reducer_file.get_as_text();
		var pattern = "public void "+reducer_name+"(";
		var start_reducer_method_index = reducer_content.find(pattern) + len(pattern);
		var method_arguments = ""
		var char = 'SpacetimeDB.Types.';
		while char != ')':
			method_arguments += char;
			char = reducer_content[start_reducer_method_index]
			start_reducer_method_index += 1
		method_arguments = insert_at_pattern(method_arguments,", ", "SpacetimeDB.Types.")
		var var_names = method_arguments.split(" ")
		var call_arguments = ""
		for k in range(len(var_names)):
			if k % 2 == 1:
				call_arguments += var_names[k];
		content = insert_at_pattern(content, "// Reducers", "\n\n	public void "+reducer_name+"("+method_arguments+"){\n		if (conn == null){\n			return;\n		}\n		conn.Reducers."+reducer_name+"("+call_arguments+");\n	}");
		
#		Update the file with the new content
	file = FileAccess.open(st_client_path_line_edit.text, FileAccess.WRITE);
	file.store_string(content);
	print("finished client")
