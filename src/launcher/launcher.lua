package.loaded["launcher.launcherInit"] = nil
require("launcher.launcherInit")

local function enter_game()
	AddSearchPath();
	Launcher.gameDataCollection(2)
	require "appentry"
end

local function findUIObject( root,name,Type)
	-- body
	local  finctrl = {}
    finctrl = cc.utils.findChildren(finctrl,root,name);
    if Type ~= nil then
    	tolua.cast(finctrl[1],Type);
    end
    return finctrl;
end

local LauncherScene = lcher_class("LauncherScene", function()
	local scene = cc.Scene:create()
	scene.name = "LauncherScene"
    return scene
end)


function LauncherScene:ctor()
	self._path = Launcher.writablePath .. "upd/"
	
	local root = cc.CSLoader:createNode( "common_upgradeLayer.csb" )
	self:addChild( root );	
	self:fitUI(root);

	--find ctrl example
	local  finctrl = {}
	self.Root = findUIObject(root,"//Root" )[1];
	self.Label_err_msg = self.Root:getChildByName("Label_err_msg");
	self.Label_err_msg:setString("");
	local PanelRoot = self.Root:getChildByName("PanelRoot");
	self.Label_check_upgrade = PanelRoot:getChildByName("Label_check_upgrade");
	self.Label_game_init = PanelRoot:getChildByName("Label_game_init");

	self.Panel_inner_upgrade = PanelRoot:getChildByName("Panel_inner_upgrade");
	self.Label_download_desc = self.Panel_inner_upgrade:getChildByName("Label_download_desc");
	local Image_bar_back = self.Panel_inner_upgrade:getChildByName("Image_bar_back");
	self.ProgressBar_download = Image_bar_back:getChildByName("ProgressBar_download");
	self.Label_progress = Image_bar_back:getChildByName("Label_progress");
	self.Label_unzip_tip = Image_bar_back:getChildByName("Label_unzip_tip");
	self.Panel_inner_upgrade:setVisible(false);
	self.Label_game_init:setVisible(true);

	local effectfile = nil;
    local frameSize = cc.Director:getInstance():getVisibleSize()
    effectfile:setContentSize(frameSize)
    ccui.Helper:doLayout(effectfile)

	self.index = 0;
	self.Count = 0;

	self.requestForUdpate = false;
	self.dotTb = {" ." ," . ."," . . .",""};
	self.des = {"正在读取游戏信息",self.dotTb[1]};
	self.Label_game_init:setString(table.concat( self.des));

	self:onUpdate(handler(self, self.Update));

    Launcher.performWithDelayGlobal(function()
    	 if USEOFFICIAL == false then
			Launcher.initPlatform(lcher_handler(self, self._initPlatformResult))
		else
			self:_checkUpdate()
		end
    end, 1.5)

end

function LauncherScene:Update( tick )
	-- body
	self.Count = self.Count + tick;
	if self.Label_game_init:isVisible() ==true and self.Count>0.25 then
		self.index = self.index%4+1;
		self.des = {"正在读取游戏信息",self.dotTb[self.index] or ""};
		self.Label_game_init:setString(table.concat( self.des));
		self.Count = 0;
	end

end

function LauncherScene:_initPlatformResult(message)
	if message == "1" then
		--启动更新逻辑
		self:_checkUpdate()
		Launcher.gameDataCollection(1)
	else
		--TODO::初始化平台失败
		self:ShowMsgBox("初始化平台失败,请重新启动游戏",function ( ... )
			-- body
			cc.Director:getInstance():endToLua();
		end)
	end
end

function LauncherScene:fitUI( ctrl )
	-- body
    ctrl:setContentSize(display.size)
    ccui.Helper:doLayout(ctrl);	
end

