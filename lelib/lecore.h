//
//  lecore.h
//  lelib
//
//  Created by Petr on 06.01.14.
//  Copyright (c) 2014 Logentries. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef lelib_lecore_h
#define lelib_lecore_h

#define TOKEN_LENGTH                    36
#define MAXIMUM_LOGENTRY_SIZE           8192

#define MAXIMUM_FILE_COUNT              3
#define MAXIMUM_LOGFILE_SIZE            (1024 * 1024)

extern void LE_DEBUG(NSString *format, ...);

/* Pure C API */

int le_init(void);
void le_handle_crashes(void);
void le_poke(void);
void le_log(const char* message);
void le_write_string(NSString* string);
void le_set_token(const char* token);
bool is_valid_token(const char* token,size_t *token_length);
void le_set_debug_logs(bool verbose);

#endif
