//
//  do_RichLabel1_View.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "do_RichLabel1_UIView.h"

#import "doInvokeResult.h"
#import "doUIModuleHelper.h"
#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"
#import "doTextHelper.h"
#import "doServiceContainer.h"
#import "doILogEngine.h"
#import "doSpanModel.h"

#define FONT_OBLIQUITY 15.0

@interface do_RichLabel1_UIView()<UITextViewDelegate>

@end
@implementation do_RichLabel1_UIView
{
    NSMutableDictionary *_attributeDict;
    
    NSMutableDictionary *_spanAttribute;
    
    CGFloat maxWidth;
    CGFloat maxHeight;
    
    int curFontSize;
    NSString *curFontStyle;
    
    NSString *curText;
    NSString *curSpan;
    NSMutableArray *spans;
    
    BOOL isRegisterTouch;
}

#pragma mark - doIUIModuleView协议方法（必须）
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    _model = (typeof(_model)) _doUIModule;
    
    self.editable = NO;
    self.delegate = self;
    self.showsVerticalScrollIndicator = NO;
    [self loadDefault];
    isRegisterTouch = NO;
    self.textContainer.lineFragmentPadding = 0;

}
- (void)loadDefault
{
    _attributeDict = [NSMutableDictionary dictionary];
    _spanAttribute = [NSMutableDictionary dictionary];
    curFontSize = [doUIModuleHelper GetDeviceFontSize:17 :_model.XZoom :_model.YZoom];
    curFontStyle = @"normal";
    curText = @"";
    curSpan = @"";
    spans = [NSMutableArray array];
    maxHeight = MAXFLOAT;
    maxWidth = MAXFLOAT;
    
    [_attributeDict setObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    [_attributeDict setObject:[UIFont systemFontOfSize:curFontSize] forKey:NSFontAttributeName];
    [_attributeDict setObject:@(NSUnderlineStyleNone) forKey:NSUnderlineStyleAttributeName];
    self.contentInset = UIEdgeInsetsMake(-8, 0, 2, 0);
    self.backgroundColor = [UIColor clearColor];
}
//销毁所有的全局对象
- (void) OnDispose
{
    //自定义的全局属性,view-model(UIModel)类销毁时会递归调用<子view-model(UIModel)>的该方法，将上层的引用切断。所以如果self类有非原生扩展，需主动调用view-model(UIModel)的该方法。(App || Page)-->强引用-->view-model(UIModel)-->强引用-->view
    self.delegate = nil;
}
//实现布局
- (void) OnRedraw
{
    //重新调整视图的x,y,w,h
    if ([self isAutoHeightOrAutoWidth]) {
        //实现布局相关的修改
        [doUIModuleHelper OnResize:_model];
    }else
    {
        [doUIModuleHelper OnRedraw:_model];
    }
}

#pragma mark - TYPEID_IView协议方法（必须）
#pragma mark - Changed_属性
/*
 如果在Model及父类中注册过 "属性"，可用这种方法获取
 NSString *属性名 = [(doUIModule *)_model GetPropertyValue:@"属性名"];
 
 获取属性最初的默认值
 NSString *属性名 = [(doUIModule *)_model GetProperty:@"属性名"].DefaultValue;
 */

- (void)change_fontColor:(NSString *)newValue
{
    //自己的代码实现
    //设置字体颜色
    UIColor *fontColor = [doUIModuleHelper GetColorFromString:newValue :[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    [_attributeDict setObject:fontColor forKey:NSForegroundColorAttributeName];
    [self changeText];
}
- (void)change_fontSize:(NSString *)newValue
{
    //自己的代码实现
    int fontSize = [doUIModuleHelper GetDeviceFontSize:[[doTextHelper Instance] StrToInt:newValue :[[_model GetProperty:@"fontSize"].DefaultValue intValue]] :_model.XZoom :_model.YZoom];
    curFontSize = fontSize;
    if (curFontStyle) {//和style关联
        [self change_fontStyle:curFontStyle];
    }
    else
    {
        UIFont *font = [UIFont systemFontOfSize:fontSize];
        [_attributeDict setObject:font forKey:NSFontAttributeName];
        [self changeText];
    }
    
}
- (void)change_fontStyle:(NSString *)newValue
{
    //自己的代码实现
    curFontStyle = newValue;
    UIFont *font;
    if([newValue isEqualToString:@"normal"])
    {
        [_attributeDict setObject:@0 forKey:NSObliquenessAttributeName];
        font = [UIFont systemFontOfSize:curFontSize];
    }
    else if([newValue isEqualToString:@"bold"])
    {
        [_attributeDict setObject:@0 forKey:NSObliquenessAttributeName];
        font = [UIFont boldSystemFontOfSize:curFontSize];
    }
    else if([newValue isEqualToString:@"italic"])
    {
        [_attributeDict setObject:@0.33 forKey:NSObliquenessAttributeName];
        font = [UIFont systemFontOfSize:curFontSize];
    }
    else if([newValue isEqualToString:@"bold_italic"])
    {
        [_attributeDict setObject:@0.33 forKey:NSObliquenessAttributeName];
        font = [UIFont boldSystemFontOfSize:curFontSize];
    }
    [_attributeDict setObject:font forKey:NSFontAttributeName];
    [self changeText];
}
- (void)change_maxHeight:(NSString *)newValue
{
    //自己的代码实现
    if([newValue floatValue] > 0)
    {
        maxHeight = [newValue floatValue]*_model.YZoom;
    }else{
        maxHeight = MAXFLOAT;
    }
}

- (void)change_maxLines:(NSString *)newValue
{
    //自己的代码实现
//    NSInteger number = [newValue integerValue];
//    if(number < 0)
//        number = [[_model GetProperty:@"maxLines"].DefaultValue intValue];
//    if (number != 1) {
//        self.lineBreakMode = NSLineBreakByWordWrapping;
//    }
//    self.numberOfLines = number;
}
- (void)change_maxWidth:(NSString *)newValue
{
    //自己的代码实现
    if([newValue floatValue] > 0)
    {
        maxWidth = [newValue floatValue]*_model.XZoom;
    }else{
        maxWidth = MAXFLOAT;
    }
}
- (void)change_span:(NSString *)newValue
{
    //自己的代码实现
    curSpan = newValue;
    [spans removeAllObjects];
    NSError *error;
    NSData *jsonData = [newValue dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc]initWithString:curText attributes:_attributeDict];
    @try {
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            NSException *ex = [NSException exceptionWithName:@"RichLabel1" reason:@"span参数错误" userInfo:nil];
            [ex raise];
        }
        for (NSDictionary *dict in jsonArray) {
            doSpanModel *spanModel = [doSpanModel doSpanModel:dict];
            [spans addObject:spanModel];
        }

        if (spans.count > 0 && curText.length > 0) {
            for (doSpanModel *spanModel in spans)
            {
                NSRange range;
                UIColor *fontColor = [doUIModuleHelper GetColorFromString:spanModel.fontColor :[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
//                [_spanAttribute setObject:fontColor forKey:NSForegroundColorAttributeName];
                UIFont *font = [UIFont systemFontOfSize:curFontSize];
//                if([spanModel.fontStyle isEqualToString:@"normal"])
//                {
//                    [_spanAttribute setObject:@0 forKey:NSObliquenessAttributeName];
//                    font = [UIFont systemFontOfSize:curFontSize];
//                }
//                else if([spanModel.fontStyle isEqualToString:@"bold"])
//                {
//                    [_spanAttribute setObject:@0 forKey:NSObliquenessAttributeName];
//                    font = [UIFont boldSystemFontOfSize:curFontSize];
//                }
//                else if([spanModel.fontStyle isEqualToString:@"italic"])
//                {
//                    [_spanAttribute setObject:@0 forKey:NSObliquenessAttributeName];
//                    font = [UIFont systemFontOfSize:curFontSize];
//                }
//                else if([spanModel.fontStyle isEqualToString:@"bold_italic"])
//                {
//                    [_spanAttribute setObject:@0.33 forKey:NSObliquenessAttributeName];
//                    font = [UIFont boldSystemFontOfSize:curFontSize];
//                }//不支持
                [_spanAttribute setObject:font forKey:NSFontAttributeName];
                self.linkTextAttributes = _spanAttribute;
                if (spanModel.strMatch && spanModel.strMatch.length > 0) {
                    NSArray *rangeArray = [self rangesOfString:spanModel.strMatch inString:curText];
                    for (NSValue *rangeValue in rangeArray) {
                        NSRange tempRange = [rangeValue rangeValue];
                        if ([spanModel.allowTouch boolValue]) {
                            [attriStr addAttribute:NSLinkAttributeName value:@"" range:tempRange];
                            [attriStr addAttribute:NSForegroundColorAttributeName value:fontColor range:tempRange];
                            [self curTextWithAttri:attriStr withFontStyle:spanModel.fontStyle withRange:&tempRange];
                        }
                        else
                        {
                            [attriStr addAttribute:NSForegroundColorAttributeName value:fontColor range:tempRange];
                            [self curTextWithAttri:attriStr withFontStyle:spanModel.fontStyle withRange:&tempRange];
                        }
                    }
                }
                if(spanModel.substring && spanModel.substring.length > 0)
                {
                    NSArray *rangeArray = [spanModel.substring componentsSeparatedByString:@","];
                    NSInteger loc = [[rangeArray objectAtIndex:0] integerValue];
                    NSInteger len = [[rangeArray objectAtIndex:1] integerValue] - [[rangeArray objectAtIndex:0]integerValue];
                    
                    if (len<0) {
                        len = 0;
                    }
                    range = NSMakeRange(loc, len);
                    if ([spanModel.allowTouch boolValue]) {
                        [attriStr addAttribute:NSLinkAttributeName value:@"" range:range];
                        [attriStr addAttribute:NSForegroundColorAttributeName value:fontColor range:range];
                        
                        [self curTextWithAttri:attriStr withFontStyle:spanModel.fontStyle withRange:&range];
                    }
                    else
                    {
                        [attriStr addAttribute:NSForegroundColorAttributeName value:fontColor range:range];
                        [self curTextWithAttri:attriStr withFontStyle:spanModel.fontStyle withRange:&range];
                    }
                }
            }
            
        }
    }
    @catch (NSException *exception) {
        [[doServiceContainer Instance].LogEngine WriteError:exception :exception.description];
        doInvokeResult *_invokeResult = [[doInvokeResult alloc]init];
        [_invokeResult SetException:exception];
    }
    @finally
    {
        [self setAttributedText:attriStr];
    }
}
- (void)change_text:(NSString *)newValue
{
    //自己的代码实现
    curText = newValue;
    if (curText.length > 0) {

        NSAttributedString *attriStr = [[NSAttributedString alloc]initWithString:curText attributes:_attributeDict];
        if (curSpan.length > 0) {
            [self change_span:curSpan];
        }
        else
        {
            [self setAttributedText:attriStr];
        }
        [self OnRedraw];
    }
}
- (void)change_textAlign:(NSString *)newValue
{
    //自己的代码实现
    NSTextAlignment align;
    if([newValue isEqualToString:@"left"])
    {
        align = NSTextAlignmentLeft;
    }
    else if([newValue isEqualToString:@"center"])
    {
        align = NSTextAlignmentCenter;
    }
    else if([newValue isEqualToString:@"right"])
    {
        align = NSTextAlignmentRight;
    }
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = align;
    paragraphStyle.lineSpacing = 3;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    [_attributeDict setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [self changeText];
}
- (void)change_textFlag:(NSString *)newValue
{
    //自己的代码实现
    if ([newValue isEqualToString:@"normal" ]) {
        [_attributeDict setObject:@(NSUnderlineStyleNone) forKey:NSUnderlineStyleAttributeName];
        [_attributeDict setObject:@(NSUnderlineStyleNone) forKey:NSStrikethroughStyleAttributeName];
    }else if ([newValue isEqualToString:@"underline" ]) {
        [_attributeDict setObject:@(NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
    }
    else if ([newValue isEqualToString:@"strikethrough" ]) {
        [_attributeDict setObject:@(NSUnderlineStyleSingle) forKey:NSStrikethroughStyleAttributeName];
    }
    [self changeText];
}
- (void)change_linesSpace:(NSString *)newValue
{
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = [newValue floatValue];
    [_attributeDict setObject:[UIFont systemFontOfSize:curFontSize] forKey:NSFontAttributeName];
    [_attributeDict setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [self changeText];
}
#pragma mark -私有方法
- (void) curTextWithAttri:(NSMutableAttributedString*)attriStr withFontStyle:(NSString *)fontStyle withRange:(NSRange *)range{
    
    if([fontStyle isEqualToString:@"normal"])
    {
        [attriStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:curFontSize] range:*range];
    }
    else if([fontStyle isEqualToString:@"bold"])
    {
        [attriStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:curFontSize] range:*range];
    }
    else if([fontStyle isEqualToString:@"italic"])
    {
        [attriStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:curFontSize] range:*range];
        [attriStr addAttribute:NSObliquenessAttributeName value:@0.33 range:*range];
    }
    else if([fontStyle isEqualToString:@"bold_italic"])
    {
        [attriStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:curFontSize] range:*range];
        [attriStr addAttribute:NSObliquenessAttributeName value:@0.33 range:*range];
    }
    
//    return attriStr;
}

- (CGSize)autoSize:(CGFloat)wight :(CGFloat)height
{
    NSString* text = self.text;
    if(text == nil) return CGSizeMake(0, 0);
    if(self.text!=nil)text = self.text;
    NSAttributedString *test = [[NSAttributedString alloc]initWithString:curText attributes:_attributeDict];
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading ;
    CGRect rect = [test boundingRectWithSize:CGSizeMake(wight, height)
                                        options:options
                                        context:nil];
    return rect.size;
}
- (BOOL)isAutoHeightOrAutoWidth
{
    BOOL isAutoHeight = [[_model GetPropertyValue:@"height"] isEqualToString:@"-1"];
    BOOL isAutoWidth = [[_model GetPropertyValue:@"width"] isEqualToString:@"-1"];
    if(isAutoHeight||isAutoWidth)
    {
        float cWidth,cHeight;
        if(isAutoWidth){
            cWidth =  maxWidth;
        }else{
            cWidth = _model.RealWidth;
        }
        if(isAutoHeight){
            cHeight = maxHeight;
        }else{
            cHeight = _model.RealHeight;
        }
        CGSize size = [self autoSize:cWidth :cHeight];
        float lastwidth = size.width;
        float lastheight = size.height;
        if(!isAutoWidth)
        {
            lastwidth = _model.RealWidth;
        }
        if(!isAutoHeight)
        {
            lastheight = _model.RealHeight;
        }
        if (maxHeight < lastheight) {
            lastheight = maxHeight;
        }
        if (maxWidth < lastwidth) {
            lastwidth = maxWidth;
        }
        self.frame = CGRectMake(_model.RealX, _model.RealY, lastwidth, lastheight);
    }
    self.contentSize = CGSizeMake(-1, -1);
    return isAutoWidth || isAutoHeight;
}
- (void)changeText
{
    if (curText.length > 1) {
        [self change_text:curText];
    }
}
- (NSArray *)rangesOfString:(NSString *)searchString inString:(NSString *)str {
    NSMutableArray *results = [NSMutableArray array];
    NSRange searchRange = NSMakeRange(0, [str length]);
    NSRange range;
    while ((range = [str rangeOfString:searchString options:0 range:searchRange]).location != NSNotFound) {
        [results addObject:[NSValue valueWithRange:range]];
        searchRange = NSMakeRange(NSMaxRange(range), [str length] - NSMaxRange(range));
    }
  return results;
}

/**
 *  点击链接，触发代理事件
 */
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    NSString *tempStr = [curText substringWithRange:characterRange];
    NSString *rangeStr = [NSString stringWithFormat:@"%lu,%lu",(unsigned long)characterRange.location,(unsigned long)(characterRange.length + characterRange.location)];
    
    NSError *error;
    NSData *jsonData = [curSpan dataUsingEncoding: NSUTF8StringEncoding];
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    for (NSDictionary *dict in jsonArray) {
        doSpanModel *spanMode = [doSpanModel doSpanModel:dict];
        NSRange subStringRange = [rangeStr rangeOfString:spanMode.substring];
        NSRange strMatch = [tempStr rangeOfString:spanMode.strMatch];
        if (subStringRange.location != NSNotFound ) {
            [node setObject:tempStr forKey:@"content"];
            [node setObject:spanMode.tag forKey:@"tag"];
            break;
        }
        if (strMatch.location != NSNotFound) {
            [node setObject:spanMode.strMatch forKey:@"content"];
            [node setObject:spanMode.tag forKey:@"tag"];
            break;
        }
    }
    doInvokeResult *invokeResult = [[doInvokeResult alloc]init];
    [invokeResult SetResultNode:node];
    [_model.EventCenter FireEvent:@"touch" :invokeResult];
    return NO;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView* tmpView = [super hitTest:point withEvent:event];
    
    if (tmpView == self) {
        if (isRegisterTouch) {
            return tmpView;
        }
    }
    return nil;
}
- (void)eventName:(NSString *)event :(NSString *)type
{
    if ([event hasPrefix:@"touch"]) {
        if ([type isEqualToString:@"on"])
        {
            isRegisterTouch = YES;
        }else
        {
            isRegisterTouch = NO;
        }
    }
}
#pragma mark - doIUIModuleView协议方法（必须）<大部分情况不需修改>
- (BOOL) OnPropertiesChanging: (NSMutableDictionary *) _changedValues
{
    //属性改变时,返回NO，将不会执行Changed方法
    return YES;
}
- (void) OnPropertiesChanged: (NSMutableDictionary*) _changedValues
{
    //_model的属性进行修改，同时调用self的对应的属性方法，修改视图
    [doUIModuleHelper HandleViewProperChanged: self :_model : _changedValues ];
}
- (BOOL) InvokeSyncMethod: (NSString *) _methodName : (NSDictionary *)_dicParas :(id<doIScriptEngine>)_scriptEngine : (doInvokeResult *) _invokeResult
{
    //同步消息
    return [doScriptEngineHelper InvokeSyncSelector:self : _methodName :_dicParas :_scriptEngine :_invokeResult];
}
- (BOOL) InvokeAsyncMethod: (NSString *) _methodName : (NSDictionary *) _dicParas :(id<doIScriptEngine>) _scriptEngine : (NSString *) _callbackFuncName
{
    //异步消息
    return [doScriptEngineHelper InvokeASyncSelector:self : _methodName :_dicParas :_scriptEngine: _callbackFuncName];
}
- (doUIModule *) GetModel
{
    //获取model对象
    return _model;
}

@end
