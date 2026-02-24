#include <open.mp>

#define FIELD_TYPE_INT 1
#define FIELD_TYPE_FLOAT 2
#define FIELD_TYPE_STRING 3

enum E_PLAYER_DATA_META
{
    PD_META_SQL_NAME[12],
    PD_META_TYPE,
    PD_META_SIZE,
    PD_META_OFFSET
}

enum E_PLAYER_DATA_NAME
{
    PLAYER_VAR_1,      
    PLAYER_VAR_2,      
    Float:PLAYER_VAR_3,
    PLAYER_VAR_4,      
    PLAYER_VAR_5[31],  
    PLAYER_VAR_6,      
    PLAYER_VAR_7[27],
    PLAYER_VAR_8,
    PLAYER_VAR_9,
    Float:PLAYER_VAR_10,
    Float:PLAYER_VAR_11,
    PLAYER_VAR_12,
    Float:PLAYER_VAR_13,
    PLAYER_VAR_14[48]
};

enum {
    PLAYER_DATA_FIELD_VAR_1 = 0,
    PLAYER_DATA_FIELD_VAR_2,
    PLAYER_DATA_FIELD_VAR_3,
    PLAYER_DATA_FIELD_VAR_4,
    PLAYER_DATA_FIELD_VAR_5,
    PLAYER_DATA_FIELD_VAR_6,
    PLAYER_DATA_FIELD_VAR_7,
    PLAYER_DATA_FIELD_VAR_8,
    PLAYER_DATA_FIELD_VAR_9,
    PLAYER_DATA_FIELD_VAR_10,
    PLAYER_DATA_FIELD_VAR_11,
    PLAYER_DATA_FIELD_VAR_12,
    PLAYER_DATA_FIELD_VAR_13,
    PLAYER_DATA_FIELD_VAR_14,
    MAX_FIELDS
};

static gsc_PlayerDataMeta[MAX_FIELDS][E_PLAYER_DATA_META] =
{
    {"var1", FIELD_TYPE_INT, 1, _:PLAYER_VAR_1},
    {"var2", FIELD_TYPE_INT, 1, _:PLAYER_VAR_2},
    {"var3", FIELD_TYPE_FLOAT, 1, _:PLAYER_VAR_3},
    {"var4", FIELD_TYPE_INT, 1, _:PLAYER_VAR_4},
    {"var5", FIELD_TYPE_STRING, 31, _:PLAYER_VAR_5},
    {"var6", FIELD_TYPE_INT, 1, _:PLAYER_VAR_6},
    {"var7", FIELD_TYPE_STRING, 27, _:PLAYER_VAR_7},
    {"var8", FIELD_TYPE_INT, 1, _:PLAYER_VAR_8},
    {"var9", FIELD_TYPE_INT, 1, _:PLAYER_VAR_9},
    {"var10", FIELD_TYPE_STRING, 32, _:PLAYER_VAR_10},
    {"var11", FIELD_TYPE_FLOAT, 1, _:PLAYER_VAR_11},
    {"var12", FIELD_TYPE_INT, 1, _:PLAYER_VAR_12},
    {"var13", FIELD_TYPE_FLOAT, 1, _:PLAYER_VAR_13},
    {"var14", FIELD_TYPE_STRING, 48, _:PLAYER_VAR_14}
};

static gs_PlayerData[MAX_PLAYERS][E_PLAYER_DATA_NAME];

#define _BITSET_CELL_SHIFT    (5)
#define _BITSET_CELL_SIZE     (1 << _BITSET_CELL_SHIFT) // 32
#define _BITSET_CELL_MASK     (_BITSET_CELL_SIZE - 1)   // 31

static gs_PlayerDataDirty[MAX_PLAYERS][(MAX_FIELDS + _BITSET_CELL_MASK) >>> _BITSET_CELL_SHIFT];

stock Player_SetInt(playerid, field, value)
{
    new offset = gsc_PlayerDataMeta[field][PD_META_OFFSET];
    gs_PlayerData[playerid][E_PLAYER_DATA_NAME:offset] = value;
    gs_PlayerDataDirty[playerid][field >>> _BITSET_CELL_SHIFT] |= (1 << (field & _BITSET_CELL_MASK));
}

stock Player_SetFloat(playerid, field, Float:value)
{
    new offset = gsc_PlayerDataMeta[field][PD_META_OFFSET];
    gs_PlayerData[playerid][E_PLAYER_DATA_NAME:offset] = _:value;
    gs_PlayerDataDirty[playerid][field >>> _BITSET_CELL_SHIFT] |= (1 << (field & _BITSET_CELL_MASK));
}

stock Player_SetString(playerid, field, const value[])
{
    new offset = gsc_PlayerDataMeta[field][PD_META_OFFSET];
    format(gs_PlayerData[playerid][E_PLAYER_DATA_NAME:offset], gsc_PlayerDataMeta[field][PD_META_SIZE], "%s", value);
    gs_PlayerDataDirty[playerid][field >>> _BITSET_CELL_SHIFT] |= (1 << (field & _BITSET_CELL_MASK));
}

stock Player_Save(playerid)
{
    new query[1024];
    new tmp[128];
    new bool:first = true;

    strcat(query, "UPDATE players SET ");

    for(new i = 0; i < MAX_FIELDS; i++)
    {
        new cell = i >>> _BITSET_CELL_SHIFT;
        new bit = (1 << (i & _BITSET_CELL_MASK));
        if(gs_PlayerDataDirty[playerid][cell] & bit)
        {
            if(!first) strcat(query, ",");
            first = false;
            new offset = gsc_PlayerDataMeta[i][PD_META_OFFSET];
            switch(gsc_PlayerDataMeta[i][PD_META_TYPE])
            {
                case FIELD_TYPE_INT: format(tmp, sizeof(tmp), "`%s`='%d'", gsc_PlayerDataMeta[i][PD_META_SQL_NAME], gs_PlayerData[playerid][E_PLAYER_DATA_NAME:offset]);
                case FIELD_TYPE_FLOAT: format(tmp, sizeof(tmp), "`%s`='%f'", gsc_PlayerDataMeta[i][PD_META_SQL_NAME], gs_PlayerData[playerid][E_PLAYER_DATA_NAME:offset]);
                case FIELD_TYPE_STRING: format(tmp, sizeof(tmp), "`%s`='%s'", gsc_PlayerDataMeta[i][PD_META_SQL_NAME], gs_PlayerData[playerid][E_PLAYER_DATA_NAME:offset]); // SQL 注入风险 介入 mysql_escape_string
            }
            strcat(query, tmp);
            gs_PlayerDataDirty[playerid][cell] &= ~bit;
        }
    }
    if(first) return print("没有数据需要保存.");
    format(tmp, sizeof(tmp), " WHERE player_id = %d", playerid);
    strcat(query, tmp);

    printf("%s", query);
    return 1;
}

main(){}

public OnGameModeInit()
{

    Player_SetString(0, PLAYER_DATA_FIELD_VAR_14, "你好 世界!!");
    Player_SetInt(0, PLAYER_DATA_FIELD_VAR_6, 56);
    Player_SetFloat(0, PLAYER_DATA_FIELD_VAR_3, 3.14);
    Player_SetString(0, PLAYER_DATA_FIELD_VAR_5, "Hello World!!");
    Player_SetInt(0, PLAYER_DATA_FIELD_VAR_9, 568);

    Player_Save(0);

    // 再保存一下测试会不会重复保存
    Player_Save(0);

    return 1;
}
