--
-- Author: Your Name
-- Date: 2016-01-20 20:53:47
--
MainUI = class("MainUI",GameUI);


function MainUI:ctor( ... )
	-- body
	self.super.ctor(self,...);
end

function MainUI:onRemove( ... )
	-- body
	self.super.onRemove(self,...);
end

function MainUI:onShow( ... )
	-- body
end

function MainUI:onAdd( scene  )
	-- body
	self.super.onAdd(self,scene);

	-- display.newSprite("HelloWorld.png")
 --        :move(display.center)
 --        :addTo(self)

 --    -- add HelloWorld label
 --    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
 --        :move(display.cx, display.cy + 200)
 --        :addTo(self)
 --    self:httptest();

    local arrayTable = {};
    local node = cc.CSLoader:createNode("test/MainScene/MainScene.csb",function ( ctrlNode )
        -- body
        arrayTable[ctrlNode:getName()] = ctrlNode;
    end);
    self:addUINode(node)
    arrayTable["BtnPVP_8"]:onTouch(function ( event )--login
        -- body
        if event.name == "ended" then 
           self:showUI(eUI.UI_LEVELSELECTION)
        end
    end);
    -- arrayTable["Button_1_0_4_8_12"]:onTouch(function ( event )--logout
    --     -- body
    --     if event.name == "ended" then 
    --         print("Button_1");
    --     end
    -- end);
end