function LauncherScene:_checkUpdate()
	self.requestForUdpate = true;

	if not Launcher.needUpdate then--跳过更新
		enter_game();
		return;
	end

	Launcher.mkDir(self._path)

	self._curListFile =  self._path .. Launcher.fListName
	if Launcher.fileExists(self._curListFile) then
        self._fileList = Launcher.doFile(self._curListFile)
    end

    if self._fileList ~= nil then
		if self:checkAppVersion(self._fileList.appVersion) == false then
			return;
		end
    else
    	self._fileList = Launcher.doFile(Launcher.fListName)
    end

    if self._fileList == nil then
    	self._updateRetType = Launcher.UpdateRetType.OTHER_ERROR
    	self:_endUpdate()
		return;
    end
	
	if SrcFlist ~= nil then
		if self:compareVersion(SrcFlist.version,self._fileList.version) == 2 then--处理覆盖安装后清除已下载资源
			Launcher.removePath(self._path);
			package.loaded["main"] = nil
			require "main";
			return;
		end
	end
	local flistName = ""
	if ISDKM_PACKAGE then
		flistName = Launcher.fListName .."?timestamp=" .. os.time();
	else
		flistName = Launcher.fListName;
	end
    --self:_requestFromServer(Launcher.libDir .. Launcher.lcherZipName, Launcher.RequestType.LAUNCHER, 30)
	self:_requestFromServer(flistName, Launcher.RequestType.FLIST)
end

function LauncherScene:compareVersion(ver1,ver2)--0:相等1:小于2:大于
	if ver1 == ver2 then
		return 0;
	end
	local ver1Tb = string.split(ver1,".");
	local ver2Tb = string.split(ver2,".");
	local function comarenum(num1,numb2)
		if num1 > numb2 then
			return 2;
		elseif num1 < numb2 then
			return 1;
		else
			return 0;
		end
	end
	local value = comarenum(tonumber(ver1Tb[1]),tonumber(ver2Tb[1]));
	if value ~= 0 then
		return value;
	end
	value = comarenum(tonumber(ver1Tb[2]),tonumber(ver2Tb[2]));
	if value ~= 0 then
		return value;
	end
	value = comarenum(tonumber(ver1Tb[3]),tonumber(ver2Tb[3]));
	if value ~= 0 then
		return value;
	end
	return 0;
end

function LauncherScene:checkAppVersion(version)--检查编译版本
   local appVersionCode = Launcher.getAppVersionCode()
	if appVersionCode ~= version then
		if appVersionCode < version then
			self._updateRetType = Launcher.UpdateRetType.APPVER_ERROR;
		else
			self._updateRetType = Launcher.UpdateRetType.SUCCESSED;
			
		end
		--新的app已经更新需要删除upd/目录下的所有文件
		Launcher.removePath(self._path)
		self:_endUpdate();
		return false;
	end
	return true;
end

-- 对应不同错误作出不同的提示
function LauncherScene:_endUpdate()
	if self._updateRetType ~= Launcher.UpdateRetType.SUCCESSED then
		printInfo("update errorCode = %d", self._updateRetType)
		
		--Launcher.removeFile(self._curListFile)
		Launcher.serverIndex = 1;
		local retType = self.__updateRetType;
		if self._updateRetType == Launcher.UpdateRetType.NETWORK_ERROR then
			self:ShowMsgBox("连接更新服务器失败,重试！",handler(self,self._checkUpdate));
		elseif self._updateRetType == Launcher.UpdateRetType.MD5_ERROR then
			self:ShowMsgBox("文件验证失败,请重新启动游戏!");
		elseif self._updateRetType == Launcher.UpdateRetType.OTHER_ERROR then
			self:ShowMsgBox("_fileList 文件不存在");
		elseif self._updateRetType == Launcher.UpdateRetType.APPVER_ERROR then
			self:ShowMsgBox("当前APP版本太低请重新去渠道更新",function ( ... )
				-- body
				cc.Director:getInstance():endToLua();
			end);
		end
		return;
	end

	enter_game()
end

function LauncherScene:_requestFromServer(filename, requestType, waittime)
	printInfo("Launcher.serverIndex:" ..  Launcher.serverIndex )
	local url = "";
	-- if ISDKM_PACKAGE then
	-- 	url = Launcher.server[Launcher.serverIndex] .. filename .."?timestamp=" .. os.time();
	-- else
	-- 	url = Launcher.server[Launcher.serverIndex] .. filename;
	-- end
	url = Launcher.server[Launcher.serverIndex] .. filename;
	self.filename = filename
	self.requestType = requestType
	self.waittime = waittime

    if Launcher.needUpdate then
        local request = cc.HTTPRequest:createWithUrl(function(event) 
        	self:_onResponse(event, requestType)
        end, url, cc.kCCHTTPRequestMethodGET)

        if request then
        	request:setTimeout(waittime or 10)
        	request:start()
    	else
    		--初始化网络错误
    		self._updateRetType = UpdateRetType.NETWORK_ERROR
        	self:_endUpdate()
    	end
    else
    	--不更新
    	enter_game()
    end
