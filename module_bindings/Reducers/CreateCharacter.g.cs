// THIS FILE IS AUTOMATICALLY GENERATED BY SPACETIMEDB. EDITS TO THIS FILE
// WILL NOT BE SAVED. MODIFY TABLES IN YOUR MODULE SOURCE CODE INSTEAD.

#nullable enable

using System;
using SpacetimeDB.ClientApi;
using System.Collections.Generic;
using System.Runtime.Serialization;

namespace SpacetimeDB.Types
{
    public sealed partial class RemoteReducers : RemoteBase
    {
        public delegate void CreateCharacterHandler(ReducerEventContext ctx, string name);
        public event CreateCharacterHandler? OnCreateCharacter;

        public void CreateCharacter(string name)
        {
            conn.InternalCallReducer(new Reducer.CreateCharacter(name), this.SetCallReducerFlags.CreateCharacterFlags);
        }

        public bool InvokeCreateCharacter(ReducerEventContext ctx, Reducer.CreateCharacter args)
        {
            if (OnCreateCharacter == null) return false;
            OnCreateCharacter(
                ctx,
                args.Name
            );
            return true;
        }
    }

    public abstract partial class Reducer
    {
        [SpacetimeDB.Type]
        [DataContract]
        public sealed partial class CreateCharacter : Reducer, IReducerArgs
        {
            [DataMember(Name = "name")]
            public string Name;

            public CreateCharacter(string Name)
            {
                this.Name = Name;
            }

            public CreateCharacter()
            {
                this.Name = "";
            }

            string IReducerArgs.ReducerName => "CreateCharacter";
        }
    }

    public sealed partial class SetReducerFlags
    {
        internal CallReducerFlags CreateCharacterFlags;
        public void CreateCharacter(CallReducerFlags flags) => CreateCharacterFlags = flags;
    }
}
