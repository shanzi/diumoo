//
//  NSData+AESCrypt.h
//  DMAESCryptTEST
//
//  Created by Shanzi on 12-8-2.
//  Copyright (c) 2012年 Shanzi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AESCrypt)

-(NSData *)AES256EncryptWithKey:(NSString *)key;
-(NSData *)AES256DecryptWithKey:(NSString *)key;

@end
