//
//  NSUUID+TCExtensions.m
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "NSUUID+TCExtensions.h"

@implementation NSUUID (TCExtensions)

/**
 *  生成短UUID字符串
 *
 *  @return 短UUID字符串
 */
+ (NSString *)tc_shortUUIDString {
    NSString *UUIDString = [[NSUUID UUID] UUIDString];
    NSString *hexString = [UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSData *data = [self dataWithHexString:hexString];
    return [self base32EncodingWithData:data];
}

+ (NSData *)dataWithHexString:(NSString *)hexString {
    const char *chars = hexString.UTF8String;
    NSUInteger length = hexString.length;
    
    NSMutableData *data = [NSMutableData dataWithCapacity:length / 2];
    char byteChars[3] = {'\0','\0','\0'};
    unsigned long wholeByte;
    
    NSUInteger i = 0;
    while (i < length) {
        byteChars[0] = chars[i++];
        byteChars[1] = chars[i++];
        wholeByte = strtoul(byteChars, NULL, 16);
        [data appendBytes:&wholeByte length:1];
    }
    
    return data;
}

+ (NSString *)base32EncodingWithData:(NSData *)data {
    NSUInteger length = data.length;
    const unsigned char *dataBuffer = data.bytes;
    
    if (length == 0 || !dataBuffer) {
        return nil;
    }
    
    int bufSize = 256;
    char result[bufSize];
    
    NSUInteger count = 0;
    unsigned long buffer = dataBuffer[0];
    int next = 1;
    int bitsLeft = 8;
    while (count < bufSize && (bitsLeft > 0 || next < length)) {
        if (bitsLeft < 5) {
            if (next < length) {
                buffer <<= 8;
                buffer |= dataBuffer[next++] & 0xFF;
                bitsLeft += 8;
            } else {
                int pad = 5 - bitsLeft;
                buffer <<= pad;
                bitsLeft += pad;
            }
        }
        int index = 0x1F & (buffer >> (bitsLeft - 5));
        bitsLeft -= 5;
        result[count++] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"[index];
    }
    if (count < bufSize) {
        result[count] = '\000';
    }
    
    return [NSString stringWithUTF8String:result];
}

@end
