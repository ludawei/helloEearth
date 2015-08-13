//
//  CWMoviePlayView.m
//  TestMapCover-Pad
//
//  Created by 卢大维 on 15/7/11.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "CWMoviePlayView.h"
#import <AVFoundation/AVFoundation.h>

@interface CWMoviePlayView ()
{
    BOOL _played;
    NSString *_totalTime;
    BOOL showControlls;
    BOOL isLoaded;
}

@property (nonatomic,strong) NSURL *url;

@property (nonatomic ,strong) AVPlayer *player;
@property (nonatomic ,strong) AVPlayerItem *playerItem;

@property (nonatomic,strong) UIView *toolView;
@property (nonatomic ,strong) UIButton *stateButton,*expButton;
@property (nonatomic ,strong) UILabel *timeLabel,*totalTimeLabel;
@property (nonatomic ,strong) id playbackTimeObserver;
@property (nonatomic ,strong) UISlider *videoSlider;
@property (nonatomic ,strong) UIProgressView *videoProgress;

@end

@implementation CWMoviePlayView

-(instancetype)initWithFrame:(CGRect)frame withUrl:(NSURL *)url
{
    if (self = [super initWithFrame:frame]) {
        
        self.url = url;
        [self initViews];
        
        NSURL *videoUrl = self.url;//[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Movie" ofType:@"m4v"]];//[NSURL URLWithString:@"http://www.jxvdy.com/file/upload/201405/05/18-24-58-42-627.mp4"];
        self.playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
        [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
        [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        self.playerView.player = self.player;
        self.playerView.backgroundColor = [UIColor blackColor];
        self.stateButton.enabled = NO;
        
        // 添加视频播放结束通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    }
    
    return self;
}

-(void)initViews
{
    self.playerView = [[PlayerView alloc] initWithFrame:self.bounds];
    [self addSubview:self.playerView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.width-50, 0, 50, 50)];
    button.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [button setImage:[UIImage imageNamed:@"icon_live_close"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(clickClose) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
//    self.toolView = [[UIView alloc] initWithFrame:CGRectZero];
//    self.toolView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
//    [self addSubview:self.toolView];
    
    self.stateButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.stateButton setImage:[UIImage imageNamed:@"icon_full_play"] forState:UIControlStateNormal];
    [self.stateButton addTarget:self action:@selector(stateButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:self.stateButton];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.text = @"time";
    self.timeLabel.font = [UIFont systemFontOfSize:10];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.toolView addSubview:self.timeLabel];
    
    self.videoProgress = [[UIProgressView alloc] initWithFrame:CGRectZero];
    [self.toolView addSubview:self.videoProgress];
    
    self.videoSlider = [[UISlider alloc] initWithFrame:self.videoProgress.frame];
    [self.videoSlider addTarget:self action:@selector(videoSlierChangeValue:) forControlEvents:UIControlEventValueChanged];
    [self.videoSlider addTarget:self action:@selector(videoSlierChangeValueEnd:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoSlider setThumbImage:[UIImage imageNamed:@"icon_full_slider_thuml"] forState:UIControlStateNormal];
    [self.toolView addSubview:self.videoSlider];
    
    self.totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.totalTimeLabel.text = @"time";
    self.totalTimeLabel.font = [UIFont systemFontOfSize:10];
    self.totalTimeLabel.textColor = [UIColor whiteColor];
    self.totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.toolView addSubview:self.totalTimeLabel];
    
//    self.expButton = [[UIButton alloc] initWithFrame:CGRectZero];
//    [self.expButton setImage:[UIImage imageNamed:@"icon_full_exp"] forState:UIControlStateNormal];
//    [self.expButton addTarget:self action:@selector(expButtonTouched) forControlEvents:UIControlEventTouchUpInside];
//    [self.toolView addSubview:self.expButton];
    
//    self.toolView.hidden = !self.fullStatus;
    
    //    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 40, 40)];
    //    button.showsTouchWhenHighlighted = YES;
    //    [button setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    //    [button addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    //    button.backgroundColor = [UIColor clearColor];
    //    [self.view addSubview:button];
    //    self.closeButton = button;
    //    self.closeButton.hidden = YES;
    
    //    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 45, 0, 40, 40)];
    //    button1.showsTouchWhenHighlighted = YES;
    ////    [button1 setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    //    [button1 setTitle:@"分享" forState:UIControlStateNormal];
    //    [button1 addTarget:self action:@selector(shareButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    //    button1.backgroundColor = [UIColor clearColor];
    //    [self.view addSubview:button1];
    //    self.shareButton = button1;
    //    self.shareButton.hidden = YES;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    [self stateButtonTouched];
    
    isLoaded = YES;
    
    //    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    //    [self.view addGestureRecognizer:tap];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.width > self.height) {
        self.fullStatus = YES;
        self.toolView.hidden = !self.fullStatus;
        
        self.toolView.frame = CGRectMake(0, self.bounds.size.height-40, self.bounds.size.width, 40);
        
        CGFloat buttonWidth = 40;
        CGFloat toolWidth = self.toolView.bounds.size.width,toolHeight = self.toolView.bounds.size.height;
        self.stateButton.frame = CGRectMake(0, 0, buttonWidth, toolHeight);
        self.timeLabel.frame = CGRectMake(CGRectGetMaxX(self.stateButton.frame), 0, buttonWidth, toolHeight);
        self.videoProgress.frame = CGRectMake(CGRectGetMaxX(self.timeLabel.frame), 0, toolWidth-CGRectGetMaxX(self.timeLabel.frame)-buttonWidth, 10);
        self.videoProgress.center = CGPointMake(CGRectGetMidX(self.videoProgress.frame), toolHeight/2);
        self.videoSlider.frame = self.videoProgress.frame;
        self.totalTimeLabel.frame = CGRectMake(CGRectGetMaxX(self.videoSlider.frame), 0, buttonWidth, toolHeight);
    }
    else
    {
        self.fullStatus = NO;
        self.toolView.hidden = !self.fullStatus;
    }
    
//    [self setCustomViewHidden:self.fullStatus];
    self.playerView.frame = self.bounds;
}

#pragma mark - view rotate
- (NSUInteger)supportedInterfaceOrientations
{
    if (isLoaded) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark - update UI
- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
    
    __weak typeof(self) weakSelf = self;
    self.playbackTimeObserver = [self.playerView.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        [weakSelf updateTimeLabel];
    }];
}

-(void)updateTimeLabel
{
    CGFloat currentSecond = self.playerItem.currentTime.value/self.playerItem.currentTime.timescale;// 计算当前在第几秒
    [self updateVideoSlider:currentSecond];
    NSString *timeString = [self convertTime:currentSecond];
    self.timeLabel.text = timeString;//[NSString stringWithFormat:@"%@/%@",timeString,_totalTime];
}

#pragma mark - KVO方法
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            self.stateButton.enabled = YES;
            CMTime duration = self.playerItem.duration;// 获取视频总长度
            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;// 转换成秒
            _totalTime = [self convertTime:totalSecond];// 转换成播放时间
            self.totalTimeLabel.text = _totalTime;
            
            [self customVideoSlider:duration];// 自定义UISlider外观
            NSLog(@"movie total duration:%f",CMTimeGetSeconds(duration));
            [self monitoringPlayback:self.playerItem];// 监听播放状态
            [self updateTimeLabel];
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        NSLog(@"Time Interval:%f",timeInterval);
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.videoProgress setProgress:timeInterval / totalDuration animated:YES];
    }
}

