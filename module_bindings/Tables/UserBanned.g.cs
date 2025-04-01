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
        public sealed class UserBannedHandle : RemoteTableHandle<EventContext, UserBanned>
        {
            protected override string RemoteTableName => "UserBanned";

            public sealed class IdentityUniqueIndex : UniqueIndexBase<SpacetimeDB.Identity>
            {
                protected override SpacetimeDB.Identity GetKey(UserBanned row) => row.Identity;

                public IdentityUniqueIndex(UserBannedHandle table) : base(table) { }
            }

            public readonly IdentityUniqueIndex Identity;

            internal UserBannedHandle(DbConnection conn) : base(conn)
            {
                Identity = new(this);
            }

            protected override object GetPrimaryKey(UserBanned row) => row.Identity;
        }

        public readonly UserBannedHandle UserBanned;
    }
}
