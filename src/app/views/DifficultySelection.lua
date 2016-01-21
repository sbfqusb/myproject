--
-- Author: Your Name
-- Date: 2016-01-21 10:26:56
--
DifficultySelection = class("DifficultySelection",GameUI);


function DifficultySelection:ctor( ... )
	-- body
	self.super.ctor(self,...);
end

function DifficultySelection:onRemove( ... )
	-- body
	self.super.onRemove(self,...);
    self:dispatchEvent(EVT.UI_CLOSE,self.WigetType);
end

function DifficultySelection:onShow( ... )
	-- body
end

function DifficultySelection:onAdd( scene  )
	-- body
	self.super.onAdd(self,scene);

    local arrayTable = {};
    local node = cc.CSLoader:createNode("test/DifficultySelection/MainScene.csb",function ( ctrlNode )
        -- body
        arrayTable[ctrlNode:getName()] = ctrlNode;
    end);
    self:addUINode(node)

    arrayTable["Button_Close"]:onTouch(function ( event )--login
        -- body
        if event.name == "ended" then 
            self:close();
        end
    end);
end
