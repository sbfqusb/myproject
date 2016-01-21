Launcher = {}
-- 资源服务器url
Launcher.server = UPDATEURL
Launcher.serverIndex = 1;
Launcher.fListName = "flist"
Launcher.libDir = "lib/"
Launcher.lcherZipName = "launcher.zip"
Launcher.updateFilePostfix = ".upd"
--是否需要更新
Launcher.needUpdate = NEEDUPDATE;--android or ios update
Launcher.writablePath = cc.FileUtils:getInstance():getWritablePath()
--请求类型
Launcher.RequestType = { LAUNCHER = 0, FLIST = 1, RES = 2 }
--更新结果
Launcher.UpdateRetType = { SUCCESSED = 0, NETWORK_ERROR = 1, MD5_ERROR = 2, OTHER_ERROR = 3,APPVER_ERROR = 4 }


Launcher.PLATFORM_OS_WINDOWS = 0
Launcher.PLATFORM_OS_LINUX   = 1
Launcher.PLATFORM_OS_MAC     = 2
Launcher.PLATFORM_OS_ANDROID = 3
Launcher.PLATFORM_OS_IPHONE  = 4
Launcher.PLATFORM_OS_IPAD    = 5
Launcher.PLATFORM_OS_BLACKBERRY = 6
Launcher.PLATFORM_OS_NACL    = 7
Launcher.PLATFORM_OS_EMSCRIPTEN = 8
Launcher.PLATFORM_OS_TIZEN   = 9
Launcher.PLATFORM_OS_WINRT   = 10
Launcher.PLATFORM_OS_WP8     = 11

Launcher.PROGRESS_TIMER_BAR = 1
Launcher.PROGRESS_TIMER_RADIAL = 0

local sharedApplication = cc.Application:getInstance()
local sharedDirector = cc.Director:getInstance()
local target = sharedApplication:getTargetPlatform()
Launcher.platform    = "unknown"
Launcher.model       = "unknown"

if target == Launcher.PLATFORM_OS_WINDOWS then
    Launcher.platform = "windows"
elseif target == Launcher.PLATFORM_OS_MAC then
    Launcher.platform = "mac"
elseif target == Launcher.PLATFORM_OS_ANDROID then
    Launcher.platform = "android"
elseif target == Launcher.PLATFORM_OS_IPHONE or target == Launcher.PLATFORM_OS_IPAD then
    Launcher.platform = "ios"
    if target == Launcher.PLATFORM_OS_IPHONE then
        Launcher.model = "iphone"
    else
        Launcher.model = "ipad"
    end
elseif target == Launcher.PLATFORM_OS_WINRT then
    Launcher.platform = "winrt"
elseif target == Launcher.PLATFORM_OS_WP8 then
    Launcher.platform = "wp8"
end

if Launcher.platform == "android" then
    --TODO:这里需要修改成自己项目中java文件，这个文件实现lua调用java的方法
	Launcher.javaClassName = "org/cocos2dx/lua/AppActivity"
	Launcher.luaj = {}
	function Launcher.luaj.callStaticMethod(className, methodName, args, sig)
        return LuaJavaBridge.callStaticMethod(className, methodName, args, sig)
    end
elseif Launcher.platform == "ios" then
    --TODO:这里LuaObjcFun 是.mm 文件，实现lua调用oc方法
	Launcher.ocClassName = "AppController"
	Launcher.luaoc = {}
	function Launcher.luaoc.callStaticMethod(className, methodName, args)
	    local ok, ret = LuaObjcBridge.callStaticMethod(className, methodName, args)
	    if not ok then
	        local msg = string.format("luaoc.callStaticMethod(\"%s\", \"%s\", \"%s\") - error: [%s] ",
	                className, methodName, tostring(args), tostring(ret))
	        if ret == -1 then
	            print(msg .. "INVALID PARAMETERS")
	        elseif ret == -2 then
	            print(msg .. "CLASS NOT FOUND")
	        elseif ret == -3 then
	            print(msg .. "METHOD NOT FOUND")
	        elseif ret == -4 then
	            print(msg .. "EXCEPTION OCCURRED")
	        elseif ret == -5 then
	            print(msg .. "INVALID METHOD SIGNATURE")
	        else
	            print(msg .. "UNKNOWN")
	        end
	    end
	    return ok, ret
	end
end

function lcher_handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

