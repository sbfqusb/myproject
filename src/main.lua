
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")


--=============================================================================
SrcFlist = nil;--基包资源列表
cc.FileUtils:getInstance():addSearchPath("res/")
local fileData = cc.HelperFunc:getFileData("flist")
if fileData then
	local fun = loadstring(fileData)
    local ret, flist = pcall(fun)
    if ret then
        SrcFlist = flist;
    end
end


local writablePath = cc.FileUtils:getInstance():getWritablePath() .. "upd/"
GameResPath ={--游戏加载的路径
	"src/",
	"res/",
	"res/test",
	"res/test/MainScene",
	"res/test/LevelSelection",
	"res/test/DifficultySelection",
};

function AddSearchPath( ... )
	-- body
	local searchPath = {};
	for i = 1,#GameResPath do
		local path = writablePath ..GameResPath[i];
		if cc.FileUtils:getInstance():isDirectoryExist(path) then
			table.insert(searchPath, path);
		end
	end
	for i = 1,#GameResPath do
		table.insert(searchPath, GameResPath[i] );
	end
	cc.FileUtils:getInstance():setSearchPaths(searchPath);
end

AddSearchPath();
--================================================================================


require "config"
require "cocos.init"
require "app.ModelList"

local function main()
	collectgarbage("setpause", 100) 
	collectgarbage("setstepmul", 5000)
    require("app.MyApp"):create():run()
end

function __G__TRACKBACK__(msg)
    local msg = debug.traceback(msg, 3)
	print("===================================");
    print(msg)
	-- if Launcher.gameDataCollection then
	-- 	Launcher.gameDataCollection(1000,msg);
	-- end
	print("===================================");
	if device.platform == "windows" or device.platform == "mac" then
		local function onButtonClicked(event)
	        if event.buttonIndex == 1 then
	            cc.Director:getInstance():endToLua()
	            if device.platform == "windows" or device.platform == "mac" then
	                os.exit()
	            end
	        else
	            printInfo("玩家选择了 NO 按钮")
	        end

	    end
	    device.showAlert("", "崩溃了：" .. msg, {"确定", "取消"}, onButtonClicked);
	end
    return msg
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end