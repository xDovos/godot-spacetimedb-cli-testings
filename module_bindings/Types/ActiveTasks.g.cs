// THIS FILE IS AUTOMATICALLY GENERATED BY SPACETIMEDB. EDITS TO THIS FILE
// WILL NOT BE SAVED. MODIFY TABLES IN YOUR MODULE SOURCE CODE INSTEAD.

#nullable enable

using System;
using System.Collections.Generic;
using System.Runtime.Serialization;
using Godot;

namespace SpacetimeDB.Types
{
    [SpacetimeDB.Type]
    [DataContract]
    public sealed partial class ActiveTasks: RefCounted
    {
        [DataMember(Name = "ID")]
        public ulong Id;
        [DataMember(Name = "CharacterID")]
        public uint CharacterId;
        [DataMember(Name = "TaskID")]
        public uint TaskId;
        [DataMember(Name = "StartTime")]
        public SpacetimeDB.Timestamp StartTime;
        [DataMember(Name = "ScheduledAt")]
        public SpacetimeDB.ScheduleAt ScheduledAt;

        public ActiveTasks(
            ulong Id,
            uint CharacterId,
            uint TaskId,
            SpacetimeDB.Timestamp StartTime,
            SpacetimeDB.ScheduleAt ScheduledAt
        )
        {
            this.Id = Id;
            this.CharacterId = CharacterId;
            this.TaskId = TaskId;
            this.StartTime = StartTime;
            this.ScheduledAt = ScheduledAt;
        }

        public ActiveTasks()
        {
            this.ScheduledAt = null!;
        }
    }
}
