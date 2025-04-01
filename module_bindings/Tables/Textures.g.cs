// THIS FILE IS AUTOMATICALLY GENERATED BY SPACETIMEDB. EDITS TO THIS FILE
// WILL NOT BE SAVED. MODIFY TABLES IN YOUR MODULE SOURCE CODE INSTEAD.

#nullable enable

using System;
using SpacetimeDB.BSATN;
using SpacetimeDB.ClientApi;
using System.Collections.Generic;
using System.Runtime.Serialization;

namespace SpacetimeDB.Types
{
    public sealed partial class RemoteTables
    {
        public sealed class TexturesHandle : RemoteTableHandle<EventContext, Textures>
        {
            protected override string RemoteTableName => "Textures";

            public sealed class NameUniqueIndex : UniqueIndexBase<string>
            {
                protected override string GetKey(Textures row) => row.Name;

                public NameUniqueIndex(TexturesHandle table) : base(table) { }
            }

            public readonly NameUniqueIndex Name;

            public sealed class TextureIdUniqueIndex : UniqueIndexBase<uint>
            {
                protected override uint GetKey(Textures row) => row.TextureId;

                public TextureIdUniqueIndex(TexturesHandle table) : base(table) { }
            }

            public readonly TextureIdUniqueIndex TextureId;

            internal TexturesHandle(DbConnection conn) : base(conn)
            {
                Name = new(this);
                TextureId = new(this);
            }

            protected override object GetPrimaryKey(Textures row) => row.TextureId;
        }

        public readonly TexturesHandle Textures;
    }
}
