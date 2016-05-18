//
//  LELog.m
//  lelib
//
//  Created by Petr on 25/11/13.
//  Copyright (c) 2013,2014 Logentries. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LELog.h"
#import "LEBackgroundThread.h"
#import "LogFiles.h"
#import "lelib.h"


extern LEBackgroundThread* backgroundThread;

extern dispatch_queue_t le_write_queue;
extern char* le_token;

@implementation LELog

- (id)init
{
    self = [super init];
    if (le_init()) return nil;
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(notificationReceived:) name:UIApplicationWillEnterForegroundNotification object:nil];

    le_poke();

    return self;
}

- (void)dealloc
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)log:(NSObject*)object
{
    NSString* text = nil;
    
    if ([object respondsToSelector:@selector(leDescription)]) {
        id<LELoggableObject> leLoggableObject = (id<LELoggableObject>)object;
        text = [leLoggableObject leDescription];
    } else if ([object isKindOfClass:[NSString class]]) {
        text = (NSString*)object;
    } else {
        text = [object description];
    }
    
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"\u2028"];

    LE_DEBUG(@"%@", text);
    
    le_write_string(text);
    le_poke();
}

+ (void)log:(NSObject *)object{
    
    [[self sharedInstance] log:object];
}
+ (LELog*)sharedInstance
{
    static dispatch_once_t once;
    static LELog* sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [LELog new];
    });
    return sharedInstance;
}
+(LELog*)sessionWithToken:(NSString*)token{
    
    LELog * leLog = [self sharedInstance];
    [leLog setToken:token];
    return leLog;
}
- (void)setToken:(NSString *)token
{
    le_set_token([token cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)setDebugLogs:(BOOL)debugLogs
{
    le_set_debug_logs(debugLogs);
}

- (NSString*)token
{
    __block NSString* r = nil;
    dispatch_sync(le_write_queue, ^{
        
        if (!le_token || le_token[0]) {
            r = nil;
        } else {
            r = [NSString stringWithUTF8String:le_token];
        }
    });
    
    return r;
}

- (void)notificationReceived:(NSNotification*)notification
{
    if ([notification.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        
        if (self.logApplicationLifecycleNotifications) {
            [self log:notification.name];
        }
        
        le_poke();
        
        return;
    }
    
    if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification]) {
        [self log:notification.name];
        return;
    }
    
    if ([notification.name isEqualToString:UIApplicationWillResignActiveNotification]) {
        [self log:notification.name];
        return;
    }
    
    if ([notification.name isEqualToString:UIApplicationDidFinishLaunchingNotification]) {
        [self log:notification.name];
        return;
    }

    if ([notification.name isEqualToString:UIApplicationWillTerminateNotification]) {
        [self log:notification.name];
        return;
    }

    if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        [self log:notification.name];
        return;
    }
    
    if ([notification.name isEqualToString:UIApplicationDidReceiveMemoryWarningNotification]) {
        [self log:notification.name];
        return;
    }
}

- (void)registerForNotifications
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(notificationReceived:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [center addObserver:self selector:@selector(notificationReceived:) name:UIApplicationWillResignActiveNotification object:nil];
    [center addObserver:self selector:@selector(notificationReceived:) name:UIApplicationDidFinishLaunchingNotification object:nil];
    [center addObserver:self selector:@selector(notificationReceived:) name:UIApplicationWillTerminateNotification object:nil];
    [center addObserver:self selector:@selector(notificationReceived:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(notificationReceived:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)unregisterFromNotifications
{
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [center removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [center removeObserver:self name:UIApplicationDidFinishLaunchingNotification object:nil];
    [center removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [center removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)setLogApplicationLifecycleNotifications:(BOOL)logApplicationLifecycleNotifications
{
    @synchronized(self) {

        if (logApplicationLifecycleNotifications == _logApplicationLifecycleNotifications) return;
        
        _logApplicationLifecycleNotifications = logApplicationLifecycleNotifications;
        
        if (logApplicationLifecycleNotifications) {
            [self registerForNotifications];
        } else {
            [self unregisterFromNotifications];
        }
    }
}


@end
