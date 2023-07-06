#pragma semicolon 1
#pragma newdecls required

#include <vip_core>
#include <sdktools_functions>

static const char g_sFeature[][] =
{
	"hegrenade",
	"flashbang",
	"smokegrenade"
};

/*
Тип зарядов

    CS:S
HE            - 11
флешка        - 12
smoke        - 13

    CS:GO
HE            - 14
флешка        - 15
smoke        - 16
молотов        - 17
обманка        - 18
*/

static const char sGrenadeList[][] =
{
	"weapon_hegrenade",
	"weapon_flashbang",
	"weapon_smokegrenade"
};

public Plugin myinfo = 
{
	name = "[ViP Core] Give Grenade",
	author = "Nek.'a 2x2",
	description = "Выдача гранат",
	version = "1.0.0 100",
	url = "https://ggwp.site/"
};

public void OnPluginStart()
{
	AutoExecConfig(true, "grenade", "vip");

	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_spawn", Event_PlayerSpawn);

	if(VIP_IsVIPLoaded()) VIP_OnVIPLoaded();
}

public void OnPluginEnd()
{
	for(int i = 0; i < sizeof(g_sFeature); i++)
	{
		if(CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "VIP_UnregisterFeature") == FeatureStatus_Available && VIP_IsValidFeature(g_sFeature[i]))
			VIP_UnregisterFeature(g_sFeature[i]);
	}
}

public void VIP_OnVIPLoaded()
{
	for(int i = 0; i < sizeof(g_sFeature); i++)
	{
		VIP_RegisterFeature(g_sFeature[i], INT);
	}
}

void Event_RoundStart(Event hEvent, const char[] name, bool dontBroadcast)
{
	//
}

void Event_PlayerSpawn(Event hEvent, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if(!IsClientValid(client) || !VIP_IsClientVIP(client))
		return;
	
	for(int i = 0; i < sizeof(g_sFeature); i++) if(VIP_IsClientFeatureUse(client, g_sFeature[i]))
	{
		GiveGrenade(client, i+11, VIP_GetClientFeatureInt(client, g_sFeature[i]));
	}
}

void GiveGrenade(int client, int index, int count)
{
	if(GetEntProp(client, Prop_Send, "m_iAmmo", _, index) < 1)
		GivePlayerItem(client, sGrenadeList[index-11]);
	if(!(GetEntProp(client, Prop_Send, "m_iAmmo", _, index) >= count))
		SetEntProp(client, Prop_Send, "m_iAmmo", count, _, index);
}

bool IsClientValid(int client)
{
	return 0 < client <= MaxClients && IsClientInGame(client);
}