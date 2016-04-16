//
//  UIBarButtonItem+BKWrapper.m
//  Attension
//
//  Created by Hiraku Ohno on 2016/04/10.
//  Copyright © 2016年 Hiraku Ohno. All rights reserved.
//

#import "UIBarButtonItem+BKWrapper.h"
#import "UIBarButtonItem+BlocksKit.h"

@implementation UIBarButtonItem (BKWrapper)

+ (instancetype)itemWithSystemItem:(UIBarButtonSystemItem)systemItem handler:(void (^)(id sender))action {
    return [[self alloc] bk_initWithBarButtonSystemItem:systemItem handler:action];
}

@end
