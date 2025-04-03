@tool
extends Control

var config;
var default_config;

@export_tool_button("generate_client") var client = _on_generate_client_btn_pressed
@export_tool_button("Generate_Bindings") var bindings = _on_generate_bindings_btn_pressed

func _ready() -> void:
	pass

func _on_generate_client_btn_pressed() -> void:
	upate_spacetime_client()

func _on_generate_bindings_btn_pressed() -> void:
	update_module_bindings()



func upate_spacetime_client():
	print("\nModifying the BaseSpacetimeClient...");
	
	#	Generating base content
	var content = SPACETIME_CLIENT_CONTENT;
	
	content = insert_at_pattern(content, "HOST", " = \"" + $Host.text+"\"");
	content = insert_at_pattern(content, "MODULE", " = \"" + $Module.text+"\"");
	var modulePath = "res://module_bindings"
#	Adding all the callbacks signals for each table
	for file_name in DirAccess.open(modulePath+"/Tables").get_files():
		#print(file_name)
		if file_name.get_extension() == "cs":
			
			var file = FileAccess.open(modulePath+"/Tables/"+file_name, FileAccess.READ)
			if(file.get_error() != OK):
				print(error_string(file.get_error()))
			var text = file.get_as_text()
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
	for file_name in DirAccess.open(modulePath +"/Reducers").get_files():
		if file_name.get_extension() == "cs":
			var reducer_name = file_name.substr(0, len(file_name)-5);
			var reducer_file = FileAccess.open("res://module_bindings/Reducers/"+reducer_name+".g.cs", FileAccess.READ);
			var reducer_content = reducer_file.get_as_text();
			var pattern = "public void "+reducer_name+"(";
			var start_reducer_method_index = reducer_content.find(pattern);
			if start_reducer_method_index >= 0:
				reducers_name.append(reducer_name);
	
	for reducer_name in reducers_name:
		var reducer_file = FileAccess.open("res://module_bindings/Reducers/"+reducer_name+".g.cs", FileAccess.READ);
		var reducer_content = reducer_file.get_as_text();
		var pattern = "public void "+reducer_name+"(";
		var start_reducer_method_index = reducer_content.find(pattern) + len(pattern);
		var method_arguments = ""
		var char = '';
		while char != ')':
			method_arguments += char;
			char = reducer_content[start_reducer_method_index]
			start_reducer_method_index += 1
		var var_names = method_arguments.split(" ")
		var call_arguments = ""
		for k in range(len(var_names)):
			if k % 2 == 1:
				call_arguments += var_names[k];
		content = insert_at_pattern(content, "// Reducers", "\n\n	public void "+reducer_name+"("+method_arguments+"){\n		if (conn == null){\n			return;\n		}\n		conn.Reducers."+reducer_name+"("+call_arguments+");\n	}");
			
#		Update the file with the new content
	var file = FileAccess.open("res://addons/spacetime_client/BaseSpacetimeClient.cs", FileAccess.WRITE);
	file.store_string(content);
	print("finished client")


func update_module_bindings():
	print("\nUpdating module bindings...");
	var server_path = $ServerPath.text;
	var output = []
	var exite_code = OS.execute("spacetime", ["generate", "-y", "--lang", "csharp", "-p", server_path, "-o", "./module_bindings"], output, true, true)
	for out in output:
		print(out)
	
	print("\nAdding godot bindings...");
	for file_name in DirAccess.open("res://module_bindings/Types").get_files():
		if file_name.substr(len(file_name)-3, 3) == ".cs":
			print("Updating "+ file_name)
			var spacetime_type_name = file_name.substr(0, len(file_name)-5);
			var file = FileAccess.open("res://module_bindings/Types/"+file_name, FileAccess.READ);
			var content = file.get_as_text();
			file = FileAccess.open("res://module_bindings/Types/"+file_name, FileAccess.WRITE);
			
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

const SPACETIME_CLIENT_CONTENT = """
#nullable enable

using Godot;
using System;
using SpacetimeDB;
using SpacetimeDB.Types;

public partial class BaseSpacetimeClient : Node
{
	const string HOST;
	const string MODULE;

	public Identity? local_identity = null;
	public DbConnection? conn = null;

	[Signal]
	public delegate void SubscriptionAppliedEventHandler();
	[Signal]
	public delegate void DisconnectedEventHandler();
	[Signal]
	public delegate void ConnectedEventHandler();

	// Insert Signals
	// Update Signals
	// Delete Signals

	public override void _Ready()
	{
		AuthToken.Init("spacetime_db", "token.txt", OS.GetUserDataDir());
		conn = DbConnection.Builder()
			.WithUri(HOST)
			.WithModuleName(MODULE)
			.WithToken(AuthToken.Token)
			.OnConnect(OnConnected)
			.OnConnectError(OnConnectError)
			.OnDisconnect(OnDisconnected)
			.Build();
		RegisterCallbacks(conn);
	}

	public override void _PhysicsProcess(double delta)
	{
		conn?.FrameTick();
	}

	// Connection callbacks

	void OnConnected(DbConnection conn, Identity identity, string authToken)
	{
		local_identity = identity;
		AuthToken.SaveToken(authToken);

		conn.SubscriptionBuilder()
			.OnApplied(OnSubscriptionApplied)
			.SubscribeToAllTables();
		EmitSignal(SignalName.Connected, []);
	}
	void OnConnectError(Exception e)
	{
		GD.PrintErr($"Error while connecting: {e}");
	}
	void OnDisconnected(DbConnection conn, Exception? e)
	{
		if (e != null)
		{
			GD.PrintErr($"Disconnected abnormally: {e}");
		}
		else
		{
			GD.Print($"Disconnected normally.");
			EmitSignal(SignalName.Disconnected, []);
		}

	}

	void RegisterCallbacks(DbConnection conn)
	{
		// Add Insert Callbacks
		// Add Update Callbacks
		// Add Delete Callbacks
	}

	// Insert Callbacks
	// Update Callbacks
	// Delete Callbacks
	
	// Reducers

	// On sync data
	void OnSubscriptionApplied(SubscriptionEventContext ctx)
	{
		EmitSignal(SignalName.SubscriptionApplied, []);
	}

	// Closing connection

	public void CloseConnection()
	{
		if (conn == null)
		{
			return;
		}
		if (conn.IsActive)
		{
			conn.Disconnect();
			GD.Print("connection closed");
		}
	}


	public override void _Notification(int what)
	{
		if (what == Node.NotificationWMCloseRequest)
		{
			GD.Print("Game is exiting...");
			CloseConnection();
		}
		if (what == Node.NotificationCrash)
		{
			GD.Print("Game is crashed...");
			CloseConnection();
		}
		if (what == Node.NotificationExitTree)
		{
			GD.Print("Node Exited Tree...");
			CloseConnection();
		}

	}
}
"""
