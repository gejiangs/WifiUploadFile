//
//  XXPath.m
//  Stock
//
//  Created by deger on 11-5-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "XXPath.h"

static NSString *s_DocPath = nil;

@implementation XXPath


+ (NSString *)homePath
{
	return NSHomeDirectory();
}

+ (NSString *)tempPath;
{
	return [NSTemporaryDirectory() stringByStandardizingPath];
}

+ (NSString *)docPath
{
    if (s_DocPath == nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        s_DocPath = paths[0];
    }
    return s_DocPath;
}

+ (NSString *)privatePath
{
    return [self docPath];
}

+ (NSString *)appPath
{
	return [[NSBundle mainBundle] bundlePath];
}
@end
