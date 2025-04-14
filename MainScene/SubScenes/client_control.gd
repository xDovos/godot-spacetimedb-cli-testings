extends Control


@onready var module_path_line_edit: LineEdit = $VBoxContainer/GridContainer/ModulePathLineEdit
@onready var client_bindings_line_edit: LineEdit = $VBoxContainer/GridContainer/ClientBindingsLineEdit
@onready var st_client_path_line_edit: LineEdit = $VBoxContainer/GridContainer/StClientPathLineEdit
@onready var rich_text_label: RichTextLabel = $VBoxContainer/PanelContainer/MarginContainer/RichTextLabel
@onready var server_line_edit: LineEdit = $VBoxContainer/GridContainer/ServerLineEdit
@onready var module_name_line_edit: LineEdit = $VBoxContainer/GridContainer/ModuleNameLineEdit
@onready var reset_check_box: CheckBox = $VBoxContainer/GridContainer/ResetCheckBox


var clientTemplatePath : String = "res://Templates/BaseSpacetimeClientTemplate.txt"
var godotTypesTemplatePath : String = "res://Templates/GodotTypeTemplate.txt"
const stdb_base_types : Array[String] = [
	"Identity",
	"Timestamp",
	"TimeDuration",
	"ScheduleAt"
]
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
	if reset_check_box.button_pressed:
		reset_check_box.reset_client()
	update_module_bindings() # Replace with function body.
	CreateGodotTypes()
	upate_spacetime_client()
	



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
			var newLine = line.replace("SpacetimeDB.", "") \
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
	elif csharp_data_types.any(func(type): return paramType.contains(type)):
		string += paramType + " " + paramName + ";\n"
	else:
		string += "Godot."+ paramType + " " + paramName + ";\n"
	return string

func constructorString(paramType : String, paramName : String) -> String:
	var string : String = "			this." + paramName + " = "
	if(paramType.contains("List<")):
		var paramTypeName = getSubstring(paramType, "List<", ">")
		string = ""
		if csharp_data_types.any(func(type): return paramTypeName.contains(type)):
			string += "			Godot.Collections.Array<"+ paramTypeName + "> Godot" + paramName +" = new();\n"
			string += "			row." + paramName + ".ForEach(x => {Godot" + paramName +".Add(x);});\n"
		else:
			string += "			Godot.Collections.Array<Godot."+ paramTypeName + "> Godot" + paramName +" = new();\n"
			string += "			row." + paramName + ".ForEach(x => {Godot" + paramName +".Add(new(x));});\n"
		string += "			this."+ paramName + " = Godot" + paramName + ";\n"
	elif (csharp_data_types.any(func(type): return paramType.contains(type))):
		string += "row."+paramName+";\n"
	else:
		string += "new(row."+paramName+");\n"
	return string
	

func tostdbString(paramType : String, paramName : String) -> String:
	var string : String = "			type." + paramName + " = "
	if(paramType.contains("List<")):
		string = ""
		if csharp_data_types.any(func(type): return paramType.contains(type)):
			string += "			"+ paramType + " Stdb" + paramName +" = new();\n"
			string += "			this." + paramName + ".ToList().ForEach(x => { Stdb" + paramName + ".Add(x);});\n"
		else:
			string += "			" +insert_at_pattern(paramType, "List<", "SpacetimeDB.Types.") + " Stdb" + paramName +" = new();\n"
			string += "			this." + paramName + ".ToList().ForEach(x => { Stdb" + paramName + ".Add(x.ToStdb());});\n"
		string += "			type." + paramName + " = Stdb"+ paramName + ";\n"
	elif (csharp_data_types.any(func(type): return paramType.contains(type))):
		string += "this." + paramName +";\n"
	else:
		string += "this." + paramName + ".ToStdb();\n"
	return string

func getSubstring(text : String, patternStart : String, patternEnd : String):
	var Start : int = text.find(patternStart,0)
	var End : int = text.find(patternEnd, Start + 1)
	var string : String = text.substr(Start+ patternStart.length(), End - Start -patternStart.length())
	return string