end

function LauncherScene:_onResponse(event, requestType)
    local request = event.request
    if event.name == "completed" then
        if request:getResponseStatusCode() ~= 200 then
            self._updateRetType = Launcher.UpdateRetType.NETWORK_ERROR
        	self:_endUpdate()
        else
            local dataRecv = request:getResponseData()
            if requestType == Launcher.RequestType.LAUNCHER then
            	self:_onLauncherPacakgeFinished(dataRecv)
            elseif requestType == Launcher.RequestType.FLIST then
            	self:_onFileListDownloaded(dataRecv)
            else
            	self:_onResFileDownloaded(dataRecv)
            end
        end
    elseif event.name == "progress" then
    	 if requestType == Launcher.RequestType.RES then
    	 	self:_onResProgress(event.dltotal)
    	 end
	elseif event.name == "failed" then
		Launcher.serverIndex = Launcher.serverIndex + 1;
		if Launcher.serverIndex > #UPDATEURL then
			self._updateRetType = Launcher.UpdateRetType.NETWORK_ERROR
        	self:_endUpdate()
		else
			self:_requestFromServer(self.filename, self.requestType,self.waittime);
		end
		
    else
        self._updateRetType = Launcher.UpdateRetType.NETWORK_ERROR
        self:_endUpdate()
    end
end

function LauncherScene:_onLauncherPacakgeFinished(dataRecv)
	Launcher.mkDir(self._path .. Launcher.libDir)
	local localmd5 = nil
	local localPath = self._path .. Launcher.libDir .. Launcher.lcherZipName
	if not Launcher.fileExists(localPath) then
		localPath = Launcher.libDir .. Launcher.lcherZipName
	end
		
	localmd5 = Launcher.fileMd5(localPath)

	local downloadMd5 =  Launcher.fileDataMd5(dataRecv)

	if downloadMd5 ~= localmd5 then
		Launcher.writefile(self._path .. Launcher.libDir .. Launcher.lcherZipName, dataRecv)
        require("main")
    else
    	self:_requestFromServer(Launcher.fListName, Launcher.RequestType.FLIST)
    end
end

function LauncherScene:_onFileListDownloaded(dataRecv)
	self._newListFile = self._curListFile .. Launcher.updateFilePostfix
	Launcher.writefile(self._newListFile, dataRecv)
	self._fileListNew = Launcher.doFile(self._newListFile)
	if self._fileListNew == nil or self._fileListNew.appVersion == nil then

        self._updateRetType = Launcher.UpdateRetType.NETWORK_ERROR
		self:_endUpdate()
		return
	end

	if self:checkAppVersion(self._fileListNew.appVersion) == false then
		return;
	end
	printInfo("===========================");
	printInfo(self._fileListNew.version);
	printInfo(self._fileList.version);
	printInfo("===========================");
	if self._fileListNew.version == self._fileList.version then
		Launcher.removeFile(self._newListFile)
		self._updateRetType = Launcher.UpdateRetType.SUCCESSED
		self:_endUpdate()
		return
	end
	
	self.Panel_inner_upgrade:setVisible(true);
	self.Label_game_init:setVisible(false);
	local ver1 = self._fileList.version or 0;
	local ver2 = self._fileListNew.version or 0;
	self.Label_download_desc:setString(ver1 .. "-" .. ver2);

	--创建资源目录
	local dirPaths = self._fileListNew.dirPaths
    for i=1,#(dirPaths) do
        local isCreate = Launcher.mkDir(self._path..(dirPaths[i].name))
    end

    self:_updateNeedDownloadFiles()
    local str = "";
	print(self._needDownloadSize);
	if self._needDownloadSize == 0 then
		self._needDownloadSize = 1;
	end
--[[    if self._needDownloadSize>=1000*1000 then
    	str = string.format("本次需要更新%sM",math.floor(self._needDownloadSize/(1000*1000)));
    else--]]if self._needDownloadSize >= 1024 then
    	str = string.format("本次需要更新%skb",math.floor(self._needDownloadSize/1000));
    else
    	str = string.format("本次需要更新%skb",self._needDownloadSize);
    end

	self:ShowMsgBox(str,function ( ... )
		-- body
		self._numFileCheck = 0;
    	self:_reqNextResFile();
	end,function ( ... )
		-- body
		cc.Director:getInstance():endToLua();
	end,2);

