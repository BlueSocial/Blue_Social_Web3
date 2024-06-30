//
//  WalletInfoBridge.m
//  Blue
//
//  Created by Ethan Santos on 6/21/24.
//  Copyright © 2024 Bluepixel Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(WalletInfoBridge, NSObject)
RCT_EXTERN_METHOD(sendBalance:(NSString *)balance usdRate:(NSString *)usdRate walletAddress:(NSString *)walletAddress link:(NSString *)link resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(fetchBalance:(RCTResponseSenderBlock)completion)
RCT_EXTERN_METHOD(sendRewardAmount:(NSString *)rewardAmount)  // New method
@end
