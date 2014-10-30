//
//  Shell.h
//  Utils
//
//  Created by wayos-ios on 10/13/14.
//  Copyright (c) 2014 webuser. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Shell : NSObject
+ (NSArray *)ls;
+ (NSArray *)ls:(NSString *)path;
+ (NSString *)pwd;
+ (NSString *) cat:(NSString *)file;
+ (BOOL) cd:(NSString *)path;
+ (NSArray *) ps;
//被阉割了得, 这几个被apple动了手脚, 755也进不了, 只有777才能进入
+ (BOOL) mkdir:(NSString *)path;
+ (BOOL) rmdir:(NSString *)path;
+ (BOOL) chmod:(NSString *)file;
//end
+ (NSString *)uname;
+ (void) test;
+ (BOOL) touch:(NSString *)file;
+ (BOOL) writeTo:(NSString *)path content:(NSString *)content;
+ (BOOL) rm:(NSString *)file;
//ios7的system函数被阉了
+ (NSString *)exec:(NSString *)commond;
+ (BOOL)ping:(NSString *)ip;
+ (NSArray *)arp;
+ (NSString *)df;
+ (NSString *)top;
+ (NSString *)route;
@end