end

function LauncherScene:_onResFileDownloaded(dataRecv)
	local fn = self._curFileInfo.name .. Launcher.updateFilePostfix
	Launcher.removeFile(self._path .. fn);
	Launcher.writefile(self._path .. fn, dataRecv)
	if Launcher.checkFileWithMd5(self._path .. fn, self._curFileInfo.code) then
		table.insert(self._downList, fn)
		self._hasDownloadSize = self._hasDownloadSize + self._curFileInfo.size
		self._hasCurFileDownloadSize = 0
		self:_reqNextResFile()
	else
		--文件验证失败
        self._updateRetType = Launcher.UpdateRetType.MD5_ERROR
    	self:_endUpdate()
	end
end

function LauncherScene:_onResProgress(dltotal)
	self._hasCurFileDownloadSize = dltotal
    self:_updateProgressUI()
end

function LauncherScene:IsNeedDown( obj )--最后判断这个文件是否需要下载（与基包比较）
	-- body
	if obj == nil then
		return;
	end
	if SrcFlist == nil or SrcFlist.fileInfoList[obj.name]== nil or (SrcFlist ~= nil and SrcFlist.fileInfoList[obj.name] and obj.code ~= SrcFlist.fileInfoList[obj.name].code) then
	    self._needDownloadSize = self._needDownloadSize + obj.size
		print(obj.name .. ":" .. obj.size);
	    table.insert(self._needDownloadFiles, obj)	
   	end
end

function LauncherScene:_updateNeedDownloadFiles()
	self._needDownloadFiles = {}
    self._needRemoveFiles = {}
    self._downList = {}
    self._needDownloadSize = 0
    self._hasDownloadSize = 0
    self._hasCurFileDownloadSize = 0

    local newFileInfoList = self._fileListNew.fileInfoList
    local oldFileInfoList = self._fileList.fileInfoList
	if SrcFlist~= nil then
		if SrcFlist.version == self._fileList.version then--没有更新过
			oldFileInfoList = {}
		end
	end

    local hasChanged = false
    for i=1, #(newFileInfoList) do
        hasChanged = false
        for k=1, #(oldFileInfoList) do
            if newFileInfoList[i].name == oldFileInfoList[k].name then
                hasChanged = true
                if newFileInfoList[i].code ~= oldFileInfoList[k].code then
                    local fn = newFileInfoList[i].name .. Launcher.updateFilePostfix
                    if Launcher.checkFileWithMd5(self._path .. fn, newFileInfoList[i].code) then
                        table.insert(self._downList, fn)
                    else
                        self._needDownloadSize = self._needDownloadSize + newFileInfoList[i].size
						print(fn .. ":" .. newFileInfoList[i].size);
                        table.insert(self._needDownloadFiles, newFileInfoList[i])
                        --self:IsNeedDown(newFileInfoList[i]);
                    end
                end
                table.remove(oldFileInfoList, k)
                break
            end
        end
        if hasChanged == false then
   --          self._needDownloadSize = self._needDownloadSize + newFileInfoList[i].size
			-- print(newFileInfoList[i].name .. ":" .. newFileInfoList[i].size);
   --          table.insert(self._needDownloadFiles, newFileInfoList[i])
			local fn = newFileInfoList[i].name .. Launcher.updateFilePostfix
            if Launcher.checkFileWithMd5(self._path .. fn, newFileInfoList[i].code) then
                table.insert(self._downList, fn)
            else
            	self:IsNeedDown(newFileInfoList[i]);
            end
        end
    end
    self._needRemoveFiles = oldFileInfoList

    print("self._needDownloadFiles count = " .. (#self._needDownloadFiles))
	print(" self._needDownloadSize = " ..  self._needDownloadSize)

end

function LauncherScene:_updateProgressUI()
	local curDownSize = (self._hasDownloadSize + self._hasCurFileDownloadSize) ;
	local downloadPro = curDownSize* 100 / (self._needDownloadSize)
	
	self.ProgressBar_download:setPercent(downloadPro)
	self.Label_progress:setString(string.format("%dkb / %dkb", curDownSize/1000,self._needDownloadSize/1000))
	
end

function LauncherScene:_reqNextResFile()
    self:_updateProgressUI()
    self._numFileCheck = self._numFileCheck + 1
    self._curFileInfo = self._needDownloadFiles[self._numFileCheck]
    if self._curFileInfo and self._curFileInfo.name then
    	self:_requestFromServer(self._curFileInfo.name, Launcher.RequestType.RES)
    else
		self.Label_progress:setString("文件处理中")
		Launcher.performWithDelayGlobal(function()
			self:_endAllResFileDownloaded()
		end,0.1)
    	--self:_endAllResFileDownloaded()
    end

end

function LauncherScene:_endAllResFileDownloaded()
	local data = Launcher.readFile(self._newListFile)
    Launcher.writefile(self._curListFile, data)
    self._fileList = Launcher.doFile(self._curListFile)
    if self._fileList == nil then
        self._updateRetType = Launcher.UpdateRetType.OTHER_ERROR
    	self:_endUpdate()
        return
    end

    Launcher.removeFile(self._newListFile)

    local offset = -1 - string.len(Launcher.updateFilePostfix)
    for i,v in ipairs(self._downList) do
        v = self._path .. v
        local data = Launcher.readFile(v)

        local fn = string.sub(v, 1, offset)
        Launcher.writefile(fn, data)
        Launcher.removeFile(v)
    end

    for i,v in ipairs(self._needRemoveFiles) do
        Launcher.removeFile(self._path .. (v.name))
    end

    self._updateRetType = Launcher.UpdateRetType.SUCCESSED
    self:_endUpdate()
end

function LauncherScene:ShowMsgBox( str,callback,cancelback,Type )
	-- body
	self.Type = Type or 1;
	if self.msgBox == nil then
		self.msgBox = cc.CSLoader:createNode( "common_NewMessageBox.csb" )
		self:addChild( self.msgBox,1);	
		self:fitUI(self.msgBox);
	end

	function lonTouch( event )
		local tag = event.target;
		if event.name == "ended" then
			if tag == self.BtnYes or tag == self.BtnOk then
				if callback ~= nil then
					callback();
				end
			elseif tag == self.BtnNo then
				if cancelback ~= nil then
					cancelback();
				end
			end
			self:closeMsgBox();
			--require "appentry"进入游戏
		end
	end
	self.bgImg = findUIObject(self.msgBox,"//ImageView_back")[1]
	self.BtnYes = findUIObject(self.bgImg,"//Button_yes","ccui.Button")[1]
	self.BtnYes:setPressedActionEnabled(true)
	self.BtnYes:setTag(1);
	self.BtnNo = findUIObject(self.bgImg,"//Button_no","ccui.Button")[1]
	self.BtnNo:setPressedActionEnabled(true)
	self.BtnNo:setTag(2);
	self.BtnOk = findUIObject(self.bgImg,"//Button_ok","ccui.Button")[1]
	self.BtnOk:setPressedActionEnabled(true)
	self.BtnNo:setTag(1);
	self.BtnOk:onTouch(lonTouch);
	self.BtnYes:onTouch(lonTouch);
	self.BtnNo:onTouch(lonTouch);

	self.BtnOk:setVisible(true);
	self.BtnYes:setVisible(true);
	self.BtnNo:setVisible(true);


	if self.Type == 2 then
		--todo
		self.BtnOk:setVisible(false);
	else
		--todo
		self.BtnYes:setVisible(false);
		self.BtnNo:setVisible(false);
		
	end
	self.Label_content = findUIObject(self.bgImg,"//Label_content","ccui.Label")[1]	
	self.bgImg:setPosition(cc.p(display.size.width/2, 0));
	self.msgBox:setVisible(true);
	self.Label_content:setString(str)

	self.bgImg:stopAllActions();
	local action1 = cc.MoveTo:create(1,cc.p(display.size.width/2,display.size.height/2))
	local action2 = cc.EaseElasticOut:create(action1);
	self.bgImg:runAction(action2)
end
function LauncherScene:closeMsgBox( ... )
	-- body
	if self.msgBox ~= nil then
		local action = cc.MoveTo:create(0.2,cc.p(display.size.width/2,display.size.height))
		self.bgImg:runAction(cc.Sequence:create(action,cc.CallFunc:create(function ( ... )
			-- body
			self.msgBox:setVisible(false);
		end)));
		
	end
end




local lchr = LauncherScene.new()
Launcher.runWithScene(lchr)