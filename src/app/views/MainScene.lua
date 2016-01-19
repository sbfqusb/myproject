
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

function MainScene:onCreate()
    -- add background image
    display.newSprite("HelloWorld.png")
        :move(display.center)
        :addTo(self)

    -- add HelloWorld label
    cc.Label:createWithSystemFont("Hello World", "Arial", 40)
        :move(display.cx, display.cy + 200)
        :addTo(self)
    self:httptest();
end

function MainScene:httptest( ... )
	-- body
	function onRequestFinished(event)
	    local ok = (event.name == "completed")
	    local request = event.request
	 
	    if not ok then
	        -- 请求失败，显示错误代码和错误消息
	        print(request:getErrorCode(), request:getErrorMessage())
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
	    print(response)
	    device.showAlert("网络请求返回", "返回成功", "确定", nil);
	end
	 
	-- 创建一个请求，并以 POST 方式发送数据到服务端
	local url = "http://www.163.com"
	local request = network.createHTTPRequest(onRequestFinished, url)	 
	-- 开始请求。当请求完成时会调用 callback() 函数
	request:start()
end
return MainScene
