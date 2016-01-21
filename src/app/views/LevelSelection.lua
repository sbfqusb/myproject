--
-- Author: Your Name
-- Date: 2016-01-21 10:10:36
--
LevelSelection = class("LevelSelection",GameUI);


function LevelSelection:ctor( ... )
	-- body
	self.super.ctor(self,...);
end

function LevelSelection:onRemove( ... )
	-- body
	self.super.onRemove(self,...);
end

function LevelSelection:onShow( ... )
	-- body
end

function LevelSelection:onAdd( scene  )
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
    local node = cc.CSLoader:createNode("test/LevelSelection/MainScene.csb",function ( ctrlNode )
        -- body
        arrayTable[ctrlNode:getName()] = ctrlNode;
    end);
    self:addUINode(node)
    arrayTable["Button_Enter"]:onTouch(function ( event )--login
        -- body
        if event.name == "ended" then 
            self:showUI(eUI.UI_DIFFICULTYSELECTION)
        end
    end);
    -- arrayTable["Button_1_0_4_8_12"]:onTouch(function ( event )--logout
    --     -- body
    --     if event.name == "ended" then 
    --         print("Button_1");
    --     end
    -- end);
    self:registerEvent(EVT.UI_CLOSE,handler(self, self.eventClose));
end

function LevelSelection:eventClose( ... )
    -- body
    dump(..., "desciption, nesting")
end
