//
//  do_RichLabel1_Model.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_RichLabel1_UIModel.h"
#import "doProperty.h"
#import "do_RichLabel1_UIView.h"
#import "doIEventCenter.h"

@interface do_RichLabel1_UIModel()<doIEventCenter>

@end

@implementation do_RichLabel1_UIModel

#pragma mark - 注册属性（--属性定义--）
/*
[self RegistProperty:[[doProperty alloc]init:@"属性名" :属性类型 :@"默认值" : BOOL:是否支持代码修改属性]];
 */
-(void)OnInit
{
    [super OnInit];    
    //属性声明
	[self RegistProperty:[[doProperty alloc]init:@"fontColor" :String :@"000000FF" :NO]];
	[self RegistProperty:[[doProperty alloc]init:@"fontSize" :Number :@"17" :NO]];
	[self RegistProperty:[[doProperty alloc]init:@"fontStyle" :String :@"normal" :NO]];
	[self RegistProperty:[[doProperty alloc]init:@"maxHeight" :Number :@"" :YES]];
	[self RegistProperty:[[doProperty alloc]init:@"maxLines" :Number :@"1" :YES]];
	[self RegistProperty:[[doProperty alloc]init:@"maxWidth" :Number :@"" :YES]];
	[self RegistProperty:[[doProperty alloc]init:@"span" :String :@"" :NO]];
	[self RegistProperty:[[doProperty alloc]init:@"text" :String :@"" :NO]];
	[self RegistProperty:[[doProperty alloc]init:@"textAlign" :String :@"left" :YES]];
	[self RegistProperty:[[doProperty alloc]init:@"textFlag" :String :@"normal" :YES]];
    [self RegistProperty:[[doProperty alloc] init:@"linesSpace" :Number :@"0" :NO]];
    
}
- (void)eventOn:(NSString *)onEvent
{
    [((do_RichLabel1_UIView *)self.CurrentUIModuleView) eventName:onEvent :@"on"];
}

- (void)eventOff:(NSString *)offEvent
{
    [((do_RichLabel1_UIView *)self.CurrentUIModuleView) eventName:offEvent :@"off"];
}
@end
