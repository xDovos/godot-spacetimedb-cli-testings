
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
	[Signal]
	public delegate void UserSusInsertedEventHandler(UserSus inserted_row);
	[Signal]
	public delegate void UserModsInsertedEventHandler(UserMods inserted_row);
	[Signal]
	public delegate void UserInfoInsertedEventHandler(UserInfo inserted_row);
	[Signal]
	public delegate void UserDoubleConnectedInsertedEventHandler(UserSus inserted_row);
	[Signal]
	public delegate void UserBannedInsertedEventHandler(UserBanned inserted_row);
	[Signal]
	public delegate void UserInsertedEventHandler(User inserted_row);
	[Signal]
	public delegate void TexturesInsertedEventHandler(Textures inserted_row);
	[Signal]
	public delegate void TaskTableInsertedEventHandler(TaskTable inserted_row);
	[Signal]
	public delegate void TaskRewardTableInsertedEventHandler(TaskRewardTable inserted_row);
	[Signal]
	public delegate void TaskRequirementTableInsertedEventHandler(TaskRequirementTable inserted_row);
	[Signal]
	public delegate void StatTableInsertedEventHandler(StatTable inserted_row);
	[Signal]
	public delegate void SkillTableInsertedEventHandler(SkillTable inserted_row);
	[Signal]
	public delegate void ModCommandsInsertedEventHandler(ModCommands inserted_row);
	[Signal]
	public delegate void ItemTableInsertedEventHandler(ItemTable inserted_row);
	[Signal]
	public delegate void DisallowedWordsInsertedEventHandler(DisallowedWords inserted_row);
	[Signal]
	public delegate void ChatInsertedEventHandler(Message inserted_row);
	[Signal]
	public delegate void CharacterStatsInsertedEventHandler(CharacterStats inserted_row);
	[Signal]
	public delegate void CharacterSkillsInsertedEventHandler(CharacterSkills inserted_row);
	[Signal]
	public delegate void CharacterInventoryInsertedEventHandler(CharacterInventory inserted_row);
	[Signal]
	public delegate void CharacterInsertedEventHandler(Character inserted_row);
	[Signal]
	public delegate void BaseExpTableInsertedEventHandler(BaseExpTable inserted_row);
	[Signal]
	public delegate void ActiveTasksInsertedEventHandler(ActiveTasks inserted_row);
	// Update Signals
	[Signal]
	public delegate void UserSusUpdatedEventHandler(UserSus old_row, UserSus new_row);
	[Signal]
	public delegate void UserModsUpdatedEventHandler(UserMods old_row, UserMods new_row);
	[Signal]
	public delegate void UserInfoUpdatedEventHandler(UserInfo old_row, UserInfo new_row);
	[Signal]
	public delegate void UserDoubleConnectedUpdatedEventHandler(UserSus old_row, UserSus new_row);
	[Signal]
	public delegate void UserBannedUpdatedEventHandler(UserBanned old_row, UserBanned new_row);
	[Signal]
	public delegate void UserUpdatedEventHandler(User old_row, User new_row);
	[Signal]
	public delegate void TexturesUpdatedEventHandler(Textures old_row, Textures new_row);
	[Signal]
	public delegate void TaskTableUpdatedEventHandler(TaskTable old_row, TaskTable new_row);
	[Signal]
	public delegate void TaskRewardTableUpdatedEventHandler(TaskRewardTable old_row, TaskRewardTable new_row);
	[Signal]
	public delegate void TaskRequirementTableUpdatedEventHandler(TaskRequirementTable old_row, TaskRequirementTable new_row);
	[Signal]
	public delegate void StatTableUpdatedEventHandler(StatTable old_row, StatTable new_row);
	[Signal]
	public delegate void SkillTableUpdatedEventHandler(SkillTable old_row, SkillTable new_row);
	[Signal]
	public delegate void ModCommandsUpdatedEventHandler(ModCommands old_row, ModCommands new_row);
	[Signal]
	public delegate void ItemTableUpdatedEventHandler(ItemTable old_row, ItemTable new_row);
	[Signal]
	public delegate void DisallowedWordsUpdatedEventHandler(DisallowedWords old_row, DisallowedWords new_row);
	[Signal]
	public delegate void ChatUpdatedEventHandler(Message old_row, Message new_row);
	[Signal]
	public delegate void CharacterStatsUpdatedEventHandler(CharacterStats old_row, CharacterStats new_row);
	[Signal]
	public delegate void CharacterSkillsUpdatedEventHandler(CharacterSkills old_row, CharacterSkills new_row);
	[Signal]
	public delegate void CharacterInventoryUpdatedEventHandler(CharacterInventory old_row, CharacterInventory new_row);
	[Signal]
	public delegate void CharacterUpdatedEventHandler(Character old_row, Character new_row);
	[Signal]
	public delegate void BaseExpTableUpdatedEventHandler(BaseExpTable old_row, BaseExpTable new_row);
	[Signal]
	public delegate void ActiveTasksUpdatedEventHandler(ActiveTasks old_row, ActiveTasks new_row);
	// Delete Signals
	[Signal]
	public delegate void UserSusDeletedEventHandler(UserSus deleted_row);
	[Signal]
	public delegate void UserModsDeletedEventHandler(UserMods deleted_row);
	[Signal]
	public delegate void UserInfoDeletedEventHandler(UserInfo deleted_row);
	[Signal]
	public delegate void UserDoubleConnectedDeletedEventHandler(UserSus deleted_row);
	[Signal]
	public delegate void UserBannedDeletedEventHandler(UserBanned deleted_row);
	[Signal]
	public delegate void UserDeletedEventHandler(User deleted_row);
	[Signal]
	public delegate void TexturesDeletedEventHandler(Textures deleted_row);
	[Signal]
	public delegate void TaskTableDeletedEventHandler(TaskTable deleted_row);
	[Signal]
	public delegate void TaskRewardTableDeletedEventHandler(TaskRewardTable deleted_row);
	[Signal]
	public delegate void TaskRequirementTableDeletedEventHandler(TaskRequirementTable deleted_row);
	[Signal]
	public delegate void StatTableDeletedEventHandler(StatTable deleted_row);
	[Signal]
	public delegate void SkillTableDeletedEventHandler(SkillTable deleted_row);
	[Signal]
	public delegate void ModCommandsDeletedEventHandler(ModCommands deleted_row);
	[Signal]
	public delegate void ItemTableDeletedEventHandler(ItemTable deleted_row);
	[Signal]
	public delegate void DisallowedWordsDeletedEventHandler(DisallowedWords deleted_row);
	[Signal]
	public delegate void ChatDeletedEventHandler(Message deleted_row);
	[Signal]
	public delegate void CharacterStatsDeletedEventHandler(CharacterStats deleted_row);
	[Signal]
	public delegate void CharacterSkillsDeletedEventHandler(CharacterSkills deleted_row);
	[Signal]
	public delegate void CharacterInventoryDeletedEventHandler(CharacterInventory deleted_row);
	[Signal]
	public delegate void CharacterDeletedEventHandler(Character deleted_row);
	[Signal]
	public delegate void BaseExpTableDeletedEventHandler(BaseExpTable deleted_row);
	[Signal]
	public delegate void ActiveTasksDeletedEventHandler(ActiveTasks deleted_row);

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
		conn.Db.UserSus.OnInsert += UserSus_OnInsert;
		conn.Db.UserMods.OnInsert += UserMods_OnInsert;
		conn.Db.UserInfo.OnInsert += UserInfo_OnInsert;
		conn.Db.UserDoubleConnected.OnInsert += UserDoubleConnected_OnInsert;
		conn.Db.UserBanned.OnInsert += UserBanned_OnInsert;
		conn.Db.User.OnInsert += User_OnInsert;
		conn.Db.Textures.OnInsert += Textures_OnInsert;
		conn.Db.TaskTable.OnInsert += TaskTable_OnInsert;
		conn.Db.TaskRewardTable.OnInsert += TaskRewardTable_OnInsert;
		conn.Db.TaskRequirementTable.OnInsert += TaskRequirementTable_OnInsert;
		conn.Db.StatTable.OnInsert += StatTable_OnInsert;
		conn.Db.SkillTable.OnInsert += SkillTable_OnInsert;
		conn.Db.ModCommands.OnInsert += ModCommands_OnInsert;
		conn.Db.ItemTable.OnInsert += ItemTable_OnInsert;
		conn.Db.DisallowedWords.OnInsert += DisallowedWords_OnInsert;
		conn.Db.Chat.OnInsert += Chat_OnInsert;
		conn.Db.CharacterStats.OnInsert += CharacterStats_OnInsert;
		conn.Db.CharacterSkills.OnInsert += CharacterSkills_OnInsert;
		conn.Db.CharacterInventory.OnInsert += CharacterInventory_OnInsert;
		conn.Db.Character.OnInsert += Character_OnInsert;
		conn.Db.BaseExpTable.OnInsert += BaseExpTable_OnInsert;
		conn.Db.ActiveTasks.OnInsert += ActiveTasks_OnInsert;
		// Add Update Callbacks
		conn.Db.UserSus.OnUpdate += UserSus_OnUpdate;
		conn.Db.UserMods.OnUpdate += UserMods_OnUpdate;
		conn.Db.UserInfo.OnUpdate += UserInfo_OnUpdate;
		conn.Db.UserDoubleConnected.OnUpdate += UserDoubleConnected_OnUpdate;
		conn.Db.UserBanned.OnUpdate += UserBanned_OnUpdate;
		conn.Db.User.OnUpdate += User_OnUpdate;
		conn.Db.Textures.OnUpdate += Textures_OnUpdate;
		conn.Db.TaskTable.OnUpdate += TaskTable_OnUpdate;
		conn.Db.TaskRewardTable.OnUpdate += TaskRewardTable_OnUpdate;
		conn.Db.TaskRequirementTable.OnUpdate += TaskRequirementTable_OnUpdate;
		conn.Db.StatTable.OnUpdate += StatTable_OnUpdate;
		conn.Db.SkillTable.OnUpdate += SkillTable_OnUpdate;
		conn.Db.ModCommands.OnUpdate += ModCommands_OnUpdate;
		conn.Db.ItemTable.OnUpdate += ItemTable_OnUpdate;
		conn.Db.DisallowedWords.OnUpdate += DisallowedWords_OnUpdate;
		conn.Db.Chat.OnUpdate += Chat_OnUpdate;
		conn.Db.CharacterStats.OnUpdate += CharacterStats_OnUpdate;
		conn.Db.CharacterSkills.OnUpdate += CharacterSkills_OnUpdate;
		conn.Db.CharacterInventory.OnUpdate += CharacterInventory_OnUpdate;
		conn.Db.Character.OnUpdate += Character_OnUpdate;
		conn.Db.BaseExpTable.OnUpdate += BaseExpTable_OnUpdate;
		conn.Db.ActiveTasks.OnUpdate += ActiveTasks_OnUpdate;
		// Add Delete Callbacks
		conn.Db.UserSus.OnDelete += UserSus_OnDelete;
		conn.Db.UserMods.OnDelete += UserMods_OnDelete;
		conn.Db.UserInfo.OnDelete += UserInfo_OnDelete;
		conn.Db.UserDoubleConnected.OnDelete += UserDoubleConnected_OnDelete;
		conn.Db.UserBanned.OnDelete += UserBanned_OnDelete;
		conn.Db.User.OnDelete += User_OnDelete;
		conn.Db.Textures.OnDelete += Textures_OnDelete;
		conn.Db.TaskTable.OnDelete += TaskTable_OnDelete;
		conn.Db.TaskRewardTable.OnDelete += TaskRewardTable_OnDelete;
		conn.Db.TaskRequirementTable.OnDelete += TaskRequirementTable_OnDelete;
		conn.Db.StatTable.OnDelete += StatTable_OnDelete;
		conn.Db.SkillTable.OnDelete += SkillTable_OnDelete;
		conn.Db.ModCommands.OnDelete += ModCommands_OnDelete;
		conn.Db.ItemTable.OnDelete += ItemTable_OnDelete;
		conn.Db.DisallowedWords.OnDelete += DisallowedWords_OnDelete;
		conn.Db.Chat.OnDelete += Chat_OnDelete;
		conn.Db.CharacterStats.OnDelete += CharacterStats_OnDelete;
		conn.Db.CharacterSkills.OnDelete += CharacterSkills_OnDelete;
		conn.Db.CharacterInventory.OnDelete += CharacterInventory_OnDelete;
		conn.Db.Character.OnDelete += Character_OnDelete;
		conn.Db.BaseExpTable.OnDelete += BaseExpTable_OnDelete;
		conn.Db.ActiveTasks.OnDelete += ActiveTasks_OnDelete;
	}

	// Insert Callbacks
	void UserSus_OnInsert(EventContext ctx, UserSus inserted_row){
		EmitSignal(SignalName.UserSusInserted, inserted_row);
	}
	void UserMods_OnInsert(EventContext ctx, UserMods inserted_row){
		EmitSignal(SignalName.UserModsInserted, inserted_row);
	}
	void UserInfo_OnInsert(EventContext ctx, UserInfo inserted_row){
		EmitSignal(SignalName.UserInfoInserted, inserted_row);
	}
	void UserDoubleConnected_OnInsert(EventContext ctx, UserSus inserted_row){
		EmitSignal(SignalName.UserDoubleConnectedInserted, inserted_row);
	}
	void UserBanned_OnInsert(EventContext ctx, UserBanned inserted_row){
		EmitSignal(SignalName.UserBannedInserted, inserted_row);
	}
	void User_OnInsert(EventContext ctx, User inserted_row){
		EmitSignal(SignalName.UserInserted, inserted_row);
	}
	void Textures_OnInsert(EventContext ctx, Textures inserted_row){
		EmitSignal(SignalName.TexturesInserted, inserted_row);
	}
	void TaskTable_OnInsert(EventContext ctx, TaskTable inserted_row){
		EmitSignal(SignalName.TaskTableInserted, inserted_row);
	}
	void TaskRewardTable_OnInsert(EventContext ctx, TaskRewardTable inserted_row){
		EmitSignal(SignalName.TaskRewardTableInserted, inserted_row);
	}
	void TaskRequirementTable_OnInsert(EventContext ctx, TaskRequirementTable inserted_row){
		EmitSignal(SignalName.TaskRequirementTableInserted, inserted_row);
	}
	void StatTable_OnInsert(EventContext ctx, StatTable inserted_row){
		EmitSignal(SignalName.StatTableInserted, inserted_row);
	}
	void SkillTable_OnInsert(EventContext ctx, SkillTable inserted_row){
		EmitSignal(SignalName.SkillTableInserted, inserted_row);
	}
	void ModCommands_OnInsert(EventContext ctx, ModCommands inserted_row){
		EmitSignal(SignalName.ModCommandsInserted, inserted_row);
	}
	void ItemTable_OnInsert(EventContext ctx, ItemTable inserted_row){
		EmitSignal(SignalName.ItemTableInserted, inserted_row);
	}
	void DisallowedWords_OnInsert(EventContext ctx, DisallowedWords inserted_row){
		EmitSignal(SignalName.DisallowedWordsInserted, inserted_row);
	}
	void Chat_OnInsert(EventContext ctx, Message inserted_row){
		EmitSignal(SignalName.ChatInserted, inserted_row);
	}
	void CharacterStats_OnInsert(EventContext ctx, CharacterStats inserted_row){
		EmitSignal(SignalName.CharacterStatsInserted, inserted_row);
	}
	void CharacterSkills_OnInsert(EventContext ctx, CharacterSkills inserted_row){
		EmitSignal(SignalName.CharacterSkillsInserted, inserted_row);
	}
	void CharacterInventory_OnInsert(EventContext ctx, CharacterInventory inserted_row){
		EmitSignal(SignalName.CharacterInventoryInserted, inserted_row);
	}
	void Character_OnInsert(EventContext ctx, Character inserted_row){
		EmitSignal(SignalName.CharacterInserted, inserted_row);
	}
	void BaseExpTable_OnInsert(EventContext ctx, BaseExpTable inserted_row){
		EmitSignal(SignalName.BaseExpTableInserted, inserted_row);
	}
	void ActiveTasks_OnInsert(EventContext ctx, ActiveTasks inserted_row){
		EmitSignal(SignalName.ActiveTasksInserted, inserted_row);
	}
	// Update Callbacks
	void UserSus_OnUpdate(EventContext ctx, UserSus old_row, UserSus new_row){
		EmitSignal(SignalName.UserSusUpdated, old_row, new_row);
	}
	void UserMods_OnUpdate(EventContext ctx, UserMods old_row, UserMods new_row){
		EmitSignal(SignalName.UserModsUpdated, old_row, new_row);
	}
	void UserInfo_OnUpdate(EventContext ctx, UserInfo old_row, UserInfo new_row){
		EmitSignal(SignalName.UserInfoUpdated, old_row, new_row);
	}
	void UserDoubleConnected_OnUpdate(EventContext ctx, UserSus old_row, UserSus new_row){
		EmitSignal(SignalName.UserDoubleConnectedUpdated, old_row, new_row);
	}
	void UserBanned_OnUpdate(EventContext ctx, UserBanned old_row, UserBanned new_row){
		EmitSignal(SignalName.UserBannedUpdated, old_row, new_row);
	}
	void User_OnUpdate(EventContext ctx, User old_row, User new_row){
		EmitSignal(SignalName.UserUpdated, old_row, new_row);
	}
	void Textures_OnUpdate(EventContext ctx, Textures old_row, Textures new_row){
		EmitSignal(SignalName.TexturesUpdated, old_row, new_row);
	}
	void TaskTable_OnUpdate(EventContext ctx, TaskTable old_row, TaskTable new_row){
		EmitSignal(SignalName.TaskTableUpdated, old_row, new_row);
	}
	void TaskRewardTable_OnUpdate(EventContext ctx, TaskRewardTable old_row, TaskRewardTable new_row){
		EmitSignal(SignalName.TaskRewardTableUpdated, old_row, new_row);
	}
	void TaskRequirementTable_OnUpdate(EventContext ctx, TaskRequirementTable old_row, TaskRequirementTable new_row){
		EmitSignal(SignalName.TaskRequirementTableUpdated, old_row, new_row);
	}
	void StatTable_OnUpdate(EventContext ctx, StatTable old_row, StatTable new_row){
		EmitSignal(SignalName.StatTableUpdated, old_row, new_row);
	}
	void SkillTable_OnUpdate(EventContext ctx, SkillTable old_row, SkillTable new_row){
		EmitSignal(SignalName.SkillTableUpdated, old_row, new_row);
	}
	void ModCommands_OnUpdate(EventContext ctx, ModCommands old_row, ModCommands new_row){
		EmitSignal(SignalName.ModCommandsUpdated, old_row, new_row);
	}
	void ItemTable_OnUpdate(EventContext ctx, ItemTable old_row, ItemTable new_row){
		EmitSignal(SignalName.ItemTableUpdated, old_row, new_row);
	}
	void DisallowedWords_OnUpdate(EventContext ctx, DisallowedWords old_row, DisallowedWords new_row){
		EmitSignal(SignalName.DisallowedWordsUpdated, old_row, new_row);
	}
	void Chat_OnUpdate(EventContext ctx, Message old_row, Message new_row){
		EmitSignal(SignalName.ChatUpdated, old_row, new_row);
	}
	void CharacterStats_OnUpdate(EventContext ctx, CharacterStats old_row, CharacterStats new_row){
		EmitSignal(SignalName.CharacterStatsUpdated, old_row, new_row);
	}
	void CharacterSkills_OnUpdate(EventContext ctx, CharacterSkills old_row, CharacterSkills new_row){
		EmitSignal(SignalName.CharacterSkillsUpdated, old_row, new_row);
	}
	void CharacterInventory_OnUpdate(EventContext ctx, CharacterInventory old_row, CharacterInventory new_row){
		EmitSignal(SignalName.CharacterInventoryUpdated, old_row, new_row);
	}
	void Character_OnUpdate(EventContext ctx, Character old_row, Character new_row){
		EmitSignal(SignalName.CharacterUpdated, old_row, new_row);
	}
	void BaseExpTable_OnUpdate(EventContext ctx, BaseExpTable old_row, BaseExpTable new_row){
		EmitSignal(SignalName.BaseExpTableUpdated, old_row, new_row);
	}
	void ActiveTasks_OnUpdate(EventContext ctx, ActiveTasks old_row, ActiveTasks new_row){
		EmitSignal(SignalName.ActiveTasksUpdated, old_row, new_row);
	}
	// Delete Callbacks
	void UserSus_OnDelete(EventContext ctx, UserSus deleted_row){
		EmitSignal(SignalName.UserSusDeleted, deleted_row);
	}
	void UserMods_OnDelete(EventContext ctx, UserMods deleted_row){
		EmitSignal(SignalName.UserModsDeleted, deleted_row);
	}
	void UserInfo_OnDelete(EventContext ctx, UserInfo deleted_row){
		EmitSignal(SignalName.UserInfoDeleted, deleted_row);
	}
	void UserDoubleConnected_OnDelete(EventContext ctx, UserSus deleted_row){
		EmitSignal(SignalName.UserDoubleConnectedDeleted, deleted_row);
	}
	void UserBanned_OnDelete(EventContext ctx, UserBanned deleted_row){
		EmitSignal(SignalName.UserBannedDeleted, deleted_row);
	}
	void User_OnDelete(EventContext ctx, User deleted_row){
		EmitSignal(SignalName.UserDeleted, deleted_row);
	}
	void Textures_OnDelete(EventContext ctx, Textures deleted_row){
		EmitSignal(SignalName.TexturesDeleted, deleted_row);
	}
	void TaskTable_OnDelete(EventContext ctx, TaskTable deleted_row){
		EmitSignal(SignalName.TaskTableDeleted, deleted_row);
	}
	void TaskRewardTable_OnDelete(EventContext ctx, TaskRewardTable deleted_row){
		EmitSignal(SignalName.TaskRewardTableDeleted, deleted_row);
	}
	void TaskRequirementTable_OnDelete(EventContext ctx, TaskRequirementTable deleted_row){
		EmitSignal(SignalName.TaskRequirementTableDeleted, deleted_row);
	}
	void StatTable_OnDelete(EventContext ctx, StatTable deleted_row){
		EmitSignal(SignalName.StatTableDeleted, deleted_row);
	}
	void SkillTable_OnDelete(EventContext ctx, SkillTable deleted_row){
		EmitSignal(SignalName.SkillTableDeleted, deleted_row);
	}
	void ModCommands_OnDelete(EventContext ctx, ModCommands deleted_row){
		EmitSignal(SignalName.ModCommandsDeleted, deleted_row);
	}
	void ItemTable_OnDelete(EventContext ctx, ItemTable deleted_row){
		EmitSignal(SignalName.ItemTableDeleted, deleted_row);
	}
	void DisallowedWords_OnDelete(EventContext ctx, DisallowedWords deleted_row){
		EmitSignal(SignalName.DisallowedWordsDeleted, deleted_row);
	}
	void Chat_OnDelete(EventContext ctx, Message deleted_row){
		EmitSignal(SignalName.ChatDeleted, deleted_row);
	}
	void CharacterStats_OnDelete(EventContext ctx, CharacterStats deleted_row){
		EmitSignal(SignalName.CharacterStatsDeleted, deleted_row);
	}
	void CharacterSkills_OnDelete(EventContext ctx, CharacterSkills deleted_row){
		EmitSignal(SignalName.CharacterSkillsDeleted, deleted_row);
	}
	void CharacterInventory_OnDelete(EventContext ctx, CharacterInventory deleted_row){
		EmitSignal(SignalName.CharacterInventoryDeleted, deleted_row);
	}
	void Character_OnDelete(EventContext ctx, Character deleted_row){
		EmitSignal(SignalName.CharacterDeleted, deleted_row);
	}
	void BaseExpTable_OnDelete(EventContext ctx, BaseExpTable deleted_row){
		EmitSignal(SignalName.BaseExpTableDeleted, deleted_row);
	}
	void ActiveTasks_OnDelete(EventContext ctx, ActiveTasks deleted_row){
		EmitSignal(SignalName.ActiveTasksDeleted, deleted_row);
	}
	
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
