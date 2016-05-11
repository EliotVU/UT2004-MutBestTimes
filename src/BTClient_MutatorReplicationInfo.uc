//==============================================================================
// BTClient_MutatorReplicationInfo.uc (C) 2005-2009 Eliot and .:..:. All Rights Reserved
/* Tasks:
            Receive all kind of record details data from MutBestTimes
            Initialize Client
            Psuedo-Timer
*/
//  Coded by Eliot and .:..:
//  Updated @ XX/04/2009.
//==============================================================================
class BTClient_MutatorReplicationInfo extends ReplicationInfo;

var string
    PlayersBestTimes,
    EndMsg,
    PointsReward,
    Credits,
    RankingPage;

var float
    MapBestTime,
    ObjectiveTotalTime,
    MatchStartTime;

var bool
    bSoloMap,
    bKeyMap,
    bHasInitialized,                                                            // Client Only
    bCompetitiveMode;

/* Server and Client */
var enum ERecordState
{
    RS_Active,
    RS_Succeed,
    RS_Failure,
    RS_QuickStart,
} RecordState;

/* Local, ClientReplication */
var BTClient_ClientReplication CR;                                              // Client Only

// Server side stats
var int RecordsCount;
var int MaxRecords;
var int PlayersCount, RankedPlayersCount;
var int SoloRecords;
var int MaxRankedPlayersCount;

var float TeamTime[2];

// Maybe abit bandwith expensive, but no big deal.
var struct sTeam{
    var string Name;
    var float Points;
    var int Voters;
} Teams[3];

var BTClient_LevelReplication BaseLevel, MapLevel;

replication
{
    reliable if( Role == ROLE_Authority )
        PlayersBestTimes, MapBestTime, MatchStartTime,
        RecordState, EndMsg, PointsReward, ObjectiveTotalTime,
        SoloRecords, bCompetitiveMode, Teams;

    // Only replicated once
    reliable if( bNetInitial )
        Credits, RankingPage,
        bSoloMap, bKeyMap,
        RecordsCount, MaxRecords, MaxRankedPlayersCount, PlayersCount, RankedPlayersCount,
        BaseLevel, MapLevel;

    reliable if( bNetDirty && bCompetitiveMode )
        TeamTime;
}

/** Queries the server for the all time, quarterly or daily player ranks. */
delegate OnRequestPlayerRanks( PlayerController requester, BTClient_ClientReplication CRI, int pageIndex, byte ranksId );
delegate OnRequestRecordRanks( PlayerController requester, BTClient_ClientReplication CRI, int pageIndex, string mapName );
delegate OnServerQuery( PlayerController requester, BTClient_ClientReplication CRI, string query );
delegate OnPlayerChangeLevel( Controller other, BTClient_ClientReplication CRI, BTClient_LevelReplication myLevel );

final function AddLevelReplication( BTClient_LevelReplication levelRep )
{
    local BTClient_LevelReplication other;

    if( BaseLevel == none )
    {
        BaseLevel = levelRep;
        return;
    }

    other = BaseLevel;
    BaseLevel = levelRep;
    levelRep.NextLevel = other;
}

simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    // Because PostNetBeginPlay is never called on standalone games!
    if( Level.NetMode == NM_StandAlone )
        PostNetBeginPlay();
}

simulated event PostNetBeginPlay()
{
    super.PostNetBeginPlay();
    SetTimer( 1.0, true );
}

simulated event Timer()
{
    if( !bHasInitialized && Level.GetLocalPlayerController() != none )
    {
        InitializeClient();
        SetTimer( 0, false );
    }
}

simulated function InitializeClient()
{
    local PlayerController PC;
    local BTClient_Interaction Inter;
    local LinkedReplicationInfo LRI;

    PC = Level.GetLocalPlayerController();
    if( PC != none && PC.Player != none && PC.PlayerReplicationInfo != none )
    {
        Inter = BTClient_Interaction(PC.Player.InteractionMaster.AddInteraction( string(Class'BTClient_Interaction'), PC.Player ));
        if( Inter != none )
        {
            Inter.MRI = self;
            Inter.HU = HUD_Assault(PC.myHud);
            Inter.myHUD = PC.myHud;
            Inter.ObjectsInitialized();

            if( CR == none )
            {
                for( LRI = PC.PlayerReplicationInfo.CustomReplicationInfo; LRI != none; LRI = LRI.NextReplicationInfo )
                {
                    if( BTClient_ClientReplication(LRI) != none )
                    {
                        CR = BTClient_ClientReplication(LRI);
                        CR.MRI = self;
                        break;
                    }
                }
            }
            bHasInitialized = true;
        }
    }
}

function SetBestTime( float NewTime )
{
    MapBestTime = NewTime;
}

function Reset()
{
    RecordState = RS_Active;
}

// Moved to here for the color operators
final simulated function Color GetFadingColor( Color FadingColor )
{
    local float pulse;

    pulse = 1.0 - (Level.TimeSeconds % 1.0);
    return FadingColor * (1.0 - pulse) + class'HUD'.default.WhiteColor * pulse;
}

defaultproperties
{
    RecordState=RS_Active
    NetUpdateFrequency=2
}
