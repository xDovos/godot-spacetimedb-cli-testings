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
    public sealed partial class SkillTable: RefCounted
    {
        [DataMember(Name = "SkillID")]
        public uint SkillId;
        [DataMember(Name = "TextureID")]
        public uint TextureId;
        [DataMember(Name = "Name")]
        public string Name;
        [DataMember(Name = "Description")]
        public string? Description;
        [DataMember(Name = "LevelRequirements")]
        public System.Collections.Generic.List<LevelRequirementType> LevelRequirements;
        [DataMember(Name = "ItemRequirements")]
        public System.Collections.Generic.List<ItemRequirementType> ItemRequirements;
        [DataMember(Name = "MaxLevel")]
        public uint MaxLevel;
        [DataMember(Name = "LevelScale")]
        public uint LevelScale;
        [DataMember(Name = "ExpScale")]
        public uint ExpScale;
        [DataMember(Name = "UseExpScale")]
        public uint UseExpScale;

        public SkillTable(
            uint SkillId,
            uint TextureId,
            string Name,
            string? Description,
            System.Collections.Generic.List<LevelRequirementType> LevelRequirements,
            System.Collections.Generic.List<ItemRequirementType> ItemRequirements,
            uint MaxLevel,
            uint LevelScale,
            uint ExpScale,
            uint UseExpScale
        )
        {
            this.SkillId = SkillId;
            this.TextureId = TextureId;
            this.Name = Name;
            this.Description = Description;
            this.LevelRequirements = LevelRequirements;
            this.ItemRequirements = ItemRequirements;
            this.MaxLevel = MaxLevel;
            this.LevelScale = LevelScale;
            this.ExpScale = ExpScale;
            this.UseExpScale = UseExpScale;
        }

        public SkillTable()
        {
            this.Name = "";
            this.LevelRequirements = new();
            this.ItemRequirements = new();
        }
    }
}
