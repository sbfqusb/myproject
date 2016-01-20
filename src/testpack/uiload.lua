local uiloadTest = class("uiloadTest", function()
    return display.newNode()
end)

function uiloadTest:ctor()
end

function uiloadTest:createAni()
	local node = cc.CSLoader:createNode("Tauren.csb")
    local action = cc.CSLoader:createTimeline("Tauren.csb")

    node:runAction(action)
    action:play("attack", true)

    node:setPosition(display.center);
    self:addChild(node)
    node:setVisible(true);
    node:setLocalZOrder(10)

    local node = cc.CSLoader:createNode("Tauren.csb")
    local action = cc.CSLoader:createTimeline("Tauren.csb")
    node:runAction(action)
    action:play("run", true)
    node:setPosition(display.cx, display.cy - 200);
    self:addChild(node)
    node:setVisible(true);
    node:setLocalZOrder(10)
end

function uiloadTest:createUI()

    local arrayTable = {};
    local node = cc.CSLoader:createNode("MainScene.csb",function ( ctrlNode )
        -- body
        arrayTable[ctrlNode:getName()] = ctrlNode;
    end);
    self:addChild(node)
    dump(arrayTable,"createUI");
    arrayTable["Button_1"]:onTouch(function ( event )
        -- body
        if event.name == "ended" then 
            print("Button_1");
            self:createTestUI();
        end
    end);
end