func upate_spacetime_client():
	print("\nModifying the BaseSpacetimeClient...");
	rich_text_label.append_text("Modifying the BaseSpacetimeClient...\n")
	var bindings_path = client_bindings_line_edit.text
	var file = FileAccess.open(clientTemplatePath, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	var serverName = server_line_edit.text
	var moduleName = module_name_line_edit.text
	if not serverName.is_empty():
		if(serverName == "Local"):
			content = insert_at_pattern(content, "HOST", " = \"http://localhost:3000\"");
		elif (serverName == "Maincloud"):
			content = insert_at_pattern(content, "HOST", " = \"wss://maincloud.spacetimedb.com\"");
		else:
			content = insert_at_pattern(content, "HOST", " = \""+ serverName +"\"");
	else:
		rich_text_label.append_text("Server Name empty. Aborting")
		return
	if not moduleName.is_empty():
		content = insert_at_pattern(content, "MODULE", " = \"" + moduleName + "\"");
	else:
		rich_text_label.append_text("Module Name empty. Aborting")
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
			var StdbParameterTypeName : String = text.substr(parametersStart+ 7, parametersEnd - parametersStart -8)
			var GodotParameterTypeName : String = ""
			var CallbackCodeblockInsert : String = ""
			var CallbackCodeblockUpdate : String = ""
			var CallbackCodeblockDelete : String = ""
			
			if not csharp_data_types.any(func(type): return StdbParameterTypeName.contains(type)):
				GodotParameterTypeName = "Godot."+StdbParameterTypeName
				StdbParameterTypeName = "SpacetimeDB.Types."+ StdbParameterTypeName
				CallbackCodeblockInsert += "			EmitSignal(SignalName."+tableName+"Inserted, new "+GodotParameterTypeName+"(inserted_row));"
				CallbackCodeblockUpdate += "			EmitSignal(SignalName."+tableName+"Inserted, new "+GodotParameterTypeName+"(old_row),new "+GodotParameterTypeName+"(new_row));"
				CallbackCodeblockDelete += "			EmitSignal(SignalName."+tableName+"Inserted, new "+GodotParameterTypeName+"(deleted_row));"
			else:
				GodotParameterTypeName = StdbParameterTypeName
				CallbackCodeblockInsert += "			EmitSignal(SignalName."+tableName+"Inserted, "+ GodotParameterTypeName +" inserted_row);"
				CallbackCodeblockUpdate += "			EmitSignal(SignalName."+tableName+"Inserted, "+ GodotParameterTypeName +" old_row, new_row);"
				CallbackCodeblockDelete += "			EmitSignal(SignalName."+tableName+"Inserted, "+ GodotParameterTypeName +" deleted_row));"
			
			# adding Signals
			content = insert_at_pattern(content, "// Insert Signals", "\n	[Signal]\n	public delegate void "+tableName+"InsertedEventHandler("+GodotParameterTypeName+" inserted_row);");
			content = insert_at_pattern(content, "// Update Signals", "\n	[Signal]\n	public delegate void "+tableName+"UpdatedEventHandler("+GodotParameterTypeName+" old_row, "+GodotParameterTypeName+" new_row);");
			content = insert_at_pattern(content, "// Delete Signals", "\n	[Signal]\n	public delegate void "+tableName+"DeletedEventHandler("+GodotParameterTypeName+" deleted_row);");
			
			# adding callbacks
			content = insert_at_pattern(content, "// Add Insert Callbacks", "\n		conn.Db."+tableName+".OnInsert += "+tableName+"_OnInsert;");
			content = insert_at_pattern(content, "// Add Update Callbacks", "\n		conn.Db."+tableName+".OnUpdate += "+tableName+"_OnUpdate;");
			content = insert_at_pattern(content, "// Add Delete Callbacks", "\n		conn.Db."+tableName+".OnDelete += "+tableName+"_OnDelete;");
			
			# adding callbacks
			content = insert_at_pattern(content, "// Insert Callbacks", "\n	void "+tableName+"_OnInsert(EventContext ctx, "+StdbParameterTypeName+" inserted_row){\n"+CallbackCodeblockInsert+"\n	}");
			content = insert_at_pattern(content, "// Update Callbacks", "\n	void "+tableName+"_OnUpdate(EventContext ctx, "+StdbParameterTypeName+" old_row, "+StdbParameterTypeName+" new_row){\n"+CallbackCodeblockUpdate+"}");
			content = insert_at_pattern(content, "// Delete Callbacks", "\n	void "+tableName+"_OnDelete(EventContext ctx, "+StdbParameterTypeName+" deleted_row){\n"+CallbackCodeblockDelete+"\n	}");
			
	

	#
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
		
		var char = '';
		while char != ')':
			method_arguments += char;
			char = reducer_content[start_reducer_method_index]
			start_reducer_method_index += 1
		if method_arguments.is_empty():
			continue
		var var_names :Array= method_arguments.split(" ")
		var call_string : String = ""
		var parameterString :String = ""
		
		var parameterDict : Dictionary[int, Array] ={}
		for k in var_names.size():
			if k % 2 == 1:
				parameterDict[k-1].append(var_names[k].trim_suffix(","))
			else: 
				parameterDict[k] = [var_names[k]]
		for array in parameterDict.values():
			if csharp_data_types.any(func(dtype): return array[0].contains(dtype)):
				parameterString += array[0] + " " + array[1] + ", "
				call_string += array[1] + ", "
			else:
				parameterString += "Godot."+ array[0] + " " + array[1] + ", "
				call_string += array[1] + ".ToStdb(), "
		parameterString = parameterString.trim_suffix(", ")
		call_string = call_string.trim_suffix(", ")
		var ReducerString : String = "\n\n	public void "+reducer_name+"("+parameterString+")\n"
		ReducerString += "		{\n		if (conn == null){\n			return;\n		}\n"
		ReducerString += "			conn.Reducers."+reducer_name+"("+call_string+");\n	}"
		content = insert_at_pattern(content, "// Reducers", ReducerString);
		
		#Update the file with the new content
	file = FileAccess.open(bindings_path + "/BaseSpacetimeClient.cs", FileAccess.WRITE);
	file.store_string(content);
	print("finished client")
