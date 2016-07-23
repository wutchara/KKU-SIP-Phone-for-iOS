//
//  VideoViewController.m
//  SIPSample
//
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "VideoViewController.h"
#import "AppDelegate.h"

@interface VideoViewController (){
    NSUInteger mCameraDeviceId;//1 - FrontCamra 0 - BackCamra
    int  mLocalVideoWidth;
    int  mLocalVideoHeight;
    int  mRemoteVideoWidth;
    int  mRemoteVideoHeight;
}
@property (weak, nonatomic) IBOutlet UIButton *buttonConference;


- (void)checkDisplayVideo;
@end

@implementation VideoViewController

- (void)checkDisplayVideo
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (isInitVideo && !appDelegate.isConference) {
        if(isStartVideo)
        {
        	[portSIPSDK setRemoteVideoWindow:sessionId remoteVideoWindow:nil];
            [portSIPSDK setRemoteVideoWindow:sessionId remoteVideoWindow:_viewRemoteVideo];
            [portSIPSDK setLocalVideoWindow:_viewLocalVideo];
            [portSIPSDK displayLocalVideo:YES];
            [portSIPSDK sendVideo:sessionId sendState:YES];
            startVideoOrientation = [UIApplication sharedApplication].statusBarOrientation;
        }
        else
        {
            [portSIPSDK displayLocalVideo:NO];
            [portSIPSDK setLocalVideoWindow:nil];
            [portSIPSDK setRemoteVideoWindow:sessionId remoteVideoWindow:nil];
            [portSIPSDK setVideoOrientation:0];
        }
        
    }

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    isInitVideo = YES;
    //1 - FrontCamra 0 - BackCamra
    mCameraDeviceId = 1;
    
    [_viewLocalVideo initVideoRender];
    [_viewRemoteVideo initVideoRender];
    
    mLocalVideoWidth  =0;
    mLocalVideoHeight = 0;
    
    mRemoteVideoWidth = 0;
    mRemoteVideoHeight = 0;
}

