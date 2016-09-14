//
//  ISRDataHelper.h
//  ASRSDK
//
//  Created by Mac on 16/9/14.
//  Copyright © 2016年 kongzi2016. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISRDataHelper : NSObject

// 解析命令词返回的结果
+ (NSString*)stringFromAsr:(NSString*)params;

/**
 解析JSON数据
 ****/
+ (NSString *)stringFromJson:(NSString*)params;//


/**
 解析语法识别返回的结果
 ****/
+ (NSString *)stringFromABNFJson:(NSString*)params;

@end
