
#include <a_samp>
#include <DOF2>

// Novo strcmp
#define varGet(%0)      getproperty(0,%0)
#define varSet(%0,%1)   setproperty(0, %0, %1)
#define new_strcmp(%0,%1) \
                (varSet(%0, 1), varGet(%1) == varSet(%0, 0))

#define PASTA_CONTAS	"Contas/%s.ini"

// Cores 
#define COR_BRANCO	  0xFFFFFFFF
#define COR_VERMELHO1 0xFF0000FF
#define COR_VERMELHO2 0xFF4040FF
#define COR_VERDE1 	  0x00FF00FF
#define COR_VERDE2    0x32CD32FF
#define COR_AZUL1	  0x1E90FFFF
#define COR_AZUL2 	  0x00BFFFFF
#define COR_AMARELO1  0xFFFF00FF
#define COR_AMARELO2  0xFFD700FF
#define COR_ROSA1  	  0xFF1493FF
#define COR_ROSA2	  0xFF6EB4FF
#define COR_FADE1 	  0xE6E6E6E6
#define COR_FADE2 	  0xC8C8C8C8
#define COR_FADE3 	  0xAAAAAAAA
#define COR_FADE4 	  0x8C8C8C8C
#define COR_FADE5 	  0x6E6E6E6E
#define COR_EMOTE	  0xC2A2DAFF

enum 
{
	DIALOG_SENHA,
	DIALOG_GENERO
};

enum pInfo
{
	Senha[20],
	Dinheiro,
	Level,
	Skin,
	Genero,
	Admin,

	Interior,
	VirtualW,

	Float:VidaHP,
	Float:ColeteHP,

	Float:PosX,
	Float:PosY,
	Float:PosZ,
	Float:PosR
};
new PlayerInfo[MAX_PLAYERS][pInfo];

new arquivo[120]; // String Salvamento
new VSenha[MAX_PLAYERS][20]; // Variavel Senha Registro/Login
new VGenero[MAX_PLAYERS]; // Variável Genero Registro
new TentativasSenha[MAX_PLAYERS]; // Variavel Tentativas de Login

new bool:VerificarLogin[MAX_PLAYERS]; // Variavel Ant Spawn
new bool:EstaRegistrado[MAX_PLAYERS]; // Variavel se Tem ou nao Conta

new PlayerText:TextdrawRegistro[12][MAX_PLAYERS]; // Textdraw Registro e Login

main()
{
	print("\n----------------------------------");
	print(" Gamemode do Servidor foi Iniciada");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	SetGameModeText("Nome Servidor.");
	SetTimer("UmSegundo", 1000, true);
	return 1;
}

public OnGameModeExit()
{
	DOF2_Exit();
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	format(arquivo, sizeof(arquivo), PASTA_CONTAS, PlayerName(playerid));
	if(!DOF2_FileExists(arquivo))
	{
		EstaRegistrado[playerid] = false;
		VSenha[playerid] = "-1";
		VGenero[playerid] = -1;
		PlayerTextDrawSetString(playerid, TextdrawRegistro[7][playerid], PlayerName(playerid));
		for(new i; i < 12; i++)
		{
			PlayerTextDrawShow(playerid, TextdrawRegistro[i][playerid]);
		}
		SelectTextDraw(playerid, COR_VERMELHO2);
	}
	else if(DOF2_FileExists(arquivo))
	{
		EstaRegistrado[playerid] = true;
		VSenha[playerid] = "-1";
		TentativasSenha[playerid] = 0;
		PlayerTextDrawSetString(playerid, TextdrawRegistro[7][playerid], PlayerName(playerid));
		for(new i; i < 12; i++)
		{
			PlayerTextDrawShow(playerid, TextdrawRegistro[i][playerid]);
		}
		SelectTextDraw(playerid, COR_VERMELHO2);
	}
	LimparChat(playerid, 30);
	TogglePlayerSpectating(playerid, 1);
	InterpolateCameraPos(playerid, 131.695724, -2111.590332, 22.851112, 369.323669, -2110.894287, 12.786019, 10000, CAMERA_CUT);
	SetPlayerColor(playerid, COR_AMARELO1);
	return 1;
}

