using Godot;
using System;


[GlobalClass]
public partial class Message : Resource
{
    [Export]
    public uint Id;
    [Export]
    public uint CharacterId;
    [Export]
    public string CharacterName = "";
    public SpacetimeDB.Timestamp Sent;
    [Export]
    public string Text = "";

    public Message(
        uint Id,
        uint CharacterId,
        string CharacterName = "",
        long Sent = 0,
        string Text = ""
    )
    {
        this.Id = Id;
        this.CharacterId = CharacterId;
        this.CharacterName = CharacterName;
        this.Sent = new SpacetimeDB.Timestamp { MicrosecondsSinceUnixEpoch = Sent };
        this.Text = Text;
    }
}
