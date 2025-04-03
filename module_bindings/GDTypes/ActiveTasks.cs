using Godot;
using System;

namespace Godot
{
	[GlobalClass]
	public partial class ActiveTasks : Resource
	{
		//Exports
		[Export]
		public Godot.ScheduleAt ScheduledAt;
		[Export]
		public Godot.Timestamp StartTime;
		[Export]
		public uint TaskId;
		[Export]
		public uint CharacterId;
		[Export]
		public ulong Id;
		
		public ActiveTasks(
			SpacetimeDB.Types.ActiveTasks row
			)
		{
			//Constructor
		this.ScheduledAt = row.ScheduledAt;
		this.StartTime = row.StartTime;
		this.TaskId = row.TaskId;
		this.CharacterId = row.CharacterId;
		this.Id = row.Id;
			
		}
	}
}
