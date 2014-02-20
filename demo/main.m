//
//  main.m
//  demo
//
//  Created by Petr on 25/11/13.
//  Copyright (c) 2013 JLizard. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "lecore.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        le_init();
        le_set_token("f66815d1-702c-414b-8dcc-bb73de372584");
        le_log("nazdar");
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
