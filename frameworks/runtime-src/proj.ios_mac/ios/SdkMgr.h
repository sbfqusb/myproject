//
//  LaoHuIAPSDKMgr.h
//  DLDLGAME
//
//  Created by chenzhi on 15-7-10.
//
//

#import <Foundation/Foundation.h>
#import "CCLuaEngine.h"
#include "CCLuaBridge.h"
#include "platform/ios/CCLuaObjcBridge.h"

extern int s_platformcallback;
extern int s_sdkinit;//0 :init 1:success 2:fail
extern int loginCallback;

@interface SdkMgr : NSObject


- (void) _init;
+ (void) login:(NSDictionary*) dict;
+ (void) LoinOut:(NSDictionary*) dict;
+ (void) doPay:(NSDictionary*) dict;
+ (void) initPlatform :(NSDictionary*) dict;

@end
