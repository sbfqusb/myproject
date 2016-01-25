//
//  LaoHuIAPSDKMgr.m
//  DLDLGAME
//
//  Created by chenzhi on 15-7-10.
//
//

#import "LaoHuIAPSDKMgr.h"

@implementation LaoHuIAPSDKMgr

- (void)_init
{    
    s_platformcallback = 0;
    s_sdkinit = 0;
    loginCallback = 0;
}

+ (void)initPlatform:(NSDictionary*)dict
{
    int platformcallback = [[dict objectForKey:@"callback"] intValue];
    s_platformcallback = platformcallback;
    if (s_sdkinit == 1) {
        cocos2d::LuaBridge::pushLuaFunctionById(s_platformcallback);
        cocos2d::LuaStack *stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
        stack->pushString("1");
        stack->executeFunction(1);
        cocos2d::LuaBridge::releaseLuaFunctionById(s_platformcallback);
        s_platformcallback = 0;
    }
    else if (s_sdkinit == 2){
        cocos2d::LuaBridge::pushLuaFunctionById(s_platformcallback);
        cocos2d::LuaStack *stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
        stack->pushString("0");
        stack->executeFunction(1);
        cocos2d::LuaBridge::releaseLuaFunctionById(s_platformcallback);
        s_platformcallback = 0;
    }
//    //test
//    cocos2d::LuaBridge::pushLuaFunctionById(s_platformcallback);
//    cocos2d::LuaStack *stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
//    stack->pushString("1");
//    stack->executeFunction(1);
//    cocos2d::LuaBridge::releaseLuaFunctionById(s_platformcallback);
//    
//    //testend
}



+(void)login:(NSDictionary*) dict
{
    loginCallback = [[dict objectForKey:@"listner"] intValue];
    [[WMUPlatformKit sharedInstance] login];
//    //test
//    if (loginCallback > 0) {
//        cocos2d::LuaBridge::pushLuaFunctionById(loginCallback);
//        cocos2d::LuaStack *stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
//        stack->pushString("this is test code useid");
//        stack->pushString("this is test code useid");
//        stack->executeFunction(2);
//        cocos2d::LuaBridge::releaseLuaFunctionById(loginCallback);
//        loginCallback = 0;
//    }
//    //end
}

+(void)LoinOut:(NSDictionary*) dict
{
    if ([[[WMUPlatformKit sharedInstance] currentRealPlatform] isLogined]) {
        
        [[WMUPlatformKit sharedInstance]logout];
        return;
    }
    
//    //test
//    if (loginCallback > 0) {
//        cocos2d::LuaBridge::pushLuaFunctionById(loginCallback);
//        cocos2d::LuaStack *stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
//        stack->pushString("this is test code useid");
//        stack->pushString("this is test code useid");
//        stack->executeFunction(2);
//        cocos2d::LuaBridge::releaseLuaFunctionById(loginCallback);
//        loginCallback = 0;
//    }
//    //end
}

+(void)doPay:(NSDictionary*) dict
{
    if (![[[WMUPlatformKit sharedInstance] currentRealPlatform] isLogined]) {
        
        NSLog(@"用户尚未登录");
        
        [[WMUPlatformKit sharedInstance] login];
        return;
    }
    
    NSString *productPrice = [dict objectForKey:@"productPrice"];
    
    NSString *uuidString =[dict objectForKey:@"orderSerial"];
    
    NSString *productName = [dict objectForKey:@"productName"];
    NSString *gameServerId = [dict objectForKey:@"gameServerId"];
    NSString *extInfo = [dict objectForKey:@"extInfo"];
    NSString *channelServerId = [dict objectForKey:@"channelServerId"];
    NSString *productId = [dict objectForKey:@"productId"];
    NSString *productCount = [dict objectForKey:@"productCount"];
    NSString *roleId = [dict objectForKey:@"roleId"];
    
     NSLog(@"payment keys %@",[[WMUPlatformKit sharedInstance] needsOfPay]);
    
    NSDictionary *payInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:productPrice, uuidString, productName, gameServerId, extInfo, channelServerId, productId, productCount, roleId ,nil]
                                                        forKeys:[[WMUPlatformKit sharedInstance] needsOfPay]];
    
    [[WMUPlatformKit sharedInstance] payWithInfo:payInfo];
}

@end