#pragma mark - video actions
- (void)customVideoSlider:(CMTime)duration {
    self.videoSlider.maximumValue = CMTimeGetSeconds(duration);
    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.videoSlider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [self.videoSlider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
}

- (void)stateButtonTouched
{
    if (!_played) {
        [self.playerView.player play];
        [self.stateButton setImage:[UIImage imageNamed:@"icon_full_pause"] forState:UIControlStateNormal];
        
    } else {
        [self.playerView.player pause];
        [self.stateButton setImage:[UIImage imageNamed:@"icon_full_play"] forState:UIControlStateNormal];
        
    }
    _played = !_played;
}

- (void)videoSlierChangeValue:(id)sender {
    UISlider *slider = (UISlider *)sender;
    LOG(@"value change:%f",slider.value);
    
    if (slider.value == 0.000000) {
        [self.playerView.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
            [self.playerView.player play];
        }];
    }
}

- (void)videoSlierChangeValueEnd:(id)sender {
    UISlider *slider = (UISlider *)sender;
    LOG(@"value end:%f",slider.value);
    CMTime changedTime = CMTimeMakeWithSeconds(slider.value, 1);
    [self.playerView.player seekToTime:changedTime completionHandler:^(BOOL finished) {
        [self.playerView.player play];
        [self.stateButton setImage:[UIImage imageNamed:@"icon_full_pause"] forState:UIControlStateNormal];
        
    }];
}

- (void)updateVideoSlider:(CGFloat)currentSecond {
    [self.videoSlider setValue:currentSecond animated:YES];
}


- (void)moviePlayDidEnd:(NSNotification *)notification {
    LOG(@"Play end");
    [self.playerView.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        _played = NO;
        [self updateVideoSlider:0.0];
        [self.stateButton setImage:[UIImage imageNamed:@"icon_full_play"] forState:UIControlStateNormal];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stateButtonTouched];
        });
    }];
}

#pragma mark - tool methods
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.playerView.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (NSString *)convertTime:(CGFloat)second{
    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (second/3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showtimeNew = [formatter stringFromDate:d];
    return showtimeNew;
}

-(void)clickClose
{
    [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)clear
{
    [self.playerItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [self.playerView.player removeTimeObserver:self.playbackTimeObserver];
}

- (void)dealloc {
    [self clear];
}
@end
