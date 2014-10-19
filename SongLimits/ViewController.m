//
//  ViewController.m
//  SongLimits
//
//  Created by Roger on 10/18/14.
//  Copyright (c) 2014 Roger Zou. All rights reserved.
//

#import "ViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) MPMusicPlayerController *player;
@property (strong, nonatomic) NSArray *lengthArray;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *songButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *queueLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.activityIndicator stopAnimating];
    self.player = [[MPMusicPlayerController alloc]init];
    
    //set listen to notifs. default apple code https://developer.apple.com/Library/ios/documentation/Audio/Conceptual/iPodLibraryAccess_Guide/UsingMediaPlayback/UsingMediaPlayback.html
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_NowPlayingItemChanged:)
     name:        MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:      self.player];
    
    [notificationCenter
     addObserver: self
     selector:    @selector (handle_PlaybackStateChanged:)
     name:        MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:      self.player];
    
    [self.player beginGeneratingPlaybackNotifications];
    
    //self.songButton.layer.borderColor = self.songButton.titleLabel.textColor.CGColor;
    //self.songButton.layer.borderWidth = 1;
    //self.songButton.layer.cornerRadius = self.songButton.frame.size.height/8;
    
    /*
    NSNotificationCenter *notifyCenter = [NSNotificationCenter defaultCenter];
    [notifyCenter addObserverForName:nil
                              object:nil
                               queue:nil
                          usingBlock:^(NSNotification* notification){
                              // Explore notification
                              NSLog(@"Notification found with:"
                                    "\r\n     name:     %@"
                                    "\r\n     object:   %@"
                                    "\r\n     userInfo: %@",
                                    [notification name],
                                    [notification object],
                                    [notification userInfo]);
                          }];
    //MPMusicPlayerController *player = [MPMusicPlayerController applicationMusicPlayer];
    MPMusicPlayerController *player = [MPMusicPlayerController systemMusicPlayer];
    NSLog(@"%@", player.nowPlayingItem);
    [player beginGeneratingPlaybackNotifications];
    */
    /*
    int i = 0;
    NSTimeInterval totaltime = 0;
    totaltime += player.nowPlayingItem.playbackDuration - player.nowPlayingItem.bookmarkTime;
    NSTimeInterval storetime = player.currentPlaybackTime;//player.nowPlayingItem.bookmarkTime;
    for (;i < 2; i++) {
        [player skipToNextItem];
        NSLog(@"%@ with time %f", player.nowPlayingItem, player.nowPlayingItem.playbackDuration);
        totaltime += player.nowPlayingItem.playbackDuration;
    }
    for (;i > 0; i--) {
        [player skipToPreviousItem];
        NSLog(@"back %@", player.nowPlayingItem);
    }
    //player.nowPlayingItem.bookmarkTime = storetime;
    player.currentPlaybackTime = storetime;
     */
}

- (IBAction)setQueue:(id)sender {
    [self.activityIndicator startAnimating];
    [self.player pause];
    NSMutableArray *items = [NSMutableArray array];
    NSUInteger totaltime = 0;
    NSInteger pickerindex = [self.pickerView selectedRowInComponent:0];
    pickerindex += 1;
    for (int i = 0; i < pickerindex; i++) {
        if (self.player.nowPlayingItem == nil) {
            pickerindex = i;
            break;
        }
        [items addObject:self.player.nowPlayingItem];
        totaltime += self.player.nowPlayingItem.playbackDuration;
        [self.player skipToNextItem];
    }
    
    if ([items count]) {
        MPMediaItemCollection *holder = [[MPMediaItemCollection alloc]initWithItems:items];
        [self.player stop];
        [self.player setQueueWithItemCollection:holder];
        [self.player play];
        self.queueLabel.text = [NSString stringWithFormat:@"Queue set to %li. %lu:%lu long", (long)pickerindex, totaltime/60, totaltime % 60];
    }
    [self.activityIndicator stopAnimating];
}


//lazy instantiation
- (NSArray *)lengthArray
{
    if (!_lengthArray) {
        NSMutableArray *placeholder = [NSMutableArray array];
        for (int i = 1; i < 100; i++) {
            [placeholder addObject:@(i)];
        }
        return [NSArray arrayWithArray:placeholder];
    }
    return _lengthArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handle_NowPlayingItemChanged: (NSNotification *)notification {
    
}

- (void)handle_PlaybackStateChanged: (NSNotification *)notification {
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //default apple code https://developer.apple.com/Library/ios/documentation/Audio/Conceptual/iPodLibraryAccess_Guide/UsingMediaPlayback/UsingMediaPlayback.html
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name:           MPMusicPlayerControllerNowPlayingItemDidChangeNotification
     object:         self.player];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name:           MPMusicPlayerControllerPlaybackStateDidChangeNotification
     object:         self.player];
    
    [self.player endGeneratingPlaybackNotifications];
    
}


#pragma mark - UIPickerView
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.lengthArray count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.lengthArray[row] stringValue];
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

@end
