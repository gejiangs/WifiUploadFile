//
//  XXMusicAddViewController.m
//  Xiuxiu
//
//  Created by mac on 14-10-6.
//  Copyright (c) 2014年 yangdeger@gmail.com All rights reserved.
//

#import "XXMusicAddViewController.h"
//#import "../Managers/XXPath.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
//#import "../Config/Config.h"
#import <CocoaHTTPServer/HTTPServer.h>
#import "XXHTTPConnection.h"

@interface XXMusicAddViewController ()
{
    HTTPServer *_httpServer;
}

@end

@implementation XXMusicAddViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Wi-Fi传歌";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _httpServer = [[HTTPServer alloc] init];
    [_httpServer setConnectionClass:[XXHTTPConnection class]];
    // Tell the server to broadcast its presence via Bonjour.
    // This allows browsers such as Safari to automatically discover our service.
    [_httpServer setType:@"_http._tcp."];
    
    // Normally there's no need to run our server on any specific port.
    // Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
    // However, for easy testing you may want force a certain port so you can just hit the refresh button.
    [_httpServer setPort:25789];
    
    // Serve files from our embedded Web folder
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
    
    [_httpServer setDocumentRoot:webPath];
    
    NSError *error;
    if([_httpServer start:&error])
    {
        NSLog(@"Started HTTP Server on port %hu", [_httpServer listeningPort]);
    }
    else
    {
        NSLog(@"Error starting HTTP Server: %@", error);
    }
    
    
    NSString *ip = [self getIPAddress];
    self.addressLabel.layer.cornerRadius = 5.0;
    self.addressLabel.clipsToBounds = YES;
    self.addressLabel.text = [NSString stringWithFormat:@"http://%@:%i", ip, _httpServer.listeningPort];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillDisappear:(BOOL)animated
{
    [_httpServer stop];
}


#pragma mark -

// Get IP Address
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

@end
