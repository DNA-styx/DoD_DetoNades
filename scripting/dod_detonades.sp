/**
* DoD:S DetoNades by Root
*
* Description:
*   Detonates a grenade when it collides with a player.
*
* Version 1.0
* Changelog & more info at http://goo.gl/4nKhJ
*/

#pragma semicolon 1

#include <sdkhooks>

// ====[ CONSTANTS ]==========================================================
#define PLUGIN_NAME    "DoD:S DetoNades"
#define PLUGIN_VERSION "1.0"

enum
{
	frag_us,
	frag_ger,
	riflegren_us,
	riflegren_ger
}

enum Grenades
{
	Handle:frag_grens,
	Handle:riflegrens
};

static NadesType[Grenades],
String:LiveGrenades[][] =
{
	"frag_us",
	"frag_ger",
	"riflegren_us",
	"riflegren_ger"
};

// ====[ PLUGIN ]=============================================================
public Plugin:myinfo =
{
	name        = PLUGIN_NAME,
	author      = "Root",
	description = "Detonates a grenade when it collides with a player",
	version     = PLUGIN_VERSION,
	url         = "http://dodsplugins.com/"
};


/* OnPluginStart()
 *
 * When the plugin starts up.
 * --------------------------------------------------------------------------- */
public OnPluginStart()
{
	// Simply create plugin ConVars
	CreateConVar("dod_detonades_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_NOTIFY|FCVAR_DONTRECORD);
	NadesType[frag_grens] = CreateConVar("dod_detonade_frag_grenades",  "0", "Whether or not detonate frag grenade when it collides with a player",  FCVAR_PLUGIN, true, 0.0, true, 1.0);
	NadesType[riflegrens] = CreateConVar("dod_detonade_rifle_grenades", "1", "Whether or not detonate rifle grenade when it collides with a player", FCVAR_PLUGIN, true, 0.0, true, 1.0);
}

/* OnEntityCreated()
 *
 * When an entity is created.
 * --------------------------------------------------------------------------- */
public OnEntityCreated(entity, const String:classname[])
{
	// Skip first 8 characters to avoid comparing with 'grenade_' prefix
	if (StrEqual(classname[8], LiveGrenades[frag_us])
	||  StrEqual(classname[8], LiveGrenades[frag_ger])
	&&  GetConVarBool(NadesType[frag_grens]) == true)
	{ SetEntProp(entity, Prop_Send, "m_bIsLive", true); }

	// If plugin should handle rifle grenades - set netprop
	if (StrEqual(classname[8], LiveGrenades[riflegren_us])
	||  StrEqual(classname[8], LiveGrenades[riflegren_ger])
	&&  GetConVarBool(NadesType[riflegrens]) == true)
	{ SetEntProp(entity, Prop_Send, "m_bIsLive", true); }
}

/* OnClientPutInServer()
 *
 * Called when a client is entering the game.
 * --------------------------------------------------------------------------- */
public OnClientPutInServer(client)
{
	// Hook TraceAttack (post) instead of OnTakeDamage
	SDKHook(client, SDKHook_TraceAttackPost, TraceAttackPost);
}

/* TraceAttack()
 *
 * Called when attacking is performed.
 * --------------------------------------------------------------------------- */
public TraceAttackPost(victim, attacker, inflictor, Float:damage, damagetype, ammotype, hitbox, hitgroup)
{
	// Check for valid victim and valid inflictor (with enabled netprop)
	if (victim && victim <= MaxClients && inflictor > MaxClients
	&& (GetEntProp(inflictor, Prop_Send, "m_bIsLive") == 1))
	{
		// This fucking awesome piece of code is brought to you by blodia (c) RedSword
		// Take a look at https://forums.alliedmods.net/showthread.php?p=1985693#post1985693
		SetEntProp(inflictor, Prop_Data, "m_takedamage", 2);
		SetEntProp(inflictor, Prop_Data, "m_iHealth", 1);
		SDKHooks_TakeDamage(inflictor, 0, 0, 1.0);
	}
}