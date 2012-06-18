//=============================================================================
// Copyright 2005-2010 Eliot Van Uytfanghe. All Rights Reserved.
//=============================================================================
class BTServer_Mode extends Object within MutBestTimes
	abstract
	hidedropdown;

/** The human friendly name for this mode. */
var editconst const noexport string ModeName;

/** The Server-MapName state mapprefix to use for this mode. */
var editconst const noexport string ModePrefix;

/** Reference to the owner that spawned this TrialMode instance. */
//var editconst noexport MutBestTimes Master;

var() int ExperienceBonus;

static function bool DetectMode( MutBestTimes M )
{
	return False;
}

protected function InitializeMode()
{
}

function ModePostBeginPlay()
{
}

function ModeMatchStarting()
{
}

function ModeReset()
{
}

function ModeModifyPlayer( Pawn other, Controller c, BTClient_ClientReplication CRI )
{
}

function GetServerDetails( out GameInfo.ServerResponseLine ServerState )
{
	local string S, Color;

	if( InStr( ServerState.MapName, "AS-" ) != -1 )
	{
		// Catch color.
		Color = Left( ServerState.MapName, InStr( ServerState.MapName, "AS-" ) );
		// MapName without prefix.
		S = Mid( ServerState.MapName, InStr( ServerState.MapName, "-" ) );

		ServerState.MapName = Color $ ModePrefix $ S;
	}
}

function bool ChatCommandExecuted( PlayerController sender, string command )
{
	return false;
}

function bool ClientExecuted( PlayerController sender, string command, optional array<string> params )
{
	return false;
}

function bool AdminExecuted( PlayerController sender, string command, optional array<string> params )
{
	return false;
}

function FinalObjectiveCompleted( PlayerController PC )
{
}

final static function BTServer_Mode NewInstance( MutBestTimes M )
{
	local BTServer_Mode Mode;

	Mode = new(M) default.class;
	//Mode = M.Spawn( default.class, M );
	//Mode.Master = M;
	Mode.InitializeMode();
	return Mode;
}

function bool ShouldEnd()
{
	return true;
}

function Free()
{
}

defaultproperties
{
	ExperienceBonus=0
}
