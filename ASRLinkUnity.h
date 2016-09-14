//
//  ASRLinkUnity.h
//  ASRSDK
//
//  Created by Mac on 16/9/14.
//  Copyright © 2016年 kongzi2016. All rights reserved.
//


//需要查看科大讯飞库的导入
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "iflyMSC/IFlyMSC.h"
#import "iflyMSC/iflyMSC.h"

@class IFlyDataUploader;
@class IFlySpeechUnderstander;

@interface ASRLinkUnity : NSObject
//初始化方法
- (instancetype)init;
//开始
- (void)start;
//结束，并返回结果
- (NSString *)end;
//取消
- (void)cancel;


@end
