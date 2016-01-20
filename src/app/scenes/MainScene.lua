local GameScene = import(".GameScene")
local MainScene = class("MainScene", GameScene);
function MainScene:ctor()
	self.super.ctor(self);
    -- add background image
end

function MainScene:onEnter()
	printInfo("MainScene:onEnter")
	self.super.onEnter(self);
	
	self:showUI(eUI.UI_LOGIN)
end

function MainScene:onExit()
	printInfo("MainScene:onExit")
	self.super.onExit(self);
end

return MainScene