- (void)viewDidAppear:(BOOL)animated;
{
    [self checkDisplayVideo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//>=iOS6
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

-(int)getVideoOrotation
{
    int startVideoOrientationVal = 0;
    switch (startVideoOrientation) {
        case UIInterfaceOrientationPortrait:
            startVideoOrientationVal = 0;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            startVideoOrientationVal = 180;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            startVideoOrientationVal = 90;
            break;
        case UIInterfaceOrientationLandscapeRight:
            startVideoOrientationVal = 270;
            break;
        default:
            break;
    }
    
    int currentOrientationVal = 0;
    switch ([UIApplication sharedApplication].statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
            currentOrientationVal = 0;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            currentOrientationVal = 180;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            currentOrientationVal = 90;
            break;
        case UIInterfaceOrientationLandscapeRight:
            currentOrientationVal = 270;
            break;
        default:
            break;
    }
    
    if (mCameraDeviceId == 0) {
        return (-startVideoOrientationVal + 360 + currentOrientationVal)%360;
    }
    
    return (startVideoOrientationVal + 360 - currentOrientationVal)%360;
}



- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait||
       [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        //reset video view size
        CGRect rectLocal = _viewRemoteVideo.frame;
        rectLocal.origin.x = 169;
        rectLocal.origin.y = 31;
        rectLocal.size.width = 135;
        rectLocal.size.height = 110;
        _viewLocalVideo.frame = rectLocal;
        
        rectLocal = [_viewLocalVideo bounds];
        [_viewLocalVideo updateVideoRenderFrame:rectLocal];
        
        CGRect rect = _viewRemoteVideo.frame;
        rect.origin.x = 33;
        rect.origin.y = 289;
        rect.size.width = 254;
        rect.size.height = 208;
        _viewRemoteVideo.frame = rect;
        
        rect = [_viewRemoteVideo bounds];
        [_viewRemoteVideo updateVideoRenderFrame:rect];
    }
    else
    {
        CGRect rectLocal = _viewRemoteVideo.frame;
        rectLocal.origin.x = 10;
        rectLocal.origin.y = 160;
        rectLocal.size.width = 135;
        rectLocal.size.height = 110;
        _viewLocalVideo.frame = rectLocal;
        
        rectLocal = [_viewLocalVideo bounds];
        [_viewLocalVideo updateVideoRenderFrame:rectLocal];
        
        CGRect rect = _viewRemoteVideo.frame;
        rect.origin.x = 200;
        rect.origin.y = 5;
        rect.size.width = 320;
        rect.size.height = 262;
        _viewRemoteVideo.frame = rect;
        
        rect = [_viewRemoteVideo bounds];
        [_viewRemoteVideo updateVideoRenderFrame:rect];
    }
    
    if(isStartVideo)
    {
        [portSIPSDK setVideoOrientation:[self getVideoOrotation]];
    }
}

- (BOOL) shouldAutorotate {
    
    return YES;
}

- (IBAction) onSwitchSpeakerClick: (id)sender
{

    UIButton* buttonSpeaker = (UIButton*)sender;
    
    if([[[buttonSpeaker titleLabel] text] isEqualToString:@"Speaker"])
    {
        [portSIPSDK setLoudspeakerStatus:YES];
        [buttonSpeaker setTitle:@"Headphone" forState: UIControlStateNormal];
    }
    else
    {
        [portSIPSDK setLoudspeakerStatus:NO];
        [buttonSpeaker setTitle:@"Speaker" forState: UIControlStateNormal];
    }
}

- (IBAction) onSwitchCameraClick: (id)sender
{
    UIButton* buttonCamera = (UIButton*)sender;
    if([[[buttonCamera titleLabel] text] isEqualToString:@"FrontCamera"])
    {
        if([portSIPSDK setVideoDeviceId:1] == 0)
        {
            mCameraDeviceId = 1;
            [buttonCamera setTitle:@"BackCamera" forState: UIControlStateNormal];
        }

    }
    else
    {
        if([portSIPSDK setVideoDeviceId:0] == 0)
        {
            mCameraDeviceId = 0;
            [buttonCamera setTitle:@"FrontCamera" forState: UIControlStateNormal];
        }
    }

    startVideoOrientation = [UIApplication sharedApplication].statusBarOrientation;
    [portSIPSDK setVideoOrientation:0];
}

- (IBAction) onSendingVideoClick: (id)sender
{
    UIButton* buttonSendingVideo = (UIButton*)sender;
    
    if([[[buttonSendingVideo titleLabel] text] isEqualToString:@"PauseSending"])
    {
        [portSIPSDK sendVideo:sessionId sendState:NO];

        [buttonSendingVideo setTitle:@"StartSending" forState: UIControlStateNormal];
    }
    else
    {
        [portSIPSDK sendVideo:sessionId sendState:YES];
        [buttonSendingVideo setTitle:@"PauseSending" forState: UIControlStateNormal];
    }
}
- (IBAction)onConference:(id)sender {
    UIButton* buttonConference = (UIButton*)sender;
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if([[[buttonConference titleLabel] text] isEqualToString:@"Conference"])
    {
        [appDelegate createConference:_viewRemoteVideo];
        
        [buttonConference setTitle:@"UnConference" forState: UIControlStateNormal];
    }
    else
    {
        [appDelegate destoryConference:_viewRemoteVideo];

        [portSIPSDK setRemoteVideoWindow:sessionId remoteVideoWindow:_viewRemoteVideo];
        
        [buttonConference setTitle:@"Conference" forState: UIControlStateNormal];
    }
}

- (void)onStartVideo:(long)sessionID
{
    isStartVideo = YES;
    sessionId = sessionID;
    [self checkDisplayVideo];

}

- (void)onStopVideo:(long)sessionId
{
    isStartVideo = NO;
    [self checkDisplayVideo];
}

- (void)updateLocalVideoWindowsSize:(int)width height:(int)height
{
    if(height <= 0 || width <= 0)
        return;
    
    if(mLocalVideoHeight != height || mLocalVideoWidth != width){
        //MUST run in dispatch_get_main_queue,
        dispatch_async(dispatch_get_main_queue(), ^{
            //here view do layout new frame
            CGRect rect = _viewLocalVideo.frame;
            mLocalVideoWidth  = width;
            mLocalVideoHeight = height;
            
            rect.size.height = rect.size.width * height/width;
            
            _viewLocalVideo.frame = rect;
            
            rect = [_viewLocalVideo bounds];
            [_viewLocalVideo updateVideoRenderFrame:rect];
            
        });
        NSLog(@"updateLocalVideoWindowsSize sessionid = %zd width=%d height=%d", sessionId, width, height);
    }
}

- (void)updateRemoteVideoWindowsSize:(int)width height:(int)height
{
    if(height <= 0 || width <= 0)
        return;
    
    if(mRemoteVideoHeight != height || mRemoteVideoWidth != width){
        //MUST run in dispatch_get_main_queue,
        dispatch_async(dispatch_get_main_queue(), ^{
            //here view do layout new frame
            CGRect rect = _viewRemoteVideo.frame;
            mRemoteVideoWidth  = width;
            mRemoteVideoHeight = height;
            
            rect.size.height = rect.size.width * height/width;
            
            _viewRemoteVideo.frame = rect;
            
            rect = [_viewRemoteVideo bounds];
            [_viewRemoteVideo updateVideoRenderFrame:rect];
            
        });
        NSLog(@"updateRemoteVideoWindowsSize sessionid = %zd width=%d height=%d", sessionId, width, height);
    }
}

- (void)onVideoDecoderCallback:(long)sessionID
                         width:(int)width
                        height:(int)height
                     framerate:(int)framerate
                       bitrate:(int)bitrate
{
    if(sessionId != sessionID)
        return;
    [self updateRemoteVideoWindowsSize:width height:height];
}

- (void)willResignActive
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (isInitVideo ) {
        if(appDelegate.isConference)
        {
            [portSIPSDK setConferenceVideoWindow:nil];
        }
        else
        {
            if(isStartVideo){
                [portSIPSDK displayLocalVideo:NO];
                [portSIPSDK setLocalVideoWindow:nil];
                [portSIPSDK setRemoteVideoWindow:sessionId remoteVideoWindow:nil];
            }
        }
    }
}

- (void)didBecomeActive
{
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (isInitVideo ) {
        if(appDelegate.isConference)
        {
            [portSIPSDK setConferenceVideoWindow:_viewRemoteVideo];
        }
        else
        {
            if(isStartVideo){
                [portSIPSDK setRemoteVideoWindow:sessionId remoteVideoWindow:_viewRemoteVideo];
                [portSIPSDK setLocalVideoWindow:_viewLocalVideo];
                [portSIPSDK displayLocalVideo:YES];
                startVideoOrientation = [UIApplication sharedApplication].statusBarOrientation;
            }
        }
    }
}

@end
