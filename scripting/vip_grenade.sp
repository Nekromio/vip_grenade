#pragma semicolon 1
#pragma newdecls required

#include <vip_core>
#include <sdktools_functions>

ConVar
	cvGiveRoundStart,
	cvEnable;

bool
	bGive[MAXPLAYERS+1];

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
	version = "1.0.0 101",
	url = "https://ggwp.site/"
};

public void OnPluginStart()
{
	cvEnable = CreateConVar("sm_vip_gr_enable", "1", "Включить/Выключить плагин", _, true, _, true, 1.0);

	cvGiveRoundStart = CreateConVar("sm_vip_gr_giveround", "1", "1 Выдачать гранаты только при старте раунда/ 0 выдавать каждое возрождение", _, true, _, true, 1.0);

	AutoExecConfig(true, "grenade", "vip");

	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_spawn", Event_PlayerSpawn);

	if(VIP_IsVIPLoaded()) VIP_OnVIPLoaded();
}

public void OnClientDisconnect(int client)
{
	bGive[client] = false;
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

void Event_RoundEnd(Event hEvent, const char[] name, bool dontBroadcast)
{
	if(!cvEnable.BoolValue || !cvGiveRoundStart.BoolValue)
		return;

	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i))
	{
		bGive[i] = false;
	}
}

void Event_PlayerSpawn(Event hEvent, const char[] name, bool dontBroadcast)
{
	if(!cvEnable.BoolValue)
		return;

	int client = GetClientOfUserId(GetEventInt(hEvent, "userid"));

	if(!IsClientValid(client) || !VIP_IsClientVIP(client) || cvGiveRoundStart.BoolValue && bGive[client])
		return;

	if(cvGiveRoundStart.BoolValue)
		bGive[client] = true;

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