//
//  lelib.h
//  lelib
//
//  Created by Petr on 27.10.13.
//  Copyright (c) 2013 JLizard. All rights reserved.
//

#ifndef LE_DEBUG_LOGS
    #ifdef DEBUG
        #define LE_DEBUG_LOGS 1
    #else
        #define LE_DEBUG_LOGS 0
    #endif
#endif

#if LE_DEBUG_LOGS
#define LE_DEBUG(...)         NSLog(__VA_ARGS__)
#else
#define LE_DEBUG(...)
#endif

#import "LELog.h"
#import "lecore.h"
