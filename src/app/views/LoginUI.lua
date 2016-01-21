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
	printInfo("LoginUI:onAdd")
	printInfo("scene:" .. type(scene));
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


function LoginUI:httptest( ... )
	-- body
	function onRequestFinished(event)
	    local ok = (event.name == "completed")
	    local request = event.request
	 
	    if not ok then
	        -- 请求失败，显示错误代码和错误消息
	        --print(request:getErrorCode(), request:getErrorMessage())
	        return
	    end
	 
	    local code = request:getResponseStatusCode()
	    if code ~= 200 then
	        -- 请求结束，但没有返回 200 响应代码
	        print(code)
	        return
	    end
	 
	    -- 请求成功，显示服务端返回的内容
	    local response = request:getResponseString()
	    device.showAlert("网络请求返回", "返回成功", "确定", nil);
	end
	 
	-- 创建一个请求，并以 POST 方式发送数据到服务端
	local url = "http://www.163.com"
	local request = network.createHTTPRequest(onRequestFinished, url)	 
	-- 开始请求。当请求完成时会调用 callback() 函数
	request:start()
end