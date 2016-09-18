//
//  XXHTTPConnection.m
//  Xiuxiu
//
//  Created by mac on 14-10-12.
//  Copyright (c) 2014年 yangdeger@gmail.com All rights reserved.
//

#import <HTTPDataResponse.h>
#import "XXHTTPConnection.h"
#import <UIKit/UIKit.h>
#import "HTTPDynamicFileResponse.h"
#import "MultipartFormDataParser.h"
#import "MultipartMessageHeaderField.h"
#import "HTTPMessage.h"
#import "XXPath.h"
//#import "../Config/Config.h"

@interface XXStatusResponse : NSObject<HTTPResponse>

- (NSInteger)status;

@end

@implementation XXStatusResponse


- (UInt64)contentLength
{
    return 0;
}

- (UInt64)offset
{
    return 0;
}

- (void)setOffset:(UInt64)offset
{
    
}


- (NSData *)readDataOfLength:(NSUInteger)length
{
    return nil;
}


- (BOOL)isDone
{
    return YES;
}


- (NSInteger)status
{
    return 302;
}
@end

@interface XXHTTPConnection()
{
    MultipartFormDataParser*        parser;
    NSFileHandle*					storeFile;
    
    NSMutableArray*					uploadedFiles;
}
@end

@implementation XXHTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
    if([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload"])
    {
       return YES;
    
    }
    return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
    if([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload"]) {
        // here we need to make sure, boundary is set in header
        NSString* contentType = [request headerField:@"Content-Type"];
        NSUInteger paramsSeparator = [contentType rangeOfString:@";"].location;
        if( NSNotFound == paramsSeparator ) {
            return NO;
        }
        if( paramsSeparator >= contentType.length - 1 ) {
            return NO;
        }
        NSString* type = [contentType substringToIndex:paramsSeparator];
        if( ![type isEqualToString:@"multipart/form-data"] ) {
            // we expect multipart/form-data content type
            return NO;
        }
        
        // enumerate all params in content-type, and find boundary there
        NSArray* params = [[contentType substringFromIndex:paramsSeparator + 1] componentsSeparatedByString:@";"];
        for( NSString* param in params ) {
            paramsSeparator = [param rangeOfString:@"="].location;
            if( (NSNotFound == paramsSeparator) || paramsSeparator >= param.length - 1 ) {
                continue;
            }
            NSString* paramName = [param substringWithRange:NSMakeRange(1, paramsSeparator-1)];
            NSString* paramValue = [param substringFromIndex:paramsSeparator+1];
            
            if( [paramName isEqualToString: @"boundary"] ) {
                // let's separate the boundary from content-type, to make it more handy to handle
                [request setHeaderField:@"boundary" value:paramValue];
            }
        }
        // check if boundary specified
        if( nil == [request headerField:@"boundary"] )  {
            return NO;
        }
        return YES;
    }

    BOOL result = [super expectsRequestBodyFromMethod:method atPath:path];
    return result;
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    if ([method isEqualToString:@"GET"])
    {
        if ([path isEqualToString:@"/getName"])
        {
            UIDevice *device = [UIDevice currentDevice];
            
            NSDictionary *dic = @{@"serverName" : device.name};
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
            HTTPDataResponse *response = [[HTTPDataResponse alloc] initWithData:data];
            return response;
        }
        else if ([path isEqualToString:@"/check"])
        {
            NSDictionary *dic = @{@"count" : @(4)};
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
            HTTPDataResponse *response = [[HTTPDataResponse alloc] initWithData:data];
            return response;
        }
    }
    else if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/upload"])
    {
        
        HTTPDataResponse *response = [[HTTPDataResponse alloc] initWithData:nil];
        return response;
    }
    return [super httpResponseForMethod:method URI:path];
}



- (void)prepareForBodyWithSize:(UInt64)contentLength
{
    
    // set up mime parser
    NSString* boundary = [request headerField:@"boundary"];
    parser = [[MultipartFormDataParser alloc] initWithBoundary:boundary formEncoding:NSUTF8StringEncoding];
    parser.delegate = self;
    
    uploadedFiles = [[NSMutableArray alloc] init];
}

- (void)processBodyData:(NSData *)postDataChunk
{
    // append data to the parser. It will invoke callbacks to let us handle
    // parsed data.
    [parser appendData:postDataChunk];
}


//-----------------------------------------------------------------
#pragma mark multipart form data parser delegate


- (void) processStartOfPartWithHeader:(MultipartMessageHeader*) header {
    // in this sample, we are not interested in parts, other then file parts.
    // check content disposition to find out filename
    
    MultipartMessageHeaderField* disposition = [header.fields objectForKey:@"Content-Disposition"];
    NSString* filename = [[disposition.params objectForKey:@"filename"] lastPathComponent];
    
    if ( (nil == filename) || [filename isEqualToString: @""] ) {
        // it's either not a file part, or
        // an empty form sent. we won't handle it.
        return;
    }
    
    NSString *uploadDirPath = [XXPath docPath];
    
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager]fileExistsAtPath:uploadDirPath isDirectory:&isDir ]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:uploadDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString* filePath = [uploadDirPath stringByAppendingPathComponent: filename];
    if( [[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
        storeFile = nil;
    }
    else {
        NSLog(@"Saving file to %@", filePath);
        if(![[NSFileManager defaultManager] createDirectoryAtPath:uploadDirPath withIntermediateDirectories:true attributes:nil error:nil]) {
            NSLog(@"Could not create directory at path: %@", filePath);
        }
        if(![[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil]) {
            NSLog(@"Could not create file at path: %@", filePath);
        }
        
//        [[NSNotificationCenter defaultCenter] postNotificationName:kXXMusicFilesChanged object:self userInfo:nil];
        storeFile = [NSFileHandle fileHandleForWritingAtPath:filePath];
        [uploadedFiles addObject: filename];
    }
}


- (void) processContent:(NSData*) data WithHeader:(MultipartMessageHeader*) header
{
    // here we just write the output from parser to the file.
    if( storeFile ) {
        [storeFile writeData:data];
    }
}

- (void) processEndOfPartWithHeader:(MultipartMessageHeader*) header
{
    // as the file part is over, we close the file.
    [storeFile closeFile];
    storeFile = nil;
}

- (void) processPreambleData:(NSData*) data
{
    // if we are interested in preamble data, we could process it here.
    
}

- (void) processEpilogueData:(NSData*) data 
{
    // if we are interested in epilogue data, we could process it here.
    
}

@end