public OnPlayerConnect(playerid)
{
	CarregarTextDrawPlayer(playerid);
	VerificarLogin[playerid] = false;
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(VerificarLogin[playerid] == true)
	{
		SalvarDados(playerid);
	}
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(VerificarLogin[playerid] == false)
	{
		Kick(playerid);
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(VerificarLogin[playerid] == false)
	{
		MensagemErrorRegistro(playerid, "~r~ERRO: Voce nao pode falar no chat enquanto esta no registro/login.");
		return 0;
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_SENHA)
	{
		if(response)
		{
			if(strlen(inputtext) < 5 || strlen(inputtext) > 20)
			{
				MensagemErrorRegistro(playerid, "~r~ERRO: Voce informou uma senha muito pequena ou muito grande, informe senha maior que 5 e menor que 20");
			}
			else
			{
				format(VSenha[playerid], 20, inputtext);
				for(new i; i < strlen(inputtext); i++)
				{
					inputtext[i] = ']';
				}
				PlayerTextDrawSetString(playerid, TextdrawRegistro[8][playerid], inputtext);
				PlayerTextDrawShow(playerid, TextdrawRegistro[8][playerid]);
				PlayerPlaySound(playerid,1058,0.0,0.0,0.0);
				SelectTextDraw(playerid, COR_VERMELHO2);
			}
		}
		else
		{
			SelectTextDraw(playerid, COR_VERMELHO2);
		}
	}
	if(dialogid == DIALOG_GENERO)
	{
		if(response)
		{
			if(listitem == 0)
			{
				VGenero[playerid] = 1;
				CriarDadosPlayer(playerid);
			}
			if(listitem == 1)
			{
				VGenero[playerid] = 2;
				CriarDadosPlayer(playerid);
			}
		}
		else
		{
			return ShowPlayerDialog(playerid, DIALOG_GENERO, DIALOG_STYLE_LIST, "Genero", "1. Masculino\n2. Feminino", "Proximo", "");
		}
	}
	return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
	if(playertextid != INVALID_PLAYER_TEXT_DRAW)
	{
		if(playertextid == TextdrawRegistro[8][playerid]) // Botao Senha
		{
			if(EstaRegistrado[playerid] == false)
			{
				CancelSelectTextDraw(playerid);
				ShowPlayerDialog(playerid, DIALOG_SENHA, DIALOG_STYLE_PASSWORD, "Senha", "Informe abaixo uma senha para registrar-se.", "Pronto", "Voltar");
			}
			if(EstaRegistrado[playerid] == true)
			{
				CancelSelectTextDraw(playerid);
				ShowPlayerDialog(playerid, DIALOG_SENHA, DIALOG_STYLE_PASSWORD, "Senha", "Informe abaixo sua senha para logar no servidor.", "Pronto", "Voltar");
			}
		}
		if(playertextid == TextdrawRegistro[9][playerid])
		{
			if(EstaRegistrado[playerid] == false)
			{
				if(new_strcmp(VSenha[playerid], "-1"))
				{
					return MensagemErrorRegistro(playerid, "~r~ERRO: Voce nao digitou a senha na textdraw de senha.");
				}
				else
				{
					ShowPlayerDialog(playerid, DIALOG_GENERO, DIALOG_STYLE_LIST, "Genero", "1. Masculino\n2. Feminino", "Proximo", "");

					for(new i; i < 12; i++)
					{
						PlayerTextDrawHide(playerid, TextdrawRegistro[i][playerid]);
					}
					CancelSelectTextDraw(playerid);
				}
			}
			else if(EstaRegistrado[playerid] == true)
			{
				if(new_strcmp(VSenha[playerid], "-1"))
				{
					return MensagemErrorRegistro(playerid, "~r~ERRO: Voce nao digitou a senha na textdraw de senha.");
				}
				format(arquivo, sizeof(arquivo), PASTA_CONTAS, PlayerName(playerid));
				if(!new_strcmp(VSenha[playerid], DOF2_GetString(arquivo, "Senha")))
				{
					if(TentativasSenha[playerid] < 3)
					{
						new string[120];	
						TentativasSenha[playerid] ++;
						format(string, sizeof(string), "~r~ERRO: Voce informou sua senha incorretamente, informe sua senha corretamente (%02d/03).", TentativasSenha[playerid]);
						MensagemErrorRegistro(playerid, string);
					}
					else
					{
						Kick(playerid);
					}
				}
				else
				{
					for(new i; i < 12; i++)
					{
						PlayerTextDrawHide(playerid, TextdrawRegistro[i][playerid]);
					}
					CancelSelectTextDraw(playerid);
					CarregarDadosPlayer(playerid);
				}
			}
		}
		if(playertextid == TextdrawRegistro[10][playerid])
		{ 
			Kick(playerid);
		}
	}
	return 1;
}

forward QuebrarTextRegister(playerid);
public QuebrarTextRegister(playerid)
{
	return PlayerTextDrawHide(playerid, TextdrawRegistro[11][playerid]);
}

forward UmSegundo();
public UmSegundo()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(VerificarLogin[i] == false)
			{
				LimparChat(i, 10);
			}
		}
	}
	return 1;
}

