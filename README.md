
Logentries logging for iOS
==========================


Main features
-------------

* online/offline logging
* dictionary serialization
* secure TLS connection
* thread safety
* application lifecycle logging
* application crash logging with stack traces

Installation
------------

Just add files from lelib group into your project.

Need a token? Get a free account if you don't already have one.

Simple example
--------------

```objectivec
#import "lelib.h"

LELog* log = [LELog sharedInstance];
log.token = @"LOGENTRIES_TOKEN";

[log log:@"Hello World"];
```

Early initialization
--------------------

The library automatically hooks up to the exception handler and logs unhandled
exceptions. This means that you should initialize the library as soon as
possible to log all exceptions. Insert following lines to main.m to log
exceptions even before application:didFinishLaunchingWithOptions: is invoked.

```objectivec

#import "lecore.h"

int main(int argc, char * argv[])
{
  @autoreleasepool {

    le_init();
    le_set_token("LOGENTRIES_TOKEN");

    return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
  }
}

The token is stored in global variable. You do not have to setup token property
of LELog instance later.

```

Disable Console Logger
----------------------
To disable the logger from logging to the console set `LE_DEBUG_LOGS` to 0 in lelib.h.

Quick questions
---------------

**Any dependencies?** No dependencies. The library uses standard Obj-C and POSIX C.

**How to log an event?** Simply call `[log log:@"Hello world"];`

**No network coverage?** Log entries are stored in a file and sent to Logentries when the network is back.

**When app crashes?** If configured, the library logs information about the application crash with stack trace.

**When app is forced to shut down by OS?** There is no way to log it.

