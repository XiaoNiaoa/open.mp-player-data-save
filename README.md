# open.mp 玩家数据保存系统 全新框架实现

欢迎加入samp | open.mp 联机社区 QQ群:673335567

### 传统方式的痛点
- 99%的开源每次保存都要写几十个甚至上百个字段，数据库压力大、日志多、容易卡顿
- 查询语句到处散落，维护起来麻烦不直观，容易出现遗漏和问题
- 每次新增玩家数据都要修改数据库表结构，写大量的数据库字段 新增读取、保存、更新等多个相关函数等等

### 此框架优势
- 高级的现代优化方案
- 集中管理
- 使用简单、直观便捷
- 大量玩家数据也可以轻松拓展/维护
- 高效/安全/稳定
- 使用**位运算**实现**只保存真正修改过的字段** 零冗余保存
- 适合中大型服务器参考和二次开发

### 所有数据的保存方式只有三种
```pawn
// 设置数据
Player_SetInt(playerid, PLAYER_DATA_FIELD_VAR_84, 999);
Player_SetFloat(playerid, PLAYER_DATA_FIELD_VAR_167, 3.1415926);
Player_SetString(playerid, PLAYER_DATA_FIELD_VAR_194, "Hello GitHub!");

// 保存数据
Player_Save(playerid);
```

### 温馨提示

本仓库仅供学习参考 并非开箱即用，但后续可能会更新完善版的方案，因为是本人开发自用, 可以顺便更新上去，或者你们自己提交PR

字符串字段请自行使用 mysql_escape_string 或 %e 格式化

可以在设置数据的API加入是否同步保存的选项，比如:
```pawn
stock Player_SetInt(playerid, field, value, bool:save = false)
```

在MySQL查询语句执行成功之后再清除Dirty

可以新增自动检查MySQL表格是否完整、遗漏，无需人工维护
