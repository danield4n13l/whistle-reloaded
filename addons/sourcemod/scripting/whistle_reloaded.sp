#include <sdktools>
#include <cstrike>
#include <csgocolors>
#include <clientprefs>

char g_szPrefix[] 						= " {orange}[WHISTLE]{default}";
char WHISTLE_FULL_SOUND_PATH[] 			= "sound/zwolof/s_whistle.mp3";
char WHISTLE_RELATIVE_SOUND_PATH[] 		= "*zwolof/s_whistle.mp3";

float fTime = 10.0;

public Plugin myinfo = 
{
	name = "Simple Whistle Reloaded",
	description = "Simple Whistle Plugin with targeting and cvars",
	author = "zwolof, d3st1ny",
	version = "1.0b5",
	url = "https://steamcommunity.com/id/d3st1nyofficial"
};

public void OnPluginStart()
{
	RegClientCookie("WhistleReloaded Recharge", "Determines if the ability can be used or not", CookieAccess_Protected)
}

public OnMapStart()
{
	Cookie g_hWhistleRecharge = FindClientCookie("WhistleReloaded Recharge");
	for(int i = 0; i < MaxClients; i++)
	{
		if(!IsValidClient(i)) continue;
		SetClientCookie(i, g_hWhistleRecharge, "0");
	}
	CloseHandle(g_hWhistleRecharge);
	AddFileToDownloadsTable(WHISTLE_FULL_SOUND_PATH);
	FakePrecacheSound(WHISTLE_RELATIVE_SOUND_PATH);
}

public Action OnPlayerRunCmd(client, &buttons)
{
	if(!IsPlayerAlive(client)) 
		return Plugin_Continue;
		
	if(!IsValidClient(client))
		return Plugin_Continue;
		
	if(GetClientTeam(client) == CS_TEAM_T)
	{
		Cookie g_hWhistleRecharge = FindClientCookie("WhistleReloaded Recharge");
		char sWhistleRecharge[2];
		GetClientCookie(client, g_hWhistleRecharge, sWhistleRecharge, sizeof(sWhistleRecharge))
		if(buttons & IN_USE && (sWhistleRecharge[0] == '0' || sWhistleRecharge[0] == '\x00'))
		{
			char szName[256];
			GetClientName(client, szName, sizeof(szName));

			char szTarget[256];
			int target = GetClientAimTarget(client, false);
			char szTargetCls[256];

			if(target == -1)
			{
				CPrintToChatAll("%s {grey}%s{default} has {green}whistled{default}!", g_szPrefix, szName);
			}
			else {
				
				if(IsValidClient(target))
				{
					GetClientName(target, szTarget, sizeof(szTarget));
					CPrintToChatAll("%s {grey}%s{default} has {green}whistled{default} to {red}%s{default}!", g_szPrefix, szName, szTarget);
				}
				else{
					GetEntityClassname(target, szTargetCls, sizeof(szTargetCls));
					if( strcmp(szTargetCls, "func_button", true) || 
						strcmp(szTargetCls, "func_door", true) || 
						strcmp(szTargetCls, "func_door_rotating", true))
 					{
						CloseHandle(g_hWhistleRecharge);
						return Plugin_Continue;
					}
				}
			}


			float fVec[3];
			GetClientAbsOrigin(client, fVec);
			fVec[2] += 10;	
		
			EmitAmbientSound(WHISTLE_RELATIVE_SOUND_PATH, fVec, client, SNDLEVEL_RAIDSIREN, _, 0.3);
			SetClientCookie(client, g_hWhistleRecharge, "1");
			CloseHandle(g_hWhistleRecharge);
			CreateTimer(fTime, RemoveCooldown, client);
		}
	}
	return Plugin_Continue;
}

public Action RemoveCooldown(Handle tmr, int client)
{
	Cookie g_hWhistleRecharge = FindClientCookie("WhistleReloaded Recharge");
	SetClientCookie(client, g_hWhistleRecharge, "0");
	CPrintToChat(client, "%s You can now {green}whistle{default} again!", g_szPrefix);
	CloseHandle(g_hWhistleRecharge);
}

public Action RemoveCooldownSilent(Handle tmr, int client)
{
	Cookie g_hWhistleRecharge = FindClientCookie("WhistleReloaded Recharge");
	SetClientCookie(client, g_hWhistleRecharge, "0");
	CloseHandle(g_hWhistleRecharge);
}

stock FakePrecacheSound(const char[] szPath) 
{
	AddToStringTable(FindStringTable("soundprecache"), szPath);
}

stock bool IsValidClient(int client)
{
	if (0 < client && client <= MaxClients && IsClientInGame(client))
		return true;

	return false;
}
/*
stock bool IsUsableEntity(int entity, int contentsMask)
{
	if(!IsValidEntity(entity))
		return false;

	char szEntClassname[256];
	GetEntityClassname(entity, szEntClassname, sizeof(szEntClassname));
	if(stringszEntClassname != "func_button" && szEntClassname != "func_door" && szEntClassname != "func_door_rotating")
		return false;

	int iEntFlags = getedic(entity);
	if(iEntFlags & 1<<8)
		return true;
} */