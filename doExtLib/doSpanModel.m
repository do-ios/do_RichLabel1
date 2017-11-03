//
//  doSpanModel.m
//  Do_Test
//
//  Created by yz on 16/1/21.
//  Copyright © 2016年 DoExt. All rights reserved.
//

#import "doSpanModel.h"

@implementation doSpanModel

+ (instancetype)doSpanModel:(NSDictionary *)dict
{
    return [[self alloc]initDoSpanModel:dict];
}
- (instancetype)initDoSpanModel:(NSDictionary *)dict
{
    if (self = [super init]) {
        NSString *temp = [[dict objectForKey:@"strMatch"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        self.strMatch = temp;
        self.substring = [dict objectForKey:@"substring"];
        NSString *spanStyle = [dict objectForKey:@"spanStyle"];
        NSData *tempData = [spanStyle dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *tempDict = [NSJSONSerialization JSONObjectWithData:tempData options:NSJSONReadingMutableLeaves error:&error];
        self.fontColor = [tempDict objectForKey:@"fontColor"];
        self.fontStyle = [tempDict objectForKey:@"fontStyle"];
        self.allowTouch = [dict objectForKey:@"allowTouch"];
        self.tag = [dict objectForKey:@"tag"];
    }
    return self;
}
@end
