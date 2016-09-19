//
//  XXPath.h
//  WifiUploadFile
//
//  Created by jiang on 16/9/18.
//  Copyright © 2016年 jiang. All rights reserved.
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