stock CriarDadosPlayer(playerid)
{
	format(arquivo, sizeof(arquivo), PASTA_CONTAS, PlayerName(playerid));
	if(!DOF2_FileExists(arquivo))
	{
		DOF2_CreateFile(arquivo);
		DOF2_SetString(arquivo, "Senha", VSenha[playerid]);
		DOF2_SetInt(arquivo, "Dinheiro", 500);
		DOF2_SetInt(arquivo, "Level", 0);
		if(VGenero[playerid] == 1) // Homem
		{
			DOF2_SetInt(arquivo, "Skin", 97);
		}
		else if(VGenero[playerid] == 2) // Mulher
		{
			DOF2_SetInt(arquivo, "Skin", 93);
		}
		DOF2_SetInt(arquivo, "Genero", VGenero[playerid]);
		DOF2_SetInt(arquivo, "Admin", 0);

		DOF2_SetInt(arquivo, "Interior", 0);
		DOF2_SetInt(arquivo, "VirtualW", 0);

		DOF2_SetFloat(arquivo, "VidaHP", 100.0);
		DOF2_SetFloat(arquivo, "ColeteHP", 0.0);

		DOF2_SetFloat(arquivo, "PosX", 1715.336547);
		DOF2_SetFloat(arquivo, "PosY", -1884.636474);
		DOF2_SetFloat(arquivo, "PosZ", 13.567583);
		DOF2_SetFloat(arquivo, "PosR", 354.027893);
		DOF2_SaveFile();

		VSenha[playerid] = "-1";
		VGenero[playerid] = -1;
		CarregarDadosPlayer(playerid);
	}
	return 1;
}

stock CarregarDadosPlayer(playerid)
{
	format(arquivo, sizeof(arquivo), PASTA_CONTAS, PlayerName(playerid));
	if(DOF2_FileExists(arquivo))
	{
		GivePlayerMoney(playerid, DOF2_GetInt(arquivo, "Dinheiro"));
		SetPlayerScore(playerid, DOF2_GetInt(arquivo, "Level"));
		SetPlayerSkin(playerid, DOF2_GetInt(arquivo, "Skin"));
		PlayerInfo[playerid][Genero] = DOF2_GetInt(arquivo, "Genero");
		PlayerInfo[playerid][Admin] = DOF2_GetInt(arquivo, "Admin");
		SetPlayerInterior(playerid, DOF2_GetInt(arquivo, "Interior"));
		SetPlayerVirtualWorld(playerid, DOF2_GetInt(arquivo, "VirtualW"));
		SetPlayerHealth(playerid, DOF2_GetFloat(arquivo, "VidaHP"));
		SetPlayerArmour(playerid, DOF2_GetFloat(arquivo, "ColeteHP"));
		PlayerInfo[playerid][PosX] = DOF2_GetFloat(arquivo, "PosX");
		PlayerInfo[playerid][PosY] = DOF2_GetFloat(arquivo, "PosY");
		PlayerInfo[playerid][PosZ] = DOF2_GetFloat(arquivo, "PosZ");
		PlayerInfo[playerid][PosR] = DOF2_GetFloat(arquivo, "PosR");

		TogglePlayerSpectating(playerid, 0);
		VerificarLogin[playerid] = true;
		SetPlayerColor(playerid, COR_BRANCO);

		new string[128];
		format(string, sizeof(string), "{00FF00}| SERVER |{FFFFFF} Seja bem vindo %s! Caso precise de ajuda chame um administrador.", PlayerName(playerid));
		SendClientMessage(playerid, -1, string);

		SetSpawnInfo(playerid, NO_TEAM, GetPlayerSkin(playerid), PlayerInfo[playerid][PosX], PlayerInfo[playerid][PosY], PlayerInfo[playerid][PosZ], PlayerInfo[playerid][PosR], 0, 0, 0, 0, 0, 0);
		SpawnPlayer(playerid);
	}
	return 1;
}

