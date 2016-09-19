//
//  ViewController.m
//  WifiUploadFile
//
//  Created by jiang on 16/9/18.
//  Copyright © 2016年 jiang. All rights reserved.
//

#import "HomeViewController.h"
#import "AddFileViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "XXPath.h"

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,strong) NSMutableArray *songs;
@property(nonatomic,assign) NSUInteger playingIndex;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"音乐列表";
    
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(add)];
    self.navigationItem.rightBarButtonItem = rightBar;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadMusic];
}

-(void)add
{
    AddFileViewController *vc = [[AddFileViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)loadMusic
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [XXPath docPath];
    
    NSMutableArray *musicFiles = [NSMutableArray array];
    NSError *error = nil;
    NSArray *names = [manager contentsOfDirectoryAtPath:path error:&error];
    if (!error)
    {
        for (NSString *name in names)
        {
            if ([name hasSuffix:@".mp3"])
            {
                NSString *filepath = [path stringByAppendingPathComponent:name];
                [musicFiles addObject:filepath];
            }
        }
    }
    self.songs = musicFiles;
    [self.tableView reloadData];
}

- (void)setPlayingIndex:(NSUInteger)playingIndex
{
    if (_playingIndex != playingIndex)
    {
        _playingIndex = playingIndex;
        [self.tableView reloadData];
    }
}


#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.songs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    NSString *path = self.songs[indexPath.row];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    AVAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    for (NSString *format in [asset availableMetadataFormats])
    {
        for (AVMetadataItem *item in [asset metadataForFormat:format])
        {
            NSString *key = item.commonKey;
            if ([key isEqualToString:@"title"])
            {
                info[MPMediaItemPropertyTitle] = item.value;
            }
            else if ([key isEqualToString:@"artist"])
            {
                info[MPMediaItemPropertyArtist] = item.value;
            }
            else if ([key isEqualToString:@"albumName"])
            {
                info[MPMediaItemPropertyAlbumTitle] = item.value;
            }
        }
    }
    cell.textLabel.text = info[MPMediaItemPropertyTitle];
    cell.detailTextLabel.text = info[MPMediaItemPropertyAlbumTitle];
    
    cell.accessoryType = _playingIndex == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *path = self.songs[indexPath.row];
        [self.songs removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
        NSError *error = nil;
        NSFileManager *mananger = [NSFileManager defaultManager];
        [mananger removeItemAtPath:path error:&error];
        if (error)
        {
            NSLog(@"Remove Item %@ fail", path);
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.playingIndex)
    {
        self.playingIndex = NSNotFound;
    }
    else
    {
        self.playingIndex = indexPath.row;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    [mediaPicker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [mediaPicker dismissViewControllerAnimated:YES completion:NULL];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

