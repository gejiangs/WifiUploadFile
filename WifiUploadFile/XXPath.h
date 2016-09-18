//
//  XXPath.h
//  Stock
//
//  Created by deger on 11-5-25.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface XXPath : NSObject 
{

}

+ (NSString *)homePath;
+ (NSString *)tempPath;
+ (NSString *)docPath;
+ (NSString *)privatePath;
+ (NSString *)appPath;
@end
