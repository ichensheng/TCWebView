//
//  NSString+TCExtensions.m
//  TCCategories
//
//  Created by 陈 胜 on 16/5/24.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "NSString+TCExtensions.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (TCExtensions)

- (BOOL)tc_isBlank {
    if ([self isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    return NO;
}

- (BOOL)tc_isChinese {
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}

- (CGSize)tc_boundingSizeWithFont:(UIFont *)font
                   constraintSize:(CGSize)size {
    
    return [self tc_boundingSizeWithFont:font constraintSize:size lineSpacing:0];
}

- (CGSize)tc_boundingSizeWithFont:(UIFont *)font
                   constraintSize:(CGSize)size
                      lineSpacing:(CGFloat)lineSpacing {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = lineSpacing;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle};
    return [self boundingRectWithSize:size
                              options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                           attributes:attributes
                              context:nil].size;
}

- (CGSize)tc_boundingSizeWithFont:(UIFont *)font
                   constraintSize:(CGSize)size
                         showLine:(NSInteger)line {
    
    NSString *seedString = @"国";
    CGFloat lineHeight = [seedString tc_boundingSizeWithFont:font
                                              constraintSize:CGSizeMake(MAXFLOAT, MAXFLOAT)].height;
    CGSize trueSize = [self tc_boundingSizeWithFont:font constraintSize:size];
    NSInteger numberOfLine = 0;
    CGFloat trueNumberOfLine = trueSize.height / lineHeight;
    if (trueNumberOfLine > line) {
        numberOfLine = line;
    } else {
        numberOfLine = floor(trueNumberOfLine);
        if (numberOfLine == 0) {
            numberOfLine = 1;
        }
    }
    return CGSizeMake(trueSize.width, numberOfLine * lineHeight);
}

- (NSString *)tc_MD5Digest {
    const char *str = [self UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *digest = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                        r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10],
                        r[11], r[12], r[13], r[14], r[15]];
    
    return digest;
}

static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
+ (NSString *)tc_randomString:(NSInteger)length {
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    for (NSInteger i = 0; i < length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

@end
