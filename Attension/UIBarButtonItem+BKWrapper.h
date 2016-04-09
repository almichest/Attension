//
//  UIBarButtonItem+BKWrapper.h
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/10.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (BKWrapper)

+ (instancetype)itemWithSystemItem:(UIBarButtonSystemItem)systemItem handler:(void (^)(id sender))action;

@end
