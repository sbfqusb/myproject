--
-- Author: Your Name
-- Date: 2016-01-20 14:24:59
--

local UIDataList = require("app.views.UIData");

eUIScene = 
{
	Bottom = 1,
	Second = 2,
	Third = 3;
	Top = 4
}

local GameScene = class("GameScene", function()
    return display.newScene("GameScene")
end)

function GameScene:ctor()
	self:onNodeEvent("enter", handler(self, self.onEnter));
	self:onNodeEvent("exit", handler(self, self.onExit));
	cc(self):addComponent("components.behavior.EventProtocol"):exportMethods();

	self.bottomLayer = cc.Layer:create();
	self.secondLayer = cc.Layer:create();
	self.thirdLayer = cc.Layer:create();
	self.topLayer = cc.Layer:create();

	self:addChild( self.bottomLayer );
	self:addChild( self.secondLayer );
	self:addChild( self.thirdLayer );
	self:addChild( self.topLayer );

	self.UIShowList = {};

end

function GameScene:onEnter()
end

function GameScene:onExit()
end

function GameScene:onAddUI( uiData )
	-- body
	local UIType = uiData.cfg.UIType;
	local root = uiData.ui;
	if UIType == eUIScene.Bottom then
		--todo
		self.bottomLayer:addChild(root);
	elseif UIType == eUIScene.Second then
		self.secondLayer:addChild(root);
	elseif UIType == eUIScene.Third then
		self.thirdLayer:addChild(root);
	elseif UIType == eUIScene.Top then
		self.topLayer:addChild(root);
	end

	local uiZorder = uiData.cfg.Zorder;
	if uiZorder ~=0  then
		--todo
		root:setLocalZOrder(uiZorder)
	end
	
	uiData.ui:onAdd( self );
	uiData.ui:onShow();
	table.insert(self.UIShowList, uiData);
end

function GameScene:closeUI( type )
	-- body
	local uiData = self:getShowUIList(type);
	uiData.ui:onRemove();
	table.removebyvalue(self.UIShowList, uiData);

	local UIType = uiData.cfg.UIType;
	local root = uiData.ui;
	if UIType == eUIScene.Bottom then
		--todo
		self.bottomLayer:removeChild(root);
	elseif UIType == eUIScene.Second then
		self.secondLayer:removeChild(root);
	elseif UIType == eUIScene.Third then
		self.thirdLayer:removeChild(root);
	elseif UIType == eUIScene.Top then
		self.topLayer:removeChild(root);
	end
end

function GameScene:isShowTop( uiData )
	-- body
	if uiData then--该UI已经在显示列表了
		--todo
		if uiData == self.UIShowList[#self.UIShowList] then--是否在顶端
			--todo
			if not uiData.ui:isVisible() then
				uiData.ui:setVisible(true);
			end
			return true;
		end
	end
	return false;
end

function GameScene:showUI( type , ... )
	-- body
	local uiData,index = self:getShowUIList(type);
	if uiData then
		--todo
		if self:isShowTop(uiData) then--该UI已经在显示列表了
		--todo
			return;
		end
		local removeList = {}
		for i=index+1,#self.UIShowList do
			table.insert(removeList, self.UIShowList[i]);
		end
		for i,v in ipairs(removeList) do
			self:closeUI(v.ui.WigetType)
		end
		self.UIShowList[index]:setVisible(true);
		return;
	end

	local UiCfg = UIDataList[type];
	if not UiCfg then
		--todo
		printInfo(string.format("ui Type %s dosn't exsit",type));
		return;
	end

	local UiClass = _G[UiCfg.ClassName];
	if not UiClass then
		--todo
		require("app.views." .. UiCfg.ClassName)
		UiClass = _G[UiCfg.ClassName];
		if not UiClass then
			--todo
			printInfo(string.format("class %s dosn't exsit",UiCfg.ClassName));
			return;
		end
	end

	local ui = UiClass.new( ... );
	ui.WigetType = type;

	local UiCfg = {cfg = UiCfg,ui = ui}
	self:onAddUI(UiCfg)
	self:uiMutex(UiCfg)
	dump(self.UIShowList, "UIShowList")
end

function GameScene:getShowUIList( Type )
	-- body
	for i = #self.UIShowList, 1, -1 do
		local v = self.UIShowList[i];
		if v.ui.WigetType == Type then
			--todo
			return v,i;
		end
	end
	return nil;
end

function GameScene:uiMutex( uiData )
	-- body
	if uiData.cfg.Group ==0 then
		--todo
		return;
	end
	local idx = #self.UIShowList;
	if idx == 0 or idx == nil then
		--todo
		return;
	end
	repeat
		--todo
		repeat
			--todo
			local data = self.UIShowList[idx]
			if data.ui.WigetType == uiData.ui.WigetType or data.cfg.Group ~= uiData.cfg.Group then
				--todo
				break
			else
				self:closeUI(data.ui.WigetType)
			end
		until true
		idx = idx -1
	until idx == 0
end

return GameScene
