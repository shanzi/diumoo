//
//  debugLog.h
//  diumoo
//
//  Created by Zheng Anakin on 12-6-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#ifdef DEBUG
#define DMLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define DMLog(format, ...)
#endif