function lcher_class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
            cls.ctor = function() end
        end

        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = {}
            setmetatable(cls, {__index = super})
            cls.super = super
        else
            cls = {ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end

function Launcher.hex(s)
	--return s;
    s = string.gsub(s,"(.)",function (x) return string.format("%02X",string.byte(x)) end)
    return s
end

function Launcher.fileExists(file)
    return cc.FileUtils:getInstance():isFileExist(file)
end

function Launcher.isDirectoryExist(path)
    return cc.FileUtils:getInstance():isDirectoryExist(path)
end

function Launcher.readFile(path)
	return cc.HelperFunc:getFileData(path);
end

function Launcher.writefile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end


function Launcher.removePath(path)
	if Launcher.isDirectoryExist(path) then
		cc.FileUtils:getInstance():removeDirectory(path);
	end
end

function Launcher.removeFile(file)
	if Launcher.fileExists(file) then
		cc.FileUtils:getInstance():removeFile(file);
	end
end

function Launcher.mkDir(path)
    if not Launcher.isDirectoryExist(path) then
		return cc.FileUtils:getInstance():createDirectory(path);
    end
    return true
end

function Launcher.doFile(path)
    local fileData = cc.HelperFunc:getFileData(path)
	if fileData==nil then
		return;
	end
    local fun = loadstring(fileData)
    local ret, flist = pcall(fun)
    if ret then
        return flist
    end

    return flist
end


function Launcher.fileDataMd5(fileData)
	if fileData ~= nil then
		return cc.Crypto:MD5(Launcher.hex(fileData), false)
	else
		return nil
	end
end

function Launcher.fileMd5(filePath)
	return cc.Crypto:MD5File(filePath);
end

function Launcher.checkFileDataWithMd5(data, cryptoCode)
	if cryptoCode == nil then
        return true
    end

    local fMd5 = cc.Crypto:MD5(Launcher.hex(data), false)
    if fMd5 == cryptoCode then
        return true
    end

    return false
end

function Launcher.checkFileWithMd5(filePath, cryptoCode)
	if not Launcher.fileExists(filePath) then
        return false
    end

	local fMd5 = Launcher.fileMd5(filePath);
	if fMd5 == cryptoCode then
        return true
    end

    return false
end

--获取app编译版本号
function Launcher.getAppVersionCode()
  --   local appVersion = 1;
  --   if Launcher.platform == "android" then
  --       local javaMethodName = "getAppVersionCode"
  --       local javaParams = { }
  --       local javaMethodSig = "()I"
  --       local ok, ret = Launcher.luaj.callStaticMethod(Launcher.javaClassName, javaMethodName, javaParams, javaMethodSig)
  --       if ok then
  --           appVersion = ret
		-- else
		-- 	printInfo("please implement getAppVersionCode method");
  --       end
  --       appVersion = SrcFlist.appVersion
  --   elseif Launcher.platform == "ios" then
  --       local ok, ret = Launcher.luaoc.callStaticMethod(Launcher.ocClassName, "getAppVersionCode")
  --       if ok then
  --           local var = string.split(ret, ".")
  --           appVersion = tonumber(var[1]);
		-- else
		-- 	printInfo("please implement getAppVersionCode method");
  --       end
  --   end
    return SrcFlist.appVersion;
end

function Launcher.initPlatform(callback)
    if Launcher.platform == "android" then
        local javaMethodName = "initPlatform"
        local javaParams = {
                callback
            }
        local javaMethodSig = "(I)V"
        Launcher.luaj.callStaticMethod(Launcher.javaClassName, javaMethodName, javaParams, javaMethodSig)
    elseif Launcher.platform == "ios" then
        local args = {
            callback = callback
        }
        Launcher.luaoc.callStaticMethod("LaoHuIAPSDKMgr", "initPlatform", args)
    else
        callback("1");--successed
    end
end

function Launcher.performWithDelayGlobal(listener, time)
	local scheduler = sharedDirector:getScheduler()
    local handle = nil
    handle = scheduler:scheduleScriptFunc(function()
        scheduler:unscheduleScriptEntry(handle)
        listener()
    end, time, false)
end

function Launcher.runWithScene(scene)
	local curScene = sharedDirector:getRunningScene()
	if curScene then
		sharedDirector:replaceScene(scene)
	else
		sharedDirector:runWithScene(scene)
	end
end

--test
-- local str = "W3N0cmluZyAiLlxhcHAvUmVzTG9hZE1nci5sdWEiXTo0MzogbW9kdWxlICdhcHAucHVibGljLkFyZW5hUGFja2V0dCcgbm90IGZvdW5kOgoJbm8gZmllbGQgcGFja2FnZS5wcmVsb2FkWydhcHAucHVibGljLkFyZW5hUGFja2V0dCddCglubyBmaWxlICcuXGFwcFxwdWJsaWNcQXJlbmFQYWNrZXR0Lmx1YScKCW5vIGZpbGUgJ0Q6XENsaWVudFxydW50aW1lXHdpbjMyXGx1YVxhcHBccHVibGljXEFyZW5hUGFja2V0dC5sdWEnCglubyBmaWxlICdEOlxDbGllbnRccnVudGltZVx3aW4zMlxsdWFcYXBwXHB1YmxpY1xBcmVuYVBhY2tldHRcaW5pdC5sdWEnCglubyBmaWxlICdEOi9DbGllbnQvcnVudGltZS93aW4zMi8uLi8uLi9zcmMvYXBwXHB1YmxpY1xBcmVuYVBhY2tldHQubHVhJwoJbm8gZmlsZSAnLlxhcHBccHVibGljXEFyZW5hUGFja2V0dC5kbGwnCglubyBmaWxlICdEOlxDbGllbnRccnVudGltZVx3aW4zMlxhcHBccHVibGljXEFyZW5hUGFja2V0dC5kbGwnCglubyBmaWxlICdEOlxDbGllbnRccnVudGltZVx3aW4zMlxsb2FkYWxsLmRsbCcKCW5vIGZpbGUgJy5cYXBwLmRsbCcKCW5vIGZpbGUgJ0Q6XENsaWVudFxydW50aW1lXHdpbjMyXGFwcC5kbGwnCglubyBmaWxlICdEOlxDbGllbnRccnVudGltZVx3aW4zMlxsb2FkYWxsLmRsbCcKc3RhY2sgdHJhY2ViYWNrOgoJW0NdOiBpbiBmdW5jdGlvbiAncmVxdWlyZScKCVtzdHJpbmcgIi5cYXBwL1Jlc0xvYWRNZ3IubHVhIl06NDM6IGluIGZ1bmN0aW9uIDxbc3RyaW5nICIuXGFwcC9SZXNMb2FkTWdyLmx1YSJdOjM1Pg==";
-- str = crypto.decodeBase64(str);
--end
local isFirstStart = cc.UserDefault:getInstance():getStringForKey("isfirst");
function Launcher.gameDataCollection(index,extra)
	--if device.platform == "windows" then
    do
        return;
    end

	local gameSize = display.sizeInPixels.width .. "x" .. display.sizeInPixels.height;
	local imei = device.getOpenUDID();
	extra = extra or "";
	if extra ~= "" then
		extra = crypto.encodeBase64(extra,string.len(extra));
--[[		extra = string.gsub(extra, "\'","")
		extra = string.gsub(extra, " ","_")
		extra = string.text2html(extra);
		extra = string.gsub(extra, " ","")--]]
	end
	local isFirst = "0";
	if isFirstStart == "" then
		isFirst = "1"
		cc.UserDefault:getInstance():setStringForKey("isfirst", "0");
		cc.UserDefault:getInstance():flush()
	end
	
	local verFile = nil
	local file = Launcher.writablePath .. "upd/" .. Launcher.fListName
    if Launcher.fileExists(file) then
        verFile = Launcher.doFile(file)
    else
        verFile = Launcher.doFile(Launcher.fListName)
    end
    
	local time = os.time()
	
	local function onRequestFinished(event)
		-- ToDo
		printInfo("gameDataCollection --- onRequestFinished --- "..event.name)
	end
	local url = "";
	if device.platform == "windows" then
		url = "http://192.168.3.248:8080/?"
	else
		url = "http://dldl.info.dkmol.cn/?"
	end
	local str = "model=&cpu=&memory=&mac=&os=%s&resolution=%s&simoperator=%s&network=&ip=&imei=%s&uuid=%s&appid=&client_ver=%s&step=%s&is_frist=%s&gid=&time_c=%s&ext=%s"

	local mStr = string.format(str,device.platform,gameSize,cc.Native:getDeviceName(),tostring(imei),tostring(imei),verFile.version,tostring(index),tostring(isFirst),os.date("%Y-%m-%d-%H:%M"),extra)
	local allStr = url..mStr
	local request = cc.HTTPRequest:createWithUrl(onRequestFinished, allStr, cc.kCCHTTPRequestMethodGET)
	
    request:setTimeout(10)
	request:start()
	printInfo("allStr:" .. allStr);

    --处理广告消息
    if device.platform == "ios" and isFirstStart == "" and USEOFFICIAL then
        local ok, idfa = Launcher.luaoc.callStaticMethod(Launcher.ocClassName, "getIDFA")
        local key = idfa .. "5e2e16c87d0d26abc12a57349f60e0e3";
        printInfo("key:" .. key);
        local sign = cc.Crypto:MD5(key,false);
        local url = "http://ads.yzjyqz.dkmol.cn/index.php?jq_type=clientNotify&sign=%s&idfa=%s";
        url = string.format(url,sign,idfa);
        printInfo("guanggaosend:" .. url);
        local request = cc.HTTPRequest:createWithUrl(function ( ... )
            -- body
        end, url, cc.kCCHTTPRequestMethodGET)
    
        request:setTimeout(10)
        request:start()
    end
	
end
