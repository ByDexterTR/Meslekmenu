#include <sourcemod>
#include <sdktools>
#include <store>

#pragma semicolon 1
#pragma newdecls required

bool Kullandi[65] = { false, ... };
ConVar Kredi = null;

public Plugin myinfo = 
{
	name = "Meslekmenu", 
	author = "ByDexter", 
	description = "", 
	version = "1.0", 
	url = "https://steamcommunity.com/id/ByDexterTR - ByDexter#2947"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_meslekmenu", Meslek);
	RegConsoleCmd("sm_meslek", Meslek);
	HookEvent("round_start", RoundStart);
	
	Kredi = CreateConVar("sm_meslekmenu_kredi", "500", "Meslek kaç kredi olsun? [0 = Kapar]", 0, true, 0.0);
}

public Action Meslek(int client, int args)
{
	Menu menu = new Menu(Menu_CallBack);
	menu.SetTitle("[SM] Meslekmenu - Hangi meslek olmak istiyorsun?\n ");
	if (Kredi.IntValue >= 1)
	{
		char format[64];
		if (Store_GetClientCredits(client) >= 500 && !Kullandi[client])
		{
			Format(format, 64, "Rambo: 150 Can - %d Kredi", Kredi.IntValue);
			menu.AddItem("0", format);
			Format(format, 64, "Flash: 5 Saniye Hızlı Koşma - %d Kredi", Kredi.IntValue);
			menu.AddItem("1", format);
			Format(format, 64, "Bombacı: 1 El bombasi ve 1 Molotof - %d Kredi", Kredi.IntValue);
			menu.AddItem("2", format);
			Format(format, 64, "Doktor: 2 Sağlık Aşısı - %d Kredi", Kredi.IntValue);
			menu.AddItem("3", format);
		}
		else if (Store_GetClientCredits(client) < 500 || Kullandi[client])
		{
			Format(format, 64, "Rambo: 150 Can - %d Kredi", Kredi.IntValue);
			menu.AddItem("0", format, ITEMDRAW_DISABLED);
			Format(format, 64, "Flash: 5 Saniye Hızlı Koşma - %d Kredi", Kredi.IntValue);
			menu.AddItem("1", format, ITEMDRAW_DISABLED);
			Format(format, 64, "Bombacı: 1 El bombasi ve 1 Molotof - %d Kredi", Kredi.IntValue);
			menu.AddItem("2", format, ITEMDRAW_DISABLED);
			Format(format, 64, "Doktor: 2 Sağlık Aşısı - %d Kredi", Kredi.IntValue);
			menu.AddItem("3", format, ITEMDRAW_DISABLED);
		}
	}
	else
	{
		if (!Kullandi[client])
		{
			menu.AddItem("0", "Rambo: 150 Can");
			menu.AddItem("1", "Flash: 5 Saniye Hızlı Koşma");
			menu.AddItem("2", "Bombacı: 1 El bombasi ve 1 Molotof");
			menu.AddItem("3", "Doktor: 2 Sağlık Aşısı");
		}
		else
		{
			menu.AddItem("0", "Rambo: 150 Can", ITEMDRAW_DISABLED);
			menu.AddItem("1", "Flash: 5 Saniye Hızlı Koşma", ITEMDRAW_DISABLED);
			menu.AddItem("2", "Bombacı: 1 El bombasi ve 1 Molotof", ITEMDRAW_DISABLED);
			menu.AddItem("3", "Doktor: 2 Sağlık Aşısı", ITEMDRAW_DISABLED);
		}
	}
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_CallBack(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char Item[4];
		menu.GetItem(param2, Item, sizeof(Item));
		if (StringToInt(Item) == 0)
		{
			PrintToChat(param1, "[SM] \x01Mesleğin değiştirildi: \x04Rambo");
			SetEntityHealth(param1, 150);
			if (Kredi.IntValue >= 1)
				Store_SetClientCredits(param1, Store_GetClientCredits(param1) - Kredi.IntValue);
		}
		else if (StringToInt(Item) == 1)
		{
			PrintToChat(param1, "[SM] \x01Mesleğin değiştirildi: \x04Flash");
			CreateTimer(5.0, FlashKapat, param1, TIMER_FLAG_NO_MAPCHANGE);
			SetEntPropFloat(param1, Prop_Data, "m_flLaggedMovementValue", 1.7);
			if (Kredi.IntValue >= 1)
				Store_SetClientCredits(param1, Store_GetClientCredits(param1) - Kredi.IntValue);
		}
		else if (StringToInt(Item) == 2)
		{
			PrintToChat(param1, "[SM] \x01Mesleğin değiştirildi: \x04Bombaci");
			GivePlayerItem(param1, "weapon_hegrenade");
			GivePlayerItem(param1, "weapon_molotov");
			if (Kredi.IntValue >= 1)
				Store_SetClientCredits(param1, Store_GetClientCredits(param1) - Kredi.IntValue);
		}
		else
		{
			PrintToChat(param1, "[SM] \x01Mesleğin değiştirildi: \x04Doktor");
			GivePlayerItem(param1, "weapon_healthshot");
			GivePlayerItem(param1, "weapon_healthshot");
			if (Kredi.IntValue >= 1)
				Store_SetClientCredits(param1, Store_GetClientCredits(param1) - Kredi.IntValue);
		}
		Kullandi[param1] = true;
	}
	else if (action == MenuAction_End)
	{
		delete menu;
	}
}

public Action FlashKapat(Handle timer, int client)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	}
	return Plugin_Stop;
}

public Action RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	for (int i = 1; i < MaxClients; i++)if (IsValidClient(i))
	{
		Kullandi[i] = false;
	}
}

bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
} 