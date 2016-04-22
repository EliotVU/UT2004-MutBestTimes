class BTGUI_QueryPanel extends GUIPanel;

var automated GUIHeader Header;
var automated GUILabel QueryLabel;
var automated GUIEditBox QueryBox;
var automated GUIImage PanelImage;
var automated BTGUI_QueryDataPanel DataPanel;

delegate OnQueryReceived( BTQueryDataReplicationInfo queryRI );

function InternalOnQueryChange( GUIComponent sender )
{
	DoQuery( GetQuery() );
}

function DoQuery( string query )
{
    local BTClient_ClientReplication CRI;

    Log( "received request for query \"" $ query $ "\"" );
    CRI = class'BTClient_ClientReplication'.static.GetRep( PlayerOwner() );
    if( CRI == none )
    {
    	Warn("Attempt to query with no CRI");
    	return;
    }
    CRI.ServerPerformQuery( query );
}

function InternalOnQueryReceived( BTQueryDataReplicationInfo queryRI )
{
	SwitchDataPanel( queryRI );
}

final function SwitchDataPanel( BTQueryDataReplicationInfo queryRI )
{
	local BTGUI_QueryDataPanel newDataPanel;

	newDataPanel = BTGUI_QueryDataPanel(AddComponent( string(queryRI.DataPanelClass) ));
	newDataPanel.WinWidth = DataPanel.WinWidth;
	newDataPanel.WinHeight = DataPanel.WinHeight;
	newDataPanel.WinTop = DataPanel.WinTop;
	newDataPanel.WinLeft = DataPanel.WinLeft;
	newDataPanel.bScaleToParent = DataPanel.bScaleToParent;
	newDataPanel.bBoundToParent = DataPanel.bBoundToParent;
	DataPanel.Free();
	RemoveComponent( DataPanel );
	DataPanel = newDataPanel;
	DataPanel.ApplyData( queryRI );
	queryRI.Abandon();
}

final function string GetQuery()
{
	return QueryBox.GetText();
}

final function SetQuery( coerce string query )
{
	QueryBox.SetText( query );
}

defaultproperties
{
	OnQueryReceived=InternalOnQueryReceived

    begin object class=GUILabel name=oQueryLabel
        WinTop=0.0
        WinHeight=0.045
        WinWidth=0.2
        WinLeft=0.0
        bScaleToParent=True
        bBoundToParent=True
        Caption="Search"
        TextColor=(R=255,G=255,B=255,A=255)
        TextAlign=TXTA_Center
        bTransparent=false
        FontScale=FNS_Small
        StyleName="BTHeader"
    end object
    QueryLabel=oQueryLabel

    begin object class=GUIEditBox name=oQueryBox
        WinTop=0.0
        WinHeight=0.045
        WinWidth=0.8
        WinLeft=0.2
        bScaleToParent=True
        bBoundToParent=True
        OnChange=InternalOnQueryChange
        StyleName="BTEditBox"
    end object
    QueryBox=oQueryBox

	Begin Object class=GUIHeader name=oHeader
		Caption="Details"
		WinWidth=1
		WinHeight=0.043750
		WinLeft=0
		WinTop=0.045
		RenderWeight=0.1
		FontScale=FNS_Small
		bUseTextHeight=true
		ScalingType=SCALE_X
		StyleName="BTHeader"
	End Object
	Header=oHeader

	Begin Object class=BTGUI_QueryDataPanel name=oQueryDataPanel
		WinWidth=1.0
		WinHeight=0.9
		WinTop=0.1
		WinLeft=0.0
        bScaleToParent=True
        bBoundToParent=True
	End Object
	DataPanel=oQueryDataPanel
}