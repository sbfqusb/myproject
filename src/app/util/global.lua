--
-- Author: Your Name
-- Date: 2016-01-22 11:41:03
--
module("global",package.seeall);
local director = cc.Director:getInstance()

function SendEvent( event, ... )--
	-- body
	local runingScene = director:getRunningScene();
	if runingScene then
		--todo
		local event = {name = eventName,params = ...};
		runingScene:dispatchEvent(event);
	end
end

function ShowUI( type, ... )--
	-- body
	local runingScene = director:getRunningScene();
	if runingScene then
		--todo
		runingScene:showUI( type , ... )
	end
end

function findUIObject( root,name,Type)
	-- body
	local  finctrl = {}
    finctrl = cc.utils.findChildren(finctrl,root,name);
    if Type ~= nil then
    	tolua.cast(finctrl[1],Type);
    end
    return finctrl;
end

function SaveKey(key,content)
	-- body
	if type(content) == "string" then
		cc.UserDefault:getInstance():setStringForKey(key,content);
	else
		cc.UserDefault:getInstance():setStringForKey(key, tostring(content));
	end
    cc.UserDefault:getInstance():flush()
end

function GetKey(key)
	-- body
	return  cc.UserDefault:getInstance():getStringForKey(key);
end


function removeArmatureData( file )
	-- body
	local manager = ccs.ArmatureDataManager:getInstance()
    manager:removeArmatureFileInfo(file);
end


-- 创建UI特效
function createUiEffect( effectName,index,callback )
	-- body
	local path = config.dirRes.effect .. effectName .. "/" .. effectName .. ".ExportJson";
	local fullpath = cc.FileUtils:getInstance():fullPathForFilename(path);
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(fullpath)
    local armature = ccs.Armature:create(effectName)
    armature:getAnimation():playWithIndex(index or 0);

    if callback then
		armature:getAnimation():setMovementEventCallFunc( function ( sender, eventType, name )
					if eventType == ccs.MovementEventType.complete then
						callback(armature);
					end				
				end );
	end
	
    return armature;
end

-- 播放ui特效
function playerUIEffect(armature, index, callback)
	armature:setVisible(true)
	armature:getAnimation():playWithIndex(index or 0)
	if callback then
		armature:getAnimation():setMovementEventCallFunc(function(sender, eventType, name)
			if eventType==ccs.MovementEventType.complete then
				callback()
				armature:setVisible(false)
			end
		end)
	end
end

function effectMovementEventCallFunc(armature,callback)
	armature:getAnimation():setMovementEventCallFunc( function ( sender, eventType, name )
			printInfo("effectMovementEventCallFunc "..eventType)
			if eventType == ccs.MovementEventType.complete then
				callback();
			end				
		end );
end

function replaceTextField( obj,isPassword,backImage )
	-- body
	if tolua.type(obj) == "ccui.EditBox" then
		return obj;
	end
	local size        = obj:getContentSize();
	local anchorPoint = obj:getAnchorPoint();
	--local pos         = obj:getPosition();
	local parent      = obj:getParent();
	local placeholder = obj:getPlaceHolder();
	local fontSize    = obj:getFontSize()

	if backImage == nil or backImage == "" then
		backImage = "regebg.png"
	end
 	local editbox = ccui.EditBox:create(size, backImage)
    editbox:setPosition(cc.p(obj:getPositionX(),obj:getPositionY()))
    editbox:setFontSize(fontSize)
   	editbox:setFontColor(cc.c4b(255,255,255,255))
    editbox:setPlaceHolder(placeholder)
    editbox:setPlaceholderFontColor(obj:getPlaceHolderColor())
    editbox:setPlaceholderFontSize(fontSize)
    editbox:setPlaceholderFontName(GAME_FONT);
    editbox:setFontName(GAME_FONT);
    if obj:getMaxLength()<1 then
    	editbox:setMaxLength(100)
    else
    	editbox:setMaxLength(obj:getMaxLength())
    end
    
    editbox:setAnchorPoint(anchorPoint);
    editbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE);
    if isPassword then
    	--editbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD);
    end

    editbox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
	--editbox:registerScriptEditBoxHandler(editBoxTextEventHandle)
    parent:addChild(editbox);
    editbox:setLocalZOrder( obj:getLocalZOrder() ) 
    obj:removeFromParent();
    return editbox;
end

function addTableView( panel )
	-- body
	local size = panel:getContentSize();
	local tableview = cc.TableView:create(size);
    tableview:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    tableview:setPosition(cc.p(0,0))
    tableview:setDelegate();
    tableview:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    panel:addChild(tableview)
    return tableview;
end

-- 弹出对话框动画
function popDialogBoxAni(ctrl, srcScale)
	srcScale = srcScale or 1
	local actArr = {
		[1] = cc.CallFunc:create(function()
			ctrl:setScale(0)
			ctrl:setVisible(true)
		end),
		[2] = cc.EaseBounceOut:create(cc.ScaleTo:create(0.8, srcScale)),
		[3] = cc.DelayTime:create(1),
		[4] = cc.ScaleTo:create(0.8, 0),
		[5] = cc.CallFunc:create(function()
			ctrl:setVisible(false)
		end),
	}
	local seq = cc.Sequence:create(actArr)
	ctrl:stopAllActions()
	ctrl:runAction(seq)
end


function AttachMsgBoxAni( ctrl,callback )--弹出框动画
	if ctrl == nil then
		return;
	end
	-- body

	local orgScale = ctrl:getScale();

	ctrl:setScale(orgScale * 0.8);
	local aniScale = cc.ScaleTo:create( 0.04, orgScale * 1.05 );
	local reverseAniScale = cc.ScaleTo:create( 0.08, orgScale );
	local seq = nil;
	if callback ~= nil then
		--todo
		seq = cc.Sequence:create( aniScale, reverseAniScale,cc.CallFunc:create(callback) )
	else
		--todo
		seq = cc.Sequence:create( aniScale, reverseAniScale )
	end
	ctrl:runAction(seq)
end

-- 关闭弹窗动画
function closeMsgBoxAni(hostUI, ctrl, callback)
	assert(hostUI and ctrl, "hostUI和ctrl不能为nil.")
	if type(callback)~="function" then 
		callback = function() end
	end
	local aniArr = {
		[1] = cc.Spawn:create(
			cc.ScaleTo:create(0.1, 0.2),
			cc.FadeOut:create(0.09)),
		[2] = cc.CallFunc:create(function()
			hostUI:close()
			callback()
		end),
	}
	ctrl:setAllChildrenOpacity(ctrl:getOpacity())
	local aniSeq = cc.Sequence:create(aniArr)
	ctrl:stopAllActions()
	ctrl:runAction(aniSeq)
end

function BlinkAni( ctrl,time )--一闪一闪动画
	-- body
	time = time or 1;
	local fadeIn = cc.FadeTo:create( time, 0 )
	local fadeOut = cc.FadeTo:create( time, 255 )
	local anim = cc.RepeatForever:create( cc.Sequence:create( fadeIn, fadeOut ) )
	ctrl:runAction(anim);
end

function UpAndDownAni(ctrl, time, offset)--上上下下动画
	offset = offset or 5
	time = time or 0.8;
	ctrl:stopAllActions( );
	if ctrl.pos == nil then
		ctrl.pos = cc.p(ctrl:getPosition());
	end
	ctrl:setPosition(cc.p(ctrl.pos.x,ctrl.pos.y));
	local pos = cc.p(ctrl:getPosition());
	local up = cc.MoveTo:create(time, cc.p(pos.x,pos.y+offset))
	local down = cc.MoveTo:create(time, cc.p(pos.x,pos.y-offset))
	local anim = cc.RepeatForever:create( cc.Sequence:create( up, down ) )
	ctrl:runAction(anim);
end

function UpAni(  ctrl,time )--反复上消失再上
	-- body
	time = time or 0.8;
	ctrl:stopAllActions( );
	if ctrl.pos == nil then
		ctrl.pos = cc.p(ctrl:getPosition());
	end
	ctrl:setPosition(cc.p(ctrl.pos.x,ctrl.pos.y));
	local pos = cc.p(ctrl:getPosition());
	local fadeOut = cc.FadeTo:create( 0.1, 255 )
	local up = cc.MoveTo:create(time, cc.p(pos.x,pos.y+5))
	local fadeIn = cc.FadeTo:create( 0.2, 0 )
	local down = cc.MoveTo:create(0, cc.p(pos.x,pos.y))

	local anim = cc.RepeatForever:create( cc.Sequence:create( fadeOut,up, fadeIn,down ) )
	ctrl:runAction(anim);	
end

function DownAni(  ctrl,time )--反复下消失再下
	-- body
	time = time or 0.8;
	ctrl:stopAllActions( );
	if ctrl.pos == nil then
		ctrl.pos = cc.p(ctrl:getPosition());
	end
	ctrl:setPosition(cc.p(ctrl.pos.x,ctrl.pos.y));
	local pos = cc.p(ctrl:getPosition());
	local fadeOut = cc.FadeTo:create( 0.1, 255 )
	local up = cc.MoveTo:create(time, cc.p(pos.x,pos.y-5))
	local fadeIn = cc.FadeTo:create( 0.2, 0 )
	local down = cc.MoveTo:create(0, cc.p(pos.x,pos.y))

	local anim = cc.RepeatForever:create( cc.Sequence:create( fadeOut,up, fadeIn,down ) )
	ctrl:runAction(anim);	
end


function ListViewFitNum( listview,datanum )--优化listview数据显示不要频繁创建item.
	-- body
	local size = listview:getChildrenCount();
	if size > datanum then
		local diff = size - datanum;
		for i=1,diff do
			listview:removeLastItem();
		end
	elseif size < datanum then
		local diff = datanum - size;
		for i=1,diff do
			listview:pushBackDefaultItem();
		end
	end
end

function PageViewFitNum( pageView,datanum,dataItemCtrl )--优化listview数据显示不要频繁创建item.
	-- body
	local size = pageView:getPageCount();
	if size > datanum then
		local diff = size - datanum;
		for i=1,diff do
			local count = pageView:getPageCount()
			pageView:removePageAtIndex(count-1);
		end
	elseif size < datanum then
		local diff = datanum - size;
		for i=1,diff do
			pageView:addPage(dataItemCtrl:clone());
		end
	end
end

--给定剩余时间格式化成:  00:00:00
function formatTime(sec)
    local hour=math.floor(sec/3600)
    local min=math.floor((sec-hour*3600)/60);
    local second=sec-hour*3600-min*60;
    local str=string.format("%02d:%02d:%02d",hour,min,second)
    return str
end

-- 格式化秒
function formatSection(sec)
	local function calculate(sec, feedrate)
		local integer = math.floor(sec/feedrate)
		local remainder = math.mod(sec, feedrate)
		return integer, remainder
	end

	local day, hour, min, second, remainder
	remainder = sec
	day, remainder = calculate(remainder, 86400)
	hour, remainder = calculate(remainder, 3600)
	min, remainder = calculate(remainder, 60)
	second, remainder = calculate(remainder, 1)

	return day, hour, min, second
end

-- 获取时间的格式化字符串
function getFormatDateStr(sec)
	local day, hour, min, second = formatSection(sec)
	local str = ""
	if day>0 then
		str = str .. tostring(day) .. "天"
	end
	if hour>0 then
		str = str .. tostring(hour) .. "时"
	end
	if min>0 then
		str = str .. tostring(min) .. "分"
	end
	if second>0 then
		str = str .. tostring(second) .. "秒"
	end
	return str
end

function breatheAni(ctrl, scale)--呼吸效果
	-- body
	if scale == nil then
		scale = 0.8;
	end
	ctrl:stopAllActions( );
	if ctrl.scale == nil then
		ctrl.scale = ctrl:getScale();
	end
	ctrl:setScale(ctrl.scale);
	local aniScale = cc.ScaleTo:create( 1, scale + 0.01 );
	local reverseAniScale = cc.ScaleTo:create( 1, scale );
	local seq = cc.Sequence:create( aniScale, reverseAniScale )
	ctrl:runAction( cc.RepeatForever:create( seq ) )
end

function cardTurnAni( inCard,outCard,callback )--卡牌翻转
	-- body
	local kRoundTime = 0.5;
	local kInAngleZ  = 270;
	local kInDeltaZ  = 90;
	local kOutAngleZ = 0;
	local kOutDeltaZ = 90;
	inCard:setVisible(false);
	outCard:setVisible(true);
	local seq0 = cc.Sequence:create( cc.DelayTime:create(kRoundTime),cc.Show:create(),
		cc.OrbitCamera:create(kRoundTime,1,0,kInAngleZ,kInDeltaZ,1,0),cc.CallFunc:create(callback));
	local seq1 = cc.Sequence:create(cc.OrbitCamera:create(kRoundTime,1,0,kOutAngleZ,kOutDeltaZ,1,0),
		cc.Hide:create(),cc.DelayTime:create(kRoundTime));
	inCard:runAction(seq0);
	outCard:runAction(seq1);
end


function guid( ... )--创建GUID
	-- body
	local seed = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'}
	local tb = {};
	for i = 1,32 do
		table.insert(tb,seed[math.random(1,16)])
	end
	local sid = table.concat(tb);
	return string.format('%s%s%s%s%s',
		string.sub(sid,1,8),
		string.sub(sid,9,12),
		string.sub(sid,13,16),
		string.sub(sid,17,20),
		string.sub(sid,21,32)
		)
end

function getSoundMP3( index )
	-- body
	return config.dirRes.sound .. index .. ".mp3";
end

-- 播放音效
function PlaySoundEffect( index ,loop)
	local file = getSoundMP3(index);
	if cc.FileUtils:getInstance():isFileExist(file) == true then
		return audio.playSound(file,loop);
	else
		printError("sound effect file:%s is not exist", file)
	end
	return;
end

-- 播放音乐
function PlayMusic( index,loop )
	-- body
	local file = getSoundMP3(index);
	if cc.FileUtils:getInstance():isFileExist(file) == true then
		return audio.playMusic(file, loop);	
	else
		printError("music file:%s is not exist", file)
	end
	return;
end

function createCircularClippingNode(radius)
	local draw = cc.DrawNode:create()
    draw:drawDot(cc.p(0, 0),radius, cc.c4f(0, 1, 0, 1))
	local node = cc.ClippingNode:create(draw);
	--node:setAlphaThreshold(0.05)
	return node;
end

--判断字符串是否包含特殊字符, specialChars默认为"`~!@#$%^&"
--用法：isStringContainSpecialChars("test%string", "`~!@#$%^&")
function isStringContainSpecialChars(str, specialChars)
	local defaultSpecialChars = "[%`%~%!%@%#%$%%%^%&]"
	if specialChars then
		local chars = "["
		local len = string.len(specialChars)
		for i = 1, len do
			chars = chars .. "%" .. string.sub(specialChars, i, i)
		end
		chars = chars .. "]"
		specialChars = chars
	else
		specialChars = defaultSpecialChars
	end
	return string.find(str, specialChars)
end