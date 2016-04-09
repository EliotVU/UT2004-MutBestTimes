class BTGUI_PlayerRankingsScoreboard extends BTGUI_ScoreboardBase;

var automated BTGUI_PlayerRankingsMultiColumnListBox RankingsListBox;
var automated BTGUI_PlayerRankingsPlayerProfile PlayerInfoPanel;

var private BTClient_Interaction Inter;
var private editconst bool bIsQuerying;

event Free()
{
	super.Free();
	Inter = none;
}

event InitComponent( GUIController MyController, GUIComponent MyOwner )
{
	local BTClient_ClientReplication CRI;
	local int i;

	super.InitComponent( MyController, MyOwner );
    BackgroundColor = class'BTClient_Config'.default.CTable;
	RankingsListBox.MyScrollBar.PositionChanged =  InternalOnScroll;

    Inter = GetInter();
    CRI = GetCRI( PlayerOwner().PlayerReplicationInfo );
	if( CRI == none )
	{
		Warn("Couldn't find a CRI for the current local player!");
		return;
	}

	for( i = 0; i < RankingsListBox.RankingLists.Length; ++ i )
	{
		CRI.Rankings[i].OnPlayerRankReceived = InternalOnPlayerRankReceived;
		CRI.Rankings[i].OnPlayerRanksDone = InternalOnPlayerRanksDone;
	}
    QueryNextPlayerRanks();
}

final function BTGUI_PlayerRankingsMultiColumnList GetRankingsListFor( BTGUI_PlayerRankingsReplicationInfo source )
{
	local int i;

	for( i = 0; i < RankingsListBox.RankingLists.Length; ++ i )
	{
		if( RankingsListBox.RankingLists[i].myRep == source )
		{
			return RankingsListBox.RankingLists[i];
		}
	}
	return none;
}

function InternalOnPlayerRankReceived( int index, BTGUI_PlayerRankingsReplicationInfo source )
{
	local BTGUI_PlayerRankingsMultiColumnList list;

	PlayerOwner().ClientMessage("Received a rank packet");
	list = GetRankingsListFor( source );
	if( list == none )
	{
		Warn("Received a rank for a non existing rankings list!");
		return;
	}
	List.AddedItem();
	if( Inter == none ) // None once this menu is reopened :<?
    	Inter = GetInter();

	t_WindowTitle.SetCaption( WindowName @ "(" $ List.ItemCount $ "/" $ Inter.MRI.RankedPlayersCount $ ") out of" @ Inter.MRI.PlayersCount );
}

function InternalOnPlayerRanksDone( BTGUI_PlayerRankingsReplicationInfo source, bool bAll )
{
	PlayerOwner().ClientMessage("Query completed");
	bIsQuerying = bAll; // Don't ever query again if we have received all there is to be received!

	if( !bIsQuerying && !RankingsListBox.MyScrollBar.bVisible )
	{
		QueryNextPlayerRanks();
	}
}

function InternalOnScroll( int newPos )
{
    if( newPos > RankingsListBox.MyScrollBar.ItemCount-15 )
    {
        QueryNextPlayerRanks();
    }
}

function QueryNextPlayerRanks()
{
	PlayerOwner().ClientMessage("Querying next ranks" @ bIsQuerying);
    if( bIsQuerying )
    	return;

    bIsQuerying = true;
    BTGUI_PlayerRankingsMultiColumnList(RankingsListBox.List).myRep.QueryNextPlayerRanks();
}

defaultproperties
{
	WinLeft=0.00
	WinTop=0.50
	WinWidth=0.2
	WinHeight=0.60
	WindowName="Player Ranks"
	bPersistent=true

    Begin Object Class=BTGUI_PlayerRankingsMultiColumnListBox Name=ItemsListBox
        WinWidth=0.68
        WinHeight=0.90
        WinLeft=0.01
        WinTop=0.065
        bVisibleWhenEmpty=true
        bScaleToParent=True
        bBoundToParent=True
        FontScale=FNS_Small
    End Object
    RankingsListBox=ItemsListBox

    Begin Object class=BTGUI_PlayerRankingsPlayerProfile name=oPlayerInfoPanel
    	WinWidth=0.29
    	WinHeight=0.90
    	WinTop=0.065
    	WinLeft=0.70
    End Object
    PlayerInfoPanel=oPlayerInfoPanel
}