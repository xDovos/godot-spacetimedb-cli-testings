
#nullable enable

using Godot;
using System;
using SpacetimeDB;
using SpacetimeDB.Types;

public partial class BaseSpacetimeClient : Node
{
	const string HOST = "http://localhost:3000";
	const string MODULE = "servertest";

	public Identity? local_identity = null;
	public DbConnection? conn = null;

	[Signal]
	public delegate void SubscriptionAppliedEventHandler();
	[Signal]
	public delegate void DisconnectedEventHandler();
	[Signal]
	public delegate void ConnectedEventHandler();

	// Insert Signals

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

	}

	// Insert Callbacks
	
	// Reducers

	public void WriteToLogs(string text){
		if (conn == null){
			return;
		}
		conn.Reducers.WriteToLogs(text);
	}

	public void StartActiveTaks(uint characterId, uint taskId){
		if (conn == null){
			return;
		}
		conn.Reducers.StartActiveTaks(characterId,taskId);
	}

	public void SetUserName(string name){
		if (conn == null){
			return;
		}
		conn.Reducers.SetUserName(name);
	}

	public void SendChatMessage(string charName, string text){
		if (conn == null){
			return;
		}
		conn.Reducers.SendChatMessage(charName,text);
	}

	public void ModTool(string command, System.Collections.Generic.List<string> args){
		if (conn == null){
			return;
		}
		conn.Reducers.ModTool(command,args);
	}

	public void DeleteCharacter(string name){
		if (conn == null){
			return;
		}
		conn.Reducers.DeleteCharacter(name);
	}

	public void CreateCharacter(string name){
		if (conn == null){
			return;
		}
		conn.Reducers.CreateCharacter(name);
	}

	public void Connect(){
		if (conn == null){
			return;
		}
		conn.Reducers.Connect();
	}

	public void AddTexturesTexture(Textures texture){
		if (conn == null){
			return;
		}
		conn.Reducers.AddTexturesTexture(texture);
	}

	public void AddTaskTableTask(TaskTable task, System.Collections.Generic.List<TaskRequirementTable> requirements, System.Collections.Generic.List<TaskRewardTable> reward){
		if (conn == null){
			return;
		}
		conn.Reducers.AddTaskTableTask(task,requirements,reward);
	}

	public void AddStatsTableStat(StatTable stat){
		if (conn == null){
			return;
		}
		conn.Reducers.AddStatsTableStat(stat);
	}

	public void AddSkillTableSkill(SkillTable skill){
		if (conn == null){
			return;
		}
		conn.Reducers.AddSkillTableSkill(skill);
	}

	public void AddItemTableItem(ItemTable item){
		if (conn == null){
			return;
		}
		conn.Reducers.AddItemTableItem(item);
	}

	public void ActiveTaskHandler(ActiveTasks activeTask){
		if (conn == null){
			return;
		}
		conn.Reducers.ActiveTaskHandler(activeTask);
	}

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
