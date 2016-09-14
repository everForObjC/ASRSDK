//
//  ASRLinkUnity.m
//  ASRSDK
//
//  Created by Mac on 16/9/14.
//  Copyright © 2016年 kongzi2016. All rights reserved.
//

#import "ASRLinkUnity.h"
#import <QuartzCore/QuartzCore.h>
#import "IATConfig.h"
#import "ISRDataHelper.h"

@interface ASRLinkUnity()<IFlySpeechRecognizerDelegate>

@property (nonatomic,strong) IFlySpeechRecognizer *speechRecognizer;
@property (nonatomic,strong) IFlyDataUploader *uploader;

@property (nonatomic,strong) NSString *result;
@property (nonatomic,strong) NSString *str_result;
@property (nonatomic,assign) BOOL isCanceled;

@end

@implementation ASRLinkUnity

- (instancetype)init{
    if (self = [super init]) {
        
        NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",@"	57d63be8"];
        [IFlySpeechUtility createUtility:initString];
        
        self.uploader = [[IFlyDataUploader alloc]init];
        
        self.result = [NSString string];
        
    }
    return self;
}
//初始化Recognizer
-(void)initRecognizer
{
    NSLog(@"%s",__func__);
    //无界面
    //单例模式，无UI的实例
    if (_speechRecognizer == nil) {
        _speechRecognizer = [IFlySpeechRecognizer sharedInstance];
        
        [_speechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
        
        //设置听写模式
        [_speechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    }
    _speechRecognizer.delegate = self;
    
    if (_speechRecognizer != nil) {
        IATConfig *instance = [IATConfig sharedInstance];
        
        //设置最长录音时间
        [_speechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        //设置后端点
        [_speechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        //设置前端点
        [_speechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        //网络等待时间
        [_speechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        
        //设置采样率，推荐使用16K
        [_speechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        
        if ([instance.language isEqualToString:[IATConfig chinese]]) {
            //设置语言
            [_speechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            //设置方言
            [_speechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
        }else if ([instance.language isEqualToString:[IATConfig english]]) {
            [_speechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        }
        //设置是否返回标点符号
        [_speechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
        
        
    }
    
}
//开启
- (void)start{
    
    self.isCanceled = NO;
    
    if(_speechRecognizer == nil)
    {
        [self initRecognizer];
    }
    
    [_speechRecognizer cancel];
    
    //设置音频来源为麦克风
    [_speechRecognizer setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    //设置听写结果格式为json
    [_speechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
    //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
    [_speechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    [_speechRecognizer setDelegate:self];
    
    BOOL ret = [_speechRecognizer startListening];
    
    if (ret) {
        NSLog(@"启动成功");
    }else{
        NSLog(@"启动失败");//可能是上次请求未结束，暂不支持多路并发
    }
    
}
//停止
- (NSString *)end{
    //结束监听并开始识别
    [_speechRecognizer stopListening];
    //
    //    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(result:)]) {
    //
    //                    [self.delegate result:_result];
    //                    NSLog(@"数据返回");
    //            }
    
    return self.result;
}
//取消
- (void)cancel{
    [_speechRecognizer cancel];
}
//音量
- (void)onVolumeChanged:(int)volume{
    
}
//开始识别回调
- (void)onBeginOfSpeech{
    
}
//停止录音回调
- (void)onEndOfSpeech{
    
}
/****
 听写结束回调（注：无论听写是否正确都会回调）
 error.errorCode = 0     听写正确
 other 听写出错
 ****/
- (void)onError:(IFlySpeechError *)errorCode{
    
    if (errorCode == 0){
        
        if (_result.length == 0) {
            NSLog(@"无识别结果");
        }else{
            
            NSLog(@"识别成功");
        }
    }else{
        
        NSLog(@"识别错误：%@",errorCode);
    }
}
//返回数据
- (void)onResults:(NSArray *)results isLast:(BOOL)isLast{
    
    NSArray * temp = [[NSArray alloc]init];
    NSString * str = [[NSString alloc]init];
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
        
    }
    
    //---------讯飞语音识别JSON数据解析---------//
    NSError * error;
    NSData * data = [result dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary * dic_result =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSArray * array_ws = [dic_result objectForKey:@"ws"];
    //遍历识别结果的每一个单词
    for (int i=0; i<array_ws.count; i++) {
        temp = [[array_ws objectAtIndex:i] objectForKey:@"cw"];
        NSDictionary * dic_cw = [temp objectAtIndex:0];
        NSString *tempStr = [dic_cw objectForKey:@"w"];
        //去掉识别结果最后的标点符号
        if ([tempStr isEqualToString:@"。"] || [tempStr isEqualToString:@"？"] || [tempStr isEqualToString:@"！"] || [tempStr isEqualToString:@"，"]) {
            //             NSLog(@"末尾标点符号：%@",str);
        }
        else{
            
            str = [str stringByAppendingString:[dic_cw objectForKey:@"w"]];
            //            NSLog(@"识别结果:%@",[dic_cw objectForKey:@"w"]);
        }
        
    }
    //     NSLog(@"最终的识别结果:%@",str);
    self.result = [self.result stringByAppendingString:str];
    
    //    NSMutableString *resultString = [[NSMutableString alloc] init];
    //    NSDictionary *dic = results[0];
    //    for (NSString *key in dic) {
    //        [resultString appendFormat:@"%@",key];
    //    }
    //    _result =[NSString stringWithFormat:@"%@%@", _str_result,resultString];
    //    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    //    _str_result = [NSString stringWithFormat:@"%@%@", _str_result,resultFromJson];
    //
    if (isLast){
        //        NSLog(@"听写结果: %@",  self.result);
//        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(result:)]) {
//            
//            [self.delegate result:_result];
//            NSLog(@"数据返回");
//        }
    }
    //    NSLog(@"resultFromJson=%@",resultFromJson);
    
    
    //    [self.str_result appendString:self.result];
    
    
    
}


@end
