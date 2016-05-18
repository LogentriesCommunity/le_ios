//
//  lecore.c
//  lelib
//
//  Created by Petr on 06.01.14.
//  Copyright (c) 2014 Logentries. All rights reserved.
//



#include "LEBackgroundThread.h"
#include "LogFiles.h"

#include "lelib.h"

LEBackgroundThread* backgroundThread;

dispatch_queue_t le_write_queue;
char* le_token;
bool le_debug_logs = false;

static int logfile_descriptor;
static off_t logfile_size;
static int file_order_number;

static char buffer[MAXIMUM_LOGENTRY_SIZE];

static void (*saved_le_exception_handler)(NSException *exception);

void LE_DEBUG(NSString *format, ...) {
#if DEBUG
    if (le_debug_logs) {
        va_list args;
        va_start(args, format);
        NSLogv(format, args);
        va_end(args);
    }
#endif
}

/*
 Sets logfile_descriptor to -1 when fails, this means that all subsequent write attempts will fail
 return 0 on success
 */
static int open_file(const char* path)
{
    mode_t mode = 0664;
    
    logfile_size = 0;
    
    logfile_descriptor = open(path, O_CREAT | O_WRONLY, mode);
    if (logfile_descriptor < 0) {
        LE_DEBUG(@"Unable to open log file.");
        return 1;
    }
    
    logfile_size = lseek(logfile_descriptor, 0, SEEK_END);
    if (logfile_size < 0) {
        LE_DEBUG(@"Unable to seek at end of file.");
        return 1;
    }
    
    LE_DEBUG(@"log file %s opened", path);
    return 0;
}

void le_poke(void)
{
    if (!backgroundThread) {
        backgroundThread = [LEBackgroundThread new];
        backgroundThread.name = @"Logentries";
                
        NSCondition* initialized = [NSCondition new];
        backgroundThread.initialized = initialized;
        
        [initialized lock];
        [backgroundThread start];
        [initialized wait];
        [initialized unlock];
    }
    
    [backgroundThread performSelector:@selector(poke:) onThread:backgroundThread withObject:@(file_order_number) waitUntilDone:NO modes:@[NSDefaultRunLoopMode]];
}

static void le_exception_handler(NSException *exception)
{
    NSString* message = [NSString stringWithFormat:@"Exception name=%@, reason=%@, userInfo=%@ addresses=%@ symbols=%@", [exception name], [exception reason], [exception userInfo], [exception callStackReturnAddresses], [exception callStackSymbols]];
    LE_DEBUG(@"%@", message);
    message = [message stringByReplacingOccurrencesOfString:@"\n" withString:@"\u2028"];
    le_log([message cStringUsingEncoding:NSUTF8StringEncoding]);
    
    if (saved_le_exception_handler) {
        saved_le_exception_handler(exception);
    }
}

int le_init(void)
{
    static dispatch_once_t once;
    
    __block int r = 0;
    
    dispatch_once(&once, ^{

        // pesimistic strategy
        r = 1;
        
        le_write_queue = dispatch_queue_create("com.logentries.write", NULL);
        
        LogFiles* logFiles = [LogFiles new];
        if (!logFiles) {
            LE_DEBUG(@"Error initializing logs directory.");
            return;
        }
        
        [logFiles consolidate];
        
        LogFile* file = [logFiles fileToWrite];
        file_order_number = (int)file.orderNumber;
        NSString* logFilePath = [file logPath];
        
        const char* path = [logFilePath cStringUsingEncoding:NSASCIIStringEncoding];
        if (!path) {
            LE_DEBUG(@"Invalid logfile path.");
            return;
        }
        
        if (open_file(path)) {
            return;
        };
        
        r = 0;
        
        return;
    });
    
    return r;
}

void le_handle_crashes(void)
{
    saved_le_exception_handler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&le_exception_handler);
}

/*
 Takes used_length characters from buffer, appends a space and token and writes in into log. Handles log rotation.
 */
static void write_buffer(size_t used_length)
{
    if ((size_t)logfile_size + used_length > MAXIMUM_LOGFILE_SIZE) {
        
        close(logfile_descriptor);
        file_order_number++;
        
        LogFile* logFile = [[LogFile alloc] initWithNumber:file_order_number];
        NSString* p = [logFile logPath];
        const char* path = [p cStringUsingEncoding:NSASCIIStringEncoding];
        
        open_file(path);
    }
    
    ssize_t written = write(logfile_descriptor, buffer, (size_t)used_length);
    if (written < (ssize_t)used_length) {
        LE_DEBUG(@"Could not write to log, no space left?");
        return;
    }
    
    logfile_size += written;
}

void le_log(const char* message)
{
    dispatch_sync(le_write_queue, ^{
        
        size_t token_length;
        
        if(!is_valid_token(le_token,&token_length))
            return ;
        

        size_t max_length = MAXIMUM_LOGENTRY_SIZE - token_length - 2; // minus token length, space separator and lf
        
        size_t length = strlen(message);
        if (max_length < length) {
            LE_DEBUG(@"Too large message, it will be truncated");
            length = max_length;
        }

        memcpy(buffer, le_token, token_length);
        buffer[token_length] = ' ';
        memcpy(buffer + token_length + 1, message, length);
        
        size_t total_length = token_length + 1 + length;
        buffer[total_length++] = '\n';
        
        write_buffer(total_length);
        le_poke();
    });
    
}

void le_write_string(NSString* string)
{
    dispatch_sync(le_write_queue, ^{
        
        size_t token_length;
        if(!is_valid_token(le_token,&token_length))
            return ;
        
        NSUInteger maxLength = MAXIMUM_LOGENTRY_SIZE - token_length - 2; // minus token length, space separator and \n
        if ([string length] > maxLength) {
            LE_DEBUG(@"Too large message, it will be truncated");
        }
        
        memcpy(buffer, le_token, token_length);
        buffer[token_length] = ' ';

        NSRange range = {.location = 0, .length = [string length]};
        
        NSUInteger usedLength = 0;
        BOOL r = [string getBytes:(buffer + token_length + 1) maxLength:maxLength usedLength:&usedLength encoding:NSUTF8StringEncoding options:NSStringEncodingConversionAllowLossy range:range remainingRange:NULL];
        
        if (!r) {
            LE_DEBUG(@"Error converting message characters.");
            return;
        }
        
        NSUInteger totalLength = token_length + 1 + usedLength;
        buffer[totalLength++] = '\n';
        write_buffer((size_t)totalLength);
    });
}

void le_set_token(const char* token)
{
    size_t length ;
    if(!is_valid_token(token,&length))
        return;
    
    char* local_buffer = malloc(length + 1);
    if (!local_buffer) {
        LE_DEBUG(@"Can't allocate token buffer.");
        return ;
    }
    strlcpy(local_buffer, token, length + 1);
    
    dispatch_sync(le_write_queue, ^{
        le_token = local_buffer;
    });
}

bool is_valid_token(const char * token,size_t* token_length)
{
    size_t length = 0;
    
    if (token == NULL) {
        NSLog(@"nil token\n");
        LE_DEBUG(@"nil token");
        return false;
    }
    
    length = strlen(token);
    
    if(token_length != NULL)
        *token_length = length;
    
    if (length < TOKEN_LENGTH) {
        LE_DEBUG(@"Invalid token length, it will not be used.");
        return false;
    }
    
    return true;
}

void le_set_debug_logs(bool debug) {
    le_debug_logs = debug;
}
