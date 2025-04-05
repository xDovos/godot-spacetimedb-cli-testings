using System;
using Godot;


namespace Godot
{
    [GlobalClass]
    public partial class Identity : Resource
    {
        public string hexString;


        public Identity(SpacetimeDB.Identity identity)
        {
            hexString = identity.ToString();
        }

        public SpacetimeDB.Identity ToStdb()
        {
            return SpacetimeDB.Identity.FromHexString(hexString);
        }
    }
}
