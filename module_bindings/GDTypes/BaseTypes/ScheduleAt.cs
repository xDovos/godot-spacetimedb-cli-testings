using System;
using Godot;

namespace Godot
{
    [GlobalClass]
    public partial class ScheduleAt : Resource
    {
        public long Time;
        public ScheduleType Type;

        public enum ScheduleType
        {
            Timestamp,
            TimeDuration
        }


        public ScheduleAt(SpacetimeDB.ScheduleAt schedule) {
            if (schedule is SpacetimeDB.ScheduleAt.Time time)
            {
                Time = time.Time_.MicrosecondsSinceUnixEpoch;
                Type = ScheduleType.Timestamp;
            }
            else if (schedule is SpacetimeDB.ScheduleAt.Interval interval)
            {
                Time = interval.Interval_.Microseconds;
                Type = ScheduleType.TimeDuration;
            }
        }

        public SpacetimeDB.ScheduleAt ToStdb()
        {
            SpacetimeDB.ScheduleAt schedule;
            if (Type == ScheduleType.Timestamp)
            {
                schedule = new SpacetimeDB.Timestamp(Time);
            }
            else if (Type == ScheduleType.TimeDuration)
            {
                schedule = new SpacetimeDB.TimeDuration(Time);
            }
            else { 
                schedule = new SpacetimeDB.Timestamp(0);
            }

            return schedule;
        }

    }
}

