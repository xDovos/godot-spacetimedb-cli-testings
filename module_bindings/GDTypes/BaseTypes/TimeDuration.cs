using System;
using Godot;

namespace Godot
{
    [GlobalClass]
    public partial class TimeDuration : Resource
    {
        public long Microseconds;
        public TimeDuration(SpacetimeDB.TimeDuration timeDuration) { 
            Microseconds = timeDuration.Microseconds;
        }
        public SpacetimeDB.TimeDuration ToStdb()
        {
            return new SpacetimeDB.TimeDuration(Microseconds);
        }
    }
}
