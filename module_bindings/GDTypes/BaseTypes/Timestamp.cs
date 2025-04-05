using System;
using Godot;

namespace Godot
{
    [GlobalClass]
    public partial class Timestamp : Resource
    {
        public long MicrosecondsSinceUnixEpoch;
        public Timestamp( SpacetimeDB.Timestamp timestamp)
        {
            MicrosecondsSinceUnixEpoch = timestamp.MicrosecondsSinceUnixEpoch;
        }
        public SpacetimeDB.Timestamp ToStdb()
        {
            return new SpacetimeDB.Timestamp(MicrosecondsSinceUnixEpoch);
        }
    }
}
