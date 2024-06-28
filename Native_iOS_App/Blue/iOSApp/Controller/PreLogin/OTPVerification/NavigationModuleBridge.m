//
//  NavigationModuleBridge.m
//  Blue
//
//  Created by Ethan Santos on 6/20/24.
//  Copyright © 2024 Bluepixel Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(NavigationModule, NSObject)

RCT_EXTERN_METHOD(goBack)
RCT_EXTERN_METHOD(navigateToTourPage)

@end
