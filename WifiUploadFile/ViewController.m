//
//  ViewController.m
//  WifiUploadFile
//
//  Created by jiang on 16/9/18.
//  Copyright © 2016年 jiang. All rights reserved.
//

#import "ViewController.h"
#import "XXMusicAddViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(add)];
    self.navigationItem.rightBarButtonItem = rightBar;
}

-(void)add
{
    XXMusicAddViewController *vc = [[XXMusicAddViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