stock SalvarDados(playerid)
{
	new Float:X, Float:Y, Float:Z, Float:R, Float:health, Float:armour;
	GetPlayerPos(playerid, Float:X, Float:Y, Float:Z);
	GetPlayerFacingAngle(playerid, Float:R);
	GetPlayerHealth(playerid, Float:health);
	GetPlayerArmour(playerid, Float:armour);
	
	format(arquivo, sizeof(arquivo), PASTA_CONTAS, PlayerName(playerid));
	if(DOF2_FileExists(arquivo))
	{
		DOF2_SetInt(arquivo, "Dinheiro", GetPlayerMoney(playerid));
		DOF2_SetInt(arquivo, "Level", GetPlayerScore(playerid));
		DOF2_SetInt(arquivo, "Skin", GetPlayerSkin(playerid));
		DOF2_SetInt(arquivo, "Genero", PlayerInfo[playerid][Genero]);
		DOF2_SetInt(arquivo, "Admin", PlayerInfo[playerid][Admin]);
		
		DOF2_SetInt(arquivo, "Interior", GetPlayerInterior(playerid));
		DOF2_SetInt(arquivo, "VirtualW", GetPlayerVirtualWorld(playerid));
		
		DOF2_SetFloat(arquivo, "VidaHP", health);
		DOF2_SetFloat(arquivo, "ColeteHP", armour);

		DOF2_SetFloat(arquivo, "PosX", X);
		DOF2_SetFloat(arquivo, "PosY", Y);
		DOF2_SetFloat(arquivo, "PosZ", Z);
		DOF2_SetFloat(arquivo, "PosR", R);
		DOF2_SaveFile();
	}
	return 1;
}

