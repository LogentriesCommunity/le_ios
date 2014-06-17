//
//  ViewController.m
//  demo
//
//  Created by Petr on 25/11/13.
//  Copyright (c) 2013,2014 Logentries. All rights reserved.
//

#import "ViewController.h"
#import "lelib.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)writeTimerFired:(NSTimer*)timer
{
    LELog* log = [LELog sharedInstance];
    [log log:timer.userInfo];
}

- (void)scheduleLog:(NSString*)message after:(NSTimeInterval)seconds
{
    [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(writeTimerFired:) userInfo:message repeats:NO];
}

- (void)logManyFired:(NSTimer*)timer
{
    static NSInteger counter = 1;
    
    if (counter > 10) return;
    
    LELog* log = [LELog sharedInstance];
    for (NSInteger i = 1; i < 10; i++) {
        NSString* message = [NSString stringWithFormat:@"logging serie %ld index %ld", (long)counter, (long)i];
        [log log:message];
    }

    counter++;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    LELog* log = [LELog sharedInstance];
    log.token = @"f66815d1-702c-414b-8dcc-bb73de372584";
    log.logApplicationLifecycleNotifications = YES;
    

/*
    // test exception logging handler
    NSArray* x = [NSArray arrayWithObject:nil];
    NSLog(@"%@", x);
 */
    
/*  
    // simple logging
    [log log:@"test A"];
    [log log:@"test B"];
    [log log:@{@(123):@"test C"}];
 */
    
    [self scheduleLog:@"test 10s" after:10];
    [self scheduleLog:@"test 20s" after:20];

/*
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(logManyFired:) userInfo:nil repeats:YES];
*/
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
