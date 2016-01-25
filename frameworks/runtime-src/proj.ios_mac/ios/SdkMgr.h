//
//  SdkMgr.h
//  myproject
//
//  Created by DK on 16/1/25.
//
//

#import <Foundation/Foundation.h>
#import "CCLuaEngine.h"
#include "CCLuaBridge.h"
#include "platform/ios/CCLuaObjcBridge.h"

//extern int s_platformcallback;
//extern int s_sdkinit;//0:init 1:success 2:fail
//extern int loginCallback;
@interface SdkMgr : NSObject
-(void) _init;

@end