stock CarregarTextDrawPlayer(playerid)
{
	// Textdraw Registro e Login
	TextdrawRegistro[0][playerid] = CreatePlayerTextDraw(playerid,-20.000000, -49.000000, "_");
	PlayerTextDrawBackgroundColor(playerid,TextdrawRegistro[0][playerid], 255);
	PlayerTextDrawFont(playerid,TextdrawRegistro[0][playerid], 1);
	PlayerTextDrawLetterSize(playerid,TextdrawRegistro[0][playerid], -2.399999, 66.000000);
	PlayerTextDrawColor(playerid,TextdrawRegistro[0][playerid], -1);
	PlayerTextDrawSetOutline(playerid,TextdrawRegistro[0][playerid], 0);
	PlayerTextDrawSetProportional(playerid,TextdrawRegistro[0][playerid], 1);
	PlayerTextDrawSetShadow(playerid,TextdrawRegistro[0][playerid], 1);
	PlayerTextDrawUseBox(playerid,TextdrawRegistro[0][playerid], 1);
	PlayerTextDrawBoxColor(playerid,TextdrawRegistro[0][playerid], 471604479);
	PlayerTextDrawTextSize(playerid,TextdrawRegistro[0][playerid], 170.000000, 89.000000);
	PlayerTextDrawSetSelectable(playerid,TextdrawRegistro[0][playerid], 0);

	TextdrawRegistro[1][playerid] = CreatePlayerTextDraw(playerid,21.000000, 118.000000, "_");
	PlayerTextDrawBackgroundColor(playerid,TextdrawRegistro[1][playerid], 255);
	PlayerTextDrawFont(playerid,TextdrawRegistro[1][playerid], 1);
	PlayerTextDrawLetterSize(playerid,TextdrawRegistro[1][playerid], 0.679999, 2.799999);
	PlayerTextDrawColor(playerid,TextdrawRegistro[1][playerid], -1);
	PlayerTextDrawSetOutline(playerid,TextdrawRegistro[1][playerid], 0);
	PlayerTextDrawSetProportional(playerid,TextdrawRegistro[1][playerid], 1);
	PlayerTextDrawSetShadow(playerid,TextdrawRegistro[1][playerid], 1);
	PlayerTextDrawUseBox(playerid,TextdrawRegistro[1][playerid], 1);
	PlayerTextDrawBoxColor(playerid,TextdrawRegistro[1][playerid], -86);
	PlayerTextDrawTextSize(playerid,TextdrawRegistro[1][playerid], 146.000000, -53.000000);
	PlayerTextDrawSetSelectable(playerid,TextdrawRegistro[1][playerid], 0);

	TextdrawRegistro[2][playerid] = CreatePlayerTextDraw(playerid,22.000000, 191.000000, "_");
	PlayerTextDrawBackgroundColor(playerid,TextdrawRegistro[2][playerid], 255);
	PlayerTextDrawFont(playerid,TextdrawRegistro[2][playerid], 1);
	PlayerTextDrawLetterSize(playerid,TextdrawRegistro[2][playerid], 0.679999, 2.799999);
	PlayerTextDrawColor(playerid,TextdrawRegistro[2][playerid], -1);
	PlayerTextDrawSetOutline(playerid,TextdrawRegistro[2][playerid], 0);
	PlayerTextDrawSetProportional(playerid,TextdrawRegistro[2][playerid], 1);
	PlayerTextDrawSetShadow(playerid,TextdrawRegistro[2][playerid], 1);
	PlayerTextDrawUseBox(playerid,TextdrawRegistro[2][playerid], 1);
	PlayerTextDrawBoxColor(playerid,TextdrawRegistro[2][playerid], -86);
	PlayerTextDrawTextSize(playerid,TextdrawRegistro[2][playerid], 146.000000, -53.000000);
	PlayerTextDrawSetSelectable(playerid,TextdrawRegistro[2][playerid], 0);

	TextdrawRegistro[3][playerid] = CreatePlayerTextDraw(playerid,7.000000, 287.000000, "_");
	PlayerTextDrawBackgroundColor(playerid,TextdrawRegistro[3][playerid], 255);
	PlayerTextDrawFont(playerid,TextdrawRegistro[3][playerid], 1);
	PlayerTextDrawLetterSize(playerid,TextdrawRegistro[3][playerid], 0.679999, 2.799999);
	PlayerTextDrawColor(playerid,TextdrawRegistro[3][playerid], -1);
	PlayerTextDrawSetOutline(playerid,TextdrawRegistro[3][playerid], 0);
	PlayerTextDrawSetProportional(playerid,TextdrawRegistro[3][playerid], 1);
	PlayerTextDrawSetShadow(playerid,TextdrawRegistro[3][playerid], 1);
	PlayerTextDrawUseBox(playerid,TextdrawRegistro[3][playerid], 1);
	PlayerTextDrawBoxColor(playerid,TextdrawRegistro[3][playerid], 852308735);
	PlayerTextDrawTextSize(playerid,TextdrawRegistro[3][playerid], 78.000000, -34.000000);
	PlayerTextDrawSetSelectable(playerid,TextdrawRegistro[3][playerid], 0);

	TextdrawRegistro[4][playerid] = CreatePlayerTextDraw(playerid,167.000000, 287.000000, "_");
	PlayerTextDrawBackgroundColor(playerid,TextdrawRegistro[4][playerid], 255);
	PlayerTextDrawFont(playerid,TextdrawRegistro[4][playerid], 1);
	PlayerTextDrawLetterSize(playerid,TextdrawRegistro[4][playerid], 0.679999, 2.799999);
	PlayerTextDrawColor(playerid,TextdrawRegistro[4][playerid], -1);
	PlayerTextDrawSetOutline(playerid,TextdrawRegistro[4][playerid], 0);
	PlayerTextDrawSetProportional(playerid,TextdrawRegistro[4][playerid], 1);
	PlayerTextDrawSetShadow(playerid,TextdrawRegistro[4][playerid], 1);
	PlayerTextDrawUseBox(playerid,TextdrawRegistro[4][playerid], 1);
	PlayerTextDrawBoxColor(playerid,TextdrawRegistro[4][playerid], -16776961);
	PlayerTextDrawTextSize(playerid,TextdrawRegistro[4][playerid], 95.000000, -11.000000);
	PlayerTextDrawSetSelectable(playerid,TextdrawRegistro[4][playerid], 0);

	TextdrawRegistro[5][playerid] = CreatePlayerTextDraw(playerid,36.000000, 44.000000, "Servidor");
	PlayerTextDrawBackgroundColor(playerid,TextdrawRegistro[5][playerid], 255);
	PlayerTextDrawFont(playerid,TextdrawRegistro[5][playerid], 3);
	PlayerTextDrawLetterSize(playerid,TextdrawRegistro[5][playerid], 0.620000, 2.599999);
	PlayerTextDrawColor(playerid,TextdrawRegistro[5][playerid], -1);
	PlayerTextDrawSetOutline(playerid,TextdrawRegistro[5][playerid], 1);
	PlayerTextDrawSetProportional(playerid,TextdrawRegistro[5][playerid], 1);
	PlayerTextDrawSetSelectable(playerid,TextdrawRegistro[5][playerid], 0);

	TextdrawRegistro[6][playerid] = CreatePlayerTextDraw(playerid,49.000000, 56.000000, "Roleplay");
	PlayerTextDrawBackgroundColor(playerid,TextdrawRegistro[6][playerid], 255);
	PlayerTextDrawFont(playerid,TextdrawRegistro[6][playerid], 0);
	PlayerTextDrawLetterSize(playerid,TextdrawRegistro[6][playerid], 0.620000, 2.599999);
	PlayerTextDrawColor(playerid,TextdrawRegistro[6][playerid], -1);
	PlayerTextDrawSetOutline(playerid,TextdrawRegistro[6][playerid], 1);
	PlayerTextDrawSetProportional(playerid,TextdrawRegistro[6][playerid], 1);
	PlayerTextDrawSetSelectable(playerid,TextdrawRegistro[6][playerid], 0);

	TextdrawRegistro[7][playerid] = CreatePlayerTextDraw(playerid,85.000000, 122.000000, "Nome_Sobrenome");
	PlayerTextDrawAlignment(playerid,TextdrawRegistro[7][playerid], 2);
	PlayerTextDrawBackgroundColor(playerid,TextdrawRegistro[7][playerid], 255);
	PlayerTextDrawFont(playerid,TextdrawRegistro[7][playerid], 2);
	PlayerTextDrawLetterSize(playerid,TextdrawRegistro[7][playerid], 0.190000, 1.600000);
	PlayerTextDrawColor(playerid,TextdrawRegistro[7][playerid], -1);
	PlayerTextDrawSetOutline(playerid,TextdrawRegistro[7][playerid], 1);
	PlayerTextDrawSetProportional(playerid,TextdrawRegistro[7][playerid], 1);
	PlayerTextDrawSetSelectable(playerid,TextdrawRegistro[7][playerid], 0);

	TextdrawRegistro[8][playerid] = CreatePlayerTextDraw(playerid,84.000000, 195.000000, "Senha");
	PlayerTextDrawAlignment(playerid,TextdrawRegistro[8][playerid], 2);
	PlayerTextDrawBackgroundColor(playerid,TextdrawRegistro[8][playerid], 255);
	PlayerTextDrawFont(playerid,TextdrawRegistro[8][playerid], 2);
	PlayerTextDrawLetterSize(playerid,TextdrawRegistro[8][playerid], 0.190000, 1.600000);
	PlayerTextDrawColor(playerid,TextdrawRegistro[8][playerid], -1);
	PlayerTextDrawSetOutline(playerid,TextdrawRegistro[8][playerid], 1);
	PlayerTextDrawSetProportional(playerid,TextdrawRegistro[8][playerid], 1);
	PlayerTextDrawSetSelectable(playerid,TextdrawRegistro[8][playerid], 1);
	PlayerTextDrawTextSize(playerid, TextdrawRegistro[8][playerid], 18.000000, 18.000000);

	TextdrawRegistro[9][playerid] = CreatePlayerTextDraw(playerid,41.000000, 292.000000, "Entrar");
	PlayerTextDrawAlignment(playerid,TextdrawRegistro[9][playerid], 2);
	PlayerTextDrawBackgroundColor(playerid,TextdrawRegistro[9][playerid], 255);
	PlayerTextDrawFont(playerid,TextdrawRegistro[9][playerid], 2);
	PlayerTextDrawLetterSize(playerid,TextdrawRegistro[9][playerid], 0.190000, 1.600000);
	PlayerTextDrawColor(playerid,TextdrawRegistro[9][playerid], -1);
	PlayerTextDrawSetOutline(playerid,TextdrawRegistro[9][playerid], 1);
	PlayerTextDrawSetProportional(playerid,TextdrawRegistro[9][playerid], 1);
	PlayerTextDrawSetSelectable(playerid,TextdrawRegistro[9][playerid], 1);
	PlayerTextDrawTextSize(playerid, TextdrawRegistro[9][playerid], 18.000000, 18.000000);

	TextdrawRegistro[10][playerid] = CreatePlayerTextDraw(playerid,132.000000, 292.000000, "Cancelar");
	PlayerTextDrawAlignment(playerid,TextdrawRegistro[10][playerid], 2);
	PlayerTextDrawBackgroundColor(playerid,TextdrawRegistro[10][playerid], 255);
	PlayerTextDrawFont(playerid,TextdrawRegistro[10][playerid], 2);
	PlayerTextDrawLetterSize(playerid,TextdrawRegistro[10][playerid], 0.190000, 1.600000);
	PlayerTextDrawColor(playerid,TextdrawRegistro[10][playerid], -1);
	PlayerTextDrawSetOutline(playerid,TextdrawRegistro[10][playerid], 1);
	PlayerTextDrawSetProportional(playerid,TextdrawRegistro[10][playerid], 1);
	PlayerTextDrawSetSelectable(playerid,TextdrawRegistro[10][playerid], 1);
	PlayerTextDrawTextSize(playerid, TextdrawRegistro[10][playerid], 18.000000, 18.000000);

	TextdrawRegistro[11][playerid] = CreatePlayerTextDraw(playerid,178.000000, 395.000000, "_");
	PlayerTextDrawBackgroundColor(playerid,TextdrawRegistro[11][playerid], 255);
	PlayerTextDrawFont(playerid,TextdrawRegistro[11][playerid], 2);
	PlayerTextDrawLetterSize(playerid,TextdrawRegistro[11][playerid], 0.190000, 1.600000);
	PlayerTextDrawColor(playerid,TextdrawRegistro[11][playerid], -16776961);
	PlayerTextDrawSetOutline(playerid,TextdrawRegistro[11][playerid], 1);
	PlayerTextDrawSetProportional(playerid,TextdrawRegistro[11][playerid], 1);
	PlayerTextDrawSetSelectable(playerid,TextdrawRegistro[11][playerid], 0);
	return 1;
}

stock MensagemErrorRegistro(playerid, const text[])
{
	PlayerTextDrawSetString(playerid, TextdrawRegistro[11][playerid], text);
	PlayerTextDrawShow(playerid, TextdrawRegistro[11][playerid]);
	PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
	SelectTextDraw(playerid, COR_VERMELHO2);
	return SetTimerEx("QuebrarTextRegister", 5000, false, "i", playerid);
}

stock PlayerName(playerid)
{
	new Nick[MAX_PLAYER_NAME];
	GetPlayerName(playerid, Nick, sizeof(Nick));
	return Nick;
}

stock LimparChat(playerid, linhas)
{
	for(new a = 0; a <= linhas; a++) 
	{
		SendClientMessage(playerid, -1, "");
	}
	return 1;
}