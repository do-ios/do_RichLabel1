//
//  do_RichLabel1_View.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "do_RichLabel1_IView.h"
#import "do_RichLabel1_UIModel.h"
#import "doIUIModuleView.h"

@interface do_RichLabel1_UIView : UITextView<do_RichLabel1_IView, doIUIModuleView>
//可根据具体实现替换UIView
{
	@private
		__weak do_RichLabel1_UIModel *_model;
}
- (void)eventName:(NSString *)event :(NSString *)type;
@end
