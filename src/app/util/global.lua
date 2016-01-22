--
-- Author: Your Name
-- Date: 2016-01-22 11:41:03
--

local director = cc.Director:getInstance()
function GlobalSendEvent( event, ... )--
	-- body
	local runingScene = director:getRunningScene();
	if runingScene then
		--todo
		local event = {name = eventName,params = ...};
		runingScene:dispatchEvent(event);
	end
end

function GlobalShowUI( type, ... )--
	-- body

	local runingScene = director:getRunningScene();
	if runingScene then
		--todo
		runingScene:showUI( type , ... )
	end
end