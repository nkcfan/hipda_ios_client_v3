//
//  NSString+Hash.h
//  Orbitink
//
//  Created by mmackh on 5/3/13.
//  Copyright (c) 2013 Professional Consulting & Trading GmbH. All rights reserved.
//
/*
 * https://github.com/mmackh/Hacker-News-for-iOS/blob/master/Hacker%20News/NSString%2BAdditions.h
 */

#import <Foundation/Foundation.h>

@interface NSString (Additions)

- (NSString *)urlFriendlyFileNameWithExtension:(NSString *)extension prefixID:(int)prefixID;
- (NSString *)urlFriendlyFileName;
- (NSString *)stringByAppendingURLPathComponent:(NSString *)pathComponent;
- (NSString *)stringByDeletingLastURLPathComponent;

- (NSString *)sha512;
- (NSString *)base64Encode;
- (NSString *)base64Decode;

- (NSString*)stringBetweenString:(NSString *)start andString:(NSString *)end;

- (NSString *)stringByStrippingHTML;
- (NSString *)localCachePath;

- (NSString *)trim;
- (BOOL)isNumeric;
- (BOOL)containsString:(NSString *)needle;

// todo remove
- (NSString *)replaceWithPattern:(NSString *)pattern template:(NSString *)template isdot:(BOOL)isdot;
- (NSArray *)matchesWithPattern:(NSString *)pattern isdot:(BOOL)isdot;

- (int) indexOf:(NSString *)text;
- (UIColor *)colorFromHexString;
- (NSString*)stringFromString:(NSString *)start;

- (CGFloat)heightOfContentWithFont:(UIFont *)font width:(CGFloat)width;

__attribute__((overloadable))
NSString *substr(NSString *str, int start);
__attribute__((overloadable))
NSString *substr(NSString *str, int start, int length);

@end

@interface NSObject (isEmpty)

- (BOOL)mag_isEmpty;

@end
