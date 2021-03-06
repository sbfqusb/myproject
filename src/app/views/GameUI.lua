--
-- Author: Your Name
-- Date: 2016-01-20 14:46:50
--

GameUI = class("GameUI",function (  )
	-- body
	return ccui.Layout:create();
end);


function GameUI:ctor( ... )
	-- body
	self.eventHandleList = {};

end

function GameUI:addUINode( node )
	-- body
	self:addChild(node);
	local frameSize = cc.Director:getInstance():getVisibleSize();
	node:setContentSize(frameSize);
	ccui.Helper:doLayout(node);
end

function GameUI:removeUINode( node )
	-- body
end

function GameUI:onRemove( ... )
	-- body
	self.eventProxy:removeAllEventListeners()
end

function GameUI:onShow( ... )
	-- body
end

function GameUI:onAdd( scene  )
	-- body
	self.scene = scene;
	self.eventProxy = cc.EventProxy.new(self.scene, self)
	--self.scene:addEventListener(WebSockets.OPEN_EVENT, handler(self, self.onOpen))
end

function GameUI:registerEvent( event,func )
	-- body
	local obj,handle = self.eventProxy:addEventListener(event,func);
	return handle
end

function GameUI:unRegisterEventByHandee( handle )
	-- body
	self.eventProxy:removeEventListener(handle);
end

function GameUI:dispatchEvent( eventName , ...)
	-- body
	local event = {name = eventName,params = ...};
	self.scene:dispatchEvent(event);
end


function GameUI:close( Type )
	-- body
	local closeType = Type or self.WigetType
	self.scene:closeUI(closeType)
end

function GameUI:showUI( Type , ... )
	-- body
	self.scene:showUI(Type , ...)
end
