//
//  main.m
//  demo
//
//  Created by Petr on 25/11/13.
//  Copyright (c) 2013,2014 Logentries. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import "lecore.h"

int main(int argc, char * argv[])
{
    @autoreleasepool {
        le_init();
        le_set_token("602c8391-2af5-47a1-8c8e-4c002e0eef3d");
        le_log("Hello World"); // Change this
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
