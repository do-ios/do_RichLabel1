//
//  doSpanModel.h
//  Do_Test
//
//  Created by yz on 16/1/21.
//  Copyright © 2016年 DoExt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface doSpanModel : NSObject
@property (nonatomic,strong) NSString *strMatch;
@property (nonatomic,strong) NSString *substring;
@property (nonatomic,strong) NSString *fontColor;
@property (nonatomic,strong) NSString *fontStyle;
@property (nonatomic,strong) NSString *allowTouch;
@property (nonatomic,strong) NSString *tag;

+(instancetype)doSpanModel:(NSDictionary *)dict;
-(instancetype)initDoSpanModel:(NSDictionary *)dict;
@end
