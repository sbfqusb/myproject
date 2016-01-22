--
-- Author: Your Name
-- Date: 2016-01-20 18:10:57
--


LoginUI = class("LoginUI",GameUI);


function LoginUI:ctor( ... )
	-- body
	self.super.ctor(self,...);
end

function LoginUI:onRemove( ... )
	-- body
	self.super.onRemove(self,...);
end

function LoginUI:onShow( ... )
	-- body
end

function LoginUI:onAdd( scene  )
	-- body
	self.super.onAdd(self,scene);

    local arrayTable = {};
    local node = cc.CSLoader:createNode("test/MainScene.csb",function ( ctrlNode )
        -- body
        arrayTable[ctrlNode:getName()] = ctrlNode;
    end);
    self:addUINode(node)
    arrayTable["Button_1_2_6_10"]:onTouch(function ( event )--login
        -- body
        if event.name == "ended" then 
            self:showUI(eUI.UI_MAIN)
            --self:close();
        end
    end);
    arrayTable["Button_1_0_4_8_12"]:onTouch(function ( event )--logout
        -- body
        if event.name == "ended" then 
            print("Button_1");
        end
    end);
end
