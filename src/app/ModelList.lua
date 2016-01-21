--
-- Author: Your Name
-- Date: 2016-01-20 16:32:28
--

local ModelList = 
{
	base = 
	{
		"app.views.GameUI",
		"app.util.event",
	}
};

function ModelList:execBaseFileList( ... )
	-- body
	for i,v in ipairs(ModelList.base) do
		require(v);
	end
end
ModelList:execBaseFileList();
return ModelList;