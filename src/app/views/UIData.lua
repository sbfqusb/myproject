--
-- Author: Your Name
-- Date: 2016-01-20 16:22:47
--
eUI = 
{
	UI_LOGIN = 1;
	UI_MAIN = 2;
	UI_LEVELSELECTION = 3;
	UI_DIFFICULTYSELECTION = 4;
};

local UIData = 
{
	[eUI.UI_LOGIN] = {UIType = 1,UIName = "登录",Zorder = 0,ClassName = "LoginUI"},
	[eUI.UI_MAIN] = {UIType = 1,UIName = "主场景",Zorder = 0,ClassName = "MainUI"},
	[eUI.UI_LEVELSELECTION] = {UIType = 1,UIName = "副本章节选择",Zorder = 0,ClassName = "LevelSelection"},
	[eUI.UI_DIFFICULTYSELECTION] = {UIType = 1,UIName = "难度选择",Zorder = 0,ClassName = "DifficultySelection"},
};
return UIData;