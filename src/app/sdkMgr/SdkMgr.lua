--
-- Author: Your Name
-- Date: 2015-06-02 19:42:20
--
SdkMgr = SdkMgr or {}

local luaj = nil;
local luaoc = nil;
local json = nil;
local Store = nil;--ios store
local javaObjCallName = nil;

if device.platform == "android" then
	luaj = require "cocos.cocos2d.luaj"
	javaObjCallName = "org/cocos2dx/lua/AppActivity"
elseif device.platform == "ios" then
	luaoc = require "cocos.cocos2d.luaoc"
	Store = require "app.sdkMgr.Store"
end

if json == nil then
	json = require("cocos.cocos2d.json")
end



function SdkMgr:LoginSdk( callfun )--登陆平台
	-- body
	if USEOFFICIAL == true then
		if callfun then
			callfun();
		end
		return;
	end
	if SdkMgr:isLogin( ) == 1 then
		if callfun then
			callfun(SdkMgr:getUserId(),SdkMgr:getToken(),SdkMgr:getDataJson());
		end
		return;
	end
	self.callbackFun = callfun;
	if device.platform == "android" then
		local tempListner = handler(self, self.LoginSdkCallBack);
		luaj.callStaticMethod(javaObjCallName, "LoginSdk", {tempListner}, "(I)V");
	elseif device.platform == "ios" then
		local tempListner = handler(self, self.LoginSdkCallBack);
		luaoc.callStaticMethod("LaoHuIAPSDKMgr", "login", {listner = tempListner});
	end
end

function SdkMgr:LoginOut(  )--登出平台
	if USEOFFICIAL == true then
		return;
	end
	if device.platform == "android" then
		luaj.callStaticMethod("org/cocos2dx/lua/OneSdkMgr", "logoutSdk", {}, "()V");
	elseif device.platform == "ios" then
		luaoc.callStaticMethod("LaoHuIAPSDKMgr", "LoinOut",{});
	end	
end

function SdkMgr:LoginSdkCallBack( event ,token)--登陆平台返回
	-- body
	printInfo("LoginSdkCallBack");
	printInfo("token");
	self.userId = "";
	self.token = ""
	if Launcher.gameDataCollection ~= nil then
		Launcher.gameDataCollection(3)
	end
	if device.platform == "android" then
		if type(event) == "string" then
		    event = json.decode(event)
		    event.result = tonumber(event.result)
		    dump(event, "");
		    if event.result == 1 then--success
				self.userId   = event.userId;
				self.token    = event.token;
				local password = event.password;
				local msg      = event.msg;

				if self:getChannelId() == "6001" and ISDKM_PACKAGE then
					self.tencentData = msg;
				end

				if self.callbackFun then
					self.callbackFun(self.userId,self.token,SdkMgr:getDataJson(),msg);
				end
		    elseif event.result == 2 then--cancel
		    elseif event.result == 0 then--fail
		    end
		end
	elseif device.platform == "ios" then
		printInfo("userId:" .. event);
		printInfo("token:" .. token);
		self.userId = event;
		self.token = token;
		if self.callbackFun then
			self.callbackFun(event,token,SdkMgr:getDataJson(),"");
		end
	end
	self.callbackFun = nil;
	if self.userId ~= "" and game.curScene.isLoginScene ~= nil then
		CSSendLogin(self.userId,self.token,0);--查询登陆过的服务器列表
	end
end

function LoginSuccessCallback( event ,token )--登陆成功全局回调
	-- body
	SdkMgr:LoginSdkCallBack( event ,token );
end

function SdkMgr:doPay( data )
	-- body
	local extData = "";
	data.args = data.args or {};
	if data.args[1] ~= nil then
		extData = data.args[1];
	end
	if device.platform == "android" then
		local tempListner = handler(self, self.doPaySdkCallBack);
		local args = 
		{
			tempListner,
			data.serial,           			        --setOrderNum     /** 游戏传入的外部订单号，每笔订单请保持订单号唯一；String */
			data.worth_money * 100,           	    --setPrice        /** 金额，以分为单位；建议传入100分的整数倍，因为有些渠道(例如百度多酷、酷狗)以元为单位，若传入金额不是100分的整数倍,* 则这些渠道包无法支付；int */
			LoginMgr.curSelectArea.serverid,  			--setServerId     /** 游戏服务器id，每一个服务器id在Onesdk后台对应一个支付通知地址，默认为0；int */
			10,                         			--setExchangeRate /** 游戏币与人民币兑换比率,例如100为1元人民币兑换100游戏币；int */
			data.goods,                 			--setProductId    /** 商品id；String */
			data.cl_name,               			--setProductName  /** 商品名称；String */
			data.first_desc,            			--setProductDesc  /** 商品描述；String */
			extData,                 			    --setExt          /** 附加字段；放在附加字段中的值，OneSDK服务器端会不作任何修改通过服务器通知透传给游戏服务器；String */
			"0",                        			--setBalance      /** 用户游戏币余额，如果没有账户余额，请填0;String */
			"vip0",                     			--setVip          /** vip等级，如果没有，请填0；String */
			tostring(PlayerData.getLevel()),      	--setLv           /** 角色等级，如果没有，请填0；String */
			"gonghui",                              --setPartyName    /** 工会、帮派名称，如果没有，请填0；String */
			PlayerData.getName(),        			--setRoleName     /** 角色名称；String */
			tostring(LoginMgr.getUserId()),        	--setRoleId       /** 角色id；String */
			LoginMgr.curSelectArea.name, 			--setServerName   /** 所在服务器名称；String */
			"哆可梦",                    			--setCompany      /** 公司名称；String */
			"钻石"                                  --setCurrencyName /** 货币名称；String */
		}
		dump(args, "doPay:args");
		if self:getChannelId() == "6001" and ISDKM_PACKAGE then
			local msg = {}
			msg.event = "tencent.payment.consume";
			msg.channelId = "6001";
			msg.orderuuid = data.serial;
			msg.ProductId = data.goods;
			msg.dataJson = {}
			msg.dataJson.device = "1";
			msg.dataJson.balance = tostring(data.worth_money * 100);
			msg.dataJson = json.encode(msg.dataJson);
			MsdkOrderList[tostring(data.serial)] = {data = json.encode(msg)};
			GlobalFun.SaveKey(MsdkOrder .. tostring(LoginMgr.getUserId()) ,json.encode(MsdkOrderList));
		end
		luaj.callStaticMethod(javaObjCallName, "doPay", args);
	elseif device.platform == "ios" then

		-- 4.	老虎官方渠道
		-- 	Key名称	含义
		-- 	productPrice               	商品价格，单位：分
		-- 	orderSerial                	订单号，必须保证唯一
		-- 	productName                	商品名称
		-- 	gameServerId        	    游戏服务器Id。如果没有请传入-1；服务器Id必须定义为非负整数。
		-- 	extInfo	                    透传参数
		-- 	channelServerId            	含义同gameServerId，必须为正整数，若无可传空字符串
		-- 	productId	                AppStore中商品的唯一标示
		-- 	productCount	            购买商品数量
		-- 	roleId	                    待充值的角色Id，不可为空
        local args = {
            productPrice = tostring(data.worth_money * 100),
            orderSerial = tostring(data.serial),
            productName = data.cl_name,
            gameServerId = tostring(LoginMgr.curSelectArea.serverid),
            extInfo = extData,
            channelServerId = tostring(LoginMgr.curSelectArea.serverid),
            productId = tostring(data.goods),
            productCount = tostring(1),
            roleId = tostring(LoginMgr.getUserId())
        }
        dump(args,"doPay:args");
        
        if USEOFFICIAL and not IOS_JAILBREAK then
        	game.curScene:showUI(eUI.UI_WAITINGLAYER,true);
        	printInfo(data.goods);
        	local value = Store.purchase(data.goods);
        	if value == false then
        		game.curScene:showUI(eUI.UI_CommonUIShowTips,"产品ID不存在");
        		game.curScene:closeUI(eUI.UI_WAITINGLAYER);
        	end
        else
        	luaoc.callStaticMethod("LaoHuIAPSDKMgr", "doPay", args)
        end
	end
end

function SdkMgr:doPaySdkCallBack( event )
	if device.platform == "android" then
		if type(event) == "string" then
		    event = json.decode(event)
		    event.result = tonumber(event.result)
		    dump(event, "");
		    if event.result == 1 then--success
				local orderId   = event.orderId;
				local token    = event.token;
				local msg      = event.msg;
				if self:getChannelId() == "6001" and ISDKM_PACKAGE then--腾讯充值
					SdkMgr:tencentPaymentConsume(orderId,msg);
				end
		    elseif event.result == 2 then--cancel
		    	MsdkOrderList[event.orderId] = nil;
				GlobalFun.SaveKey(MsdkOrder .. tostring(LoginMgr.getUserId()) ,json.encode(MsdkOrderList));
		    elseif event.result == 0 then--fail
		    end
		end
	end
end

function SdkMgr:tencentPaymentConsume( orderid,msg )
	-- body
 	local sendData = json.decode(msg);
 	local dataTab  = json.decode(sendData.dataJson);
 	dump(dataTab,"olddata");
 	if self.tencentData then
 		local data = json.decode(self.tencentData);
 		dump(data,"tencentData")
 		dataTab.openkey      = data.openkey;
 		dataTab.pfkey        = data.pfkey;
 		dataTab.pay_token    = data.pay_token;
 		dataTab.pf    		 = data.pf;
 		dataTab.openid    	 = data.openid;
 		dataTab.platform     = data.platform;
 		dataTab.device 		 = "1";
		dataTab.balance 	 = dataTab.balance.."";
 	end
 	dump(dataTab,"curdata");
 	sendData.dataJson = json.encode(dataTab);

	local packet = CS_LoginPacket:New();
    packet.LoginStr = json.encode(sendData);
    dump(packet,"packet");
	LuaSendScriptPacket(EScriptPacketType.EPacket_CS_Login,packet);
	MsdkOrderList[tostring(orderid)] = {data = msg};
	GlobalFun.SaveKey(MsdkOrder .. tostring(LoginMgr.getUserId()) ,json.encode(MsdkOrderList));
end

function SdkMgr:getTencentOpenKey()
	return self.token;
end

--only for OneSDK  on android platform
--infoType: 0-create role, 1-role login, 2-role level up
--example: SdkMgr:submitRoleInfo(1, "roleId1234", "roleName1234", "88", 1234879, "zoneName1234")
function SdkMgr:submitRoleInfo(infoType, roleId, roleName, level, zoneId, zoneName)
	if USEOFFICIAL == true then
		return;
	end
	if device.platform == "android" then
		local args = {infoType, roleId, roleName, tostring(level), tonumber(zoneId), zoneName}
		local sig = "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V"
		luaj.callStaticMethod("org/cocos2dx/lua/OneSdkMgr", "submitRoleInfo", args, sig)
	end
end

function SdkMgr:getIMEI(  )
	-- body
	return device.getOpenUDID();
end

function SdkMgr:getChannelId(  )
	-- body
	if device.platform == "android" then
			--todo
		local ok, ret = luaj.callStaticMethod(javaObjCallName, "getChannelId", {}, "()I");
		if ok then
			return tostring(ret);
		end

	elseif device.platform == "ios" then
		local ok, ret = Launcher.luaoc.callStaticMethod(Launcher.ocClassName, "getChannelId")
		if ok then
			return ret;
		end
	end
	return 0;
end

function SdkMgr:getSubChannelId(  ) --子渠道
	-- body
		--todo
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod(javaObjCallName, "getSubChannelId", {}, "()I");
		if ok then
			return tostring(ret);
		end
	elseif IOS_JAILBREAK then
		local ok, ret = Launcher.luaoc.callStaticMethod(Launcher.ocClassName, "getSubChannelId")
		if ok then
			return ret;
		end
	end
	return SdkMgr:getChannelId();
end

function SdkMgr:isLogin()
	-- body
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/OneSdkMgr", "isLogin", {}, "()I");		
		if ok then
			return ret;
		end
	elseif device.platform == "ios" then
		local ok, ret = Launcher.luaoc.callStaticMethod(Launcher.ocClassName, "isLogin")
		if ok then
			return ret;
		end
	end
	return 0;
end

function SdkMgr:setStatusBar( Value )
	-- body
	if USEOFFICIAL == true then
		return;
	end	
	if device.platform == "android" then
		--return luaj.callStaticMethod(javaObjCallName, "setStatusBar", {}, "(V)I");
	elseif device.platform == "ios" then
		luaoc.callStaticMethod(Launcher.ocClassName, "setStatusBar", {value = Value});
	end
	return 0;
end

function SdkMgr:getUserId()
	-- body
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/OneSdkMgr", "getUserId", {}, "()Ljava/lang/String;");		
		if ok then
			return ret;
		end
	elseif device.platform == "ios" then
		local ok, ret = Launcher.luaoc.callStaticMethod(Launcher.ocClassName, "getUserId")
		if ok then
			return ret;
		end
	end
	return 0;
end

function SdkMgr:getToken()
	-- body
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/OneSdkMgr", "getToken", {}, "()Ljava/lang/String;");		
		if ok then
			return ret;
		end
	elseif device.platform == "ios" then
		local ok, ret = Launcher.luaoc.callStaticMethod(Launcher.ocClassName, "getToken")
		if ok then
			return ret;
		end
	end
	return 0;
end

function SdkMgr:getDataJson()
	-- body
	if ISDKM_PACKAGE then
		if device.platform == "android" then
			local ok, ret = luaj.callStaticMethod("org/cocos2dx/lua/OneSdkMgr", "getDataJson", {}, "()Ljava/lang/String;");		
			if ok then
				return ret;
			end
		elseif device.platform == "ios" then
			local ok, ret = Launcher.luaoc.callStaticMethod(Launcher.ocClassName, "getDataJson")
			if ok then
				return ret;
			end
		end
	end
	return "";
end

--ios iAP 内购
function SdkMgr:IosIAPInit( ... )
	-- body
	self.ProductKey = 
	{
		"com.dkmgame.60",
		"com.dkmgame.300",
		"com.dkmgame.500",
		"com.dkmgame.1280",
		"com.dkmgame.2880",
		"com.dkmgame.5480",
		"com.dkmgame.6480",
		"com.dkmgame.card.25gift",
		"com.dkmgame.card.50gift"
	};
	self.ProductKeyValue = 
	{
		[self.ProductKey[1]] = 600,
		[self.ProductKey[2]] = 3000,
		[self.ProductKey[3]] = 5000,
		[self.ProductKey[4]] = 12800,
		[self.ProductKey[5]] = 28800,
		[self.ProductKey[6]] = 54800,
		[self.ProductKey[7]] = 64800,
		[self.ProductKey[8]] = 2500,
		[self.ProductKey[9]] = 5000,
	};
	Store.init(handler(self,self.storeCallback));
	Store.loadProducts({
		self.ProductKey[1],
		self.ProductKey[2],
		self.ProductKey[3],
		self.ProductKey[4],
		self.ProductKey[5],
		self.ProductKey[6],
		self.ProductKey[7],
		self.ProductKey[8],
		self.ProductKey[9]
		},handler(self, self.loadCallback));
end

function SdkMgr:validateOrder( productId,data )
	-- body
	local json = require("cocos.cocos2d.json")
	local msg =
    {
        device = 2,
        channelId = SdkMgr:getChannelId(),
        event = "validateOrder",
        productid = productId,
        key = data;
    };

	local packet = CS_LoginPacket:New();
    packet.LoginStr = json.encode(msg);
    dump(packet,"packet");
	LuaSendScriptPacket(EScriptPacketType.EPacket_CS_Login,packet);	
end

function SdkMgr:storeCallback( transation )
	-- body
	dump(transation,"storeCallback");
	game.curScene:closeUI(eUI.UI_WAITINGLAYER);
	if transation.transaction.state == "purchased" and  game.curScene.isMainScene then
		printInfo("buy scuuess")
		printInfo("====================================")
		AppleOrderList[tostring(transation.transaction.transactionIdentifier)] = {};

		local Price = tostring(self.ProductKeyValue[transation.transaction.productIdentifier]);
		SdkMgr:validateOrder(transation.transaction.productIdentifier,crypto.encodeBase64(transation.transaction.receipt,string.len(transation.transaction.receipt)));
		AppleOrderList[tostring(transation.transaction.transactionIdentifier)] = {key = transation.transaction.productIdentifier,price = Price,data = crypto.encodeBase64(transation.transaction.receipt,string.len(transation.transaction.receipt))};
		GlobalFun.SaveKey(AppleOrderKey .. tostring(LoginMgr.getUserId()) ,json.encode(AppleOrderList));
		dump(AppleOrderList,"save order");

	elseif transation.transaction.state == "restored" then
		game.curScene:showUI(eUI.UI_CommonUIShowTips,"已经购买过商品");	
	elseif transation.transaction.state == "failed" then 
		game.curScene:showUI(eUI.UI_CommonUIShowTips,"支付失败");
	elseif transation.transaction.state == "cancelled" then
		game.curScene:showUI(eUI.UI_CommonUIShowTips,"用户取消交易");
	end
	Store.finishTransaction(transation.transaction)
end
function SdkMgr:loadCallback( products )
	-- body
	dump(products,"loadCallback",10);
end

function SdkMgr:orderChare(  )
	if not game.curScene.isMainScene then
		--todo
		return;
	end
	if device.platform == "ios" and USEOFFICIAL then
		local orderData = GlobalFun.GetKey(AppleOrderKey .. tostring(LoginMgr.getUserId()));
		local orderTable = json.decode(orderData);
		if orderTable then
			dump(orderTable, "SdkMgr:orderChare")
			for k,v in pairs(orderTable) do
				SdkMgr:validateOrder( v.key,v.data );
			end
		end
	elseif self:getChannelId() == "6001" and ISDKM_PACKAGE then--腾讯充值
		local orderData = GlobalFun.GetKey(MsdkOrder .. tostring(LoginMgr.getUserId()));
		local orderTable = json.decode(orderData);
		if orderTable then
			dump(orderTable, "SdkMgr:orderChare")
			for k,v in pairs(orderTable) do
				SdkMgr:tencentPaymentConsume( k,v.data );
			end
		end
	end
end

function goToLogin()
	SdkMgr.curSwitchUser = true;
	Launcher.performWithDelayGlobal(function ( ... )
		-- body
		if game.curScene.isMainScene ~= nil then
		    LoginMgr.reConnect = nil;
		    local localScene = LoginScene:create();
		    localScene:enter();
			GuideManager.getInstance():stopGuide()
			EventManager.sendEvent(EVT.GOTO_LOGIN)
		else
			local uiData = game.curScene:getUI( eUI.UI_LOGIN );
			if uiData and uiData.frameNode:isVisible() == true then
				printInfo("UI_LOGIN is show")
			else
				local OpeningVideoUI = game.curScene:getUI(eUI.UI_OpeningVideo);
				if OpeningVideoUI and OpeningVideoUI.frameNode:isVisible() == true then
					game.curScene:closeUI(eUI.UI_OpeningVideo)
				end
            	game.curScene:showUI( eUI.UI_LOGIN );
        	end
		end
	end,0.1)
end

function goBack()--返回键
	printInfo("goBack")
	local value = game.curScene:backButtonCallback();
	if value == 1 then
		SdkMgr:sdkExit();--退出游戏
	end
end

function goExitGame(  )--退出游戏
	-- body
	cc.Director:getInstance():endToLua()
end

function SdkMgr:sdkExit( )
	-- body
	if device.platform == "android" then
		printInfo("sdkExit")
		luaj.callStaticMethod("org/cocos2dx/lua/OneSdkMgr", "ExitSdk", {}, "()V");
	end
end

-- 错误码
-- WXSuccess           = 0,    /**< 成功    */
-- WXErrCodeCommon     = -1,   /**< 普通错误类型    */
-- WXErrCodeUserCancel = -2,   /**< 用户点击取消并返回    */
-- WXErrCodeSentFail   = -3,   /**< 发送失败    */
-- WXErrCodeAuthDeny   = -4,   /**< 授权失败    */
-- WXErrCodeUnsupport  = -5,   /**< 微信不支持    */
-- 请求发送场景
-- WXSceneSession  = 0,        /**< 聊天界面    */
-- WXSceneTimeline = 1,        /**< 朋友圈      */
-- WXSceneFavorite = 2,        /**< 收藏       */
function SdkMgr:shareWeChatText(text, callfunc, type)
	if device.platform=="ios" then
		local args = {
			content = text,
			callback = callfunc,
			scene = type,
		}
		local ok, installed = luaoc.callStaticMethod(Launcher.ocClassName, "sendTextContent", args)
		-- if not installed then
		-- 	callfunc(100)
		-- end
		if not installed then
			game.curScene:showUI(eUI.UI_CommonUIShowTips,"尚未安装微信");
		end

		return installed, ok
	end
end
