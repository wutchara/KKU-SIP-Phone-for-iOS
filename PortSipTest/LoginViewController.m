//
//  FirstViewController.m
//  SIPSample
//

//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "LoginViewController.h"
#include "AppDelegate.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
    
@implementation LoginViewController
@synthesize sipRegistered;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _textUsername.delegate = self;
    _textPassword.delegate = self;
    _textUserDomain.delegate = self;
    _textSIPserver.delegate = self;
    _textSIPPort.delegate = self;
    _textAuthname.delegate = self;
    
    sipInitialized = NO;
    sipRegistered  = NO;
    [_labelDebugInfo setText:@"PortSIP VoIP SDK for iOS"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)keyboardWillShow:(NSNotification *)noti
{
    float height = 216.0;
    CGRect frame = self.view.frame;    
    frame.size = CGSizeMake(frame.size.width, frame.size.height - height);    
    [UIView beginAnimations:@"Curl" context:nil];    
    [UIView setAnimationDuration:0.30];    
    [UIView setAnimationDelegate:self];    
    [self.view setFrame:frame];    
    [UIView commitAnimations];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // When the user presses return, take focus away from the text field so that the keyboard is dismissed.
    NSTimeInterval animationDuration = 0.30f;    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];    
    [UIView setAnimationDuration:animationDuration];    
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);    
    self.view.frame = rect;    
    [UIView commitAnimations];    
    [textField resignFirstResponder];    
    return YES;    
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;    
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);    
    NSTimeInterval animationDuration = 0.30f;    
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];    
    [UIView setAnimationDuration:animationDuration];
    
    float width = self.view.frame.size.width;    
    float height = self.view.frame.size.height;
    
    if(offset > 0)        
    {    
        CGRect rect = CGRectMake(0.0f, -offset,width,height);        
        self.view.frame = rect;               
    }           
    [UIView commitAnimations];               
}

- (void) onLine
{
    if(sipInitialized)
    {
        [_labelDebugInfo setText:@"You already registered, Offline first!"];
        return;
    }
    
    NSString* kUserName = _textUsername.text;
    NSString* kDisplayName = _textUsername.text;
    NSString* kAuthName = _textAuthname.text;
    NSString* kPassword = _textPassword.text;
    NSString* kUserDomain = _textUserDomain.text;
    NSString* kSIPServer = _textSIPserver.text;
    int kSIPServerPort = [_textSIPPort.text intValue];
    
    if([kUserName length] < 1)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Information"
                                                       message: @"Please enter user name!"
                                                      delegate: self
                                             cancelButtonTitle: @"OK"
                                             otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    if([kPassword length] < 1)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Information"
                                                       message: @"Please enter password"
                                                      delegate: self
                                             cancelButtonTitle: @"OK"
                                             otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    if([kSIPServer length] < 1)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle: @"Information"
                                                       message: @"Please enter SIP Server!"
                                                      delegate: self
                                             cancelButtonTitle: @"OK"
                                             otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    TRANSPORT_TYPE transport = TRANSPORT_UDP;//TRANSPORT_TCP
    //When you need background, TCP and TLS SIP transport is save battery, UDP takes more battery
    
    int ret = [portSIPSDK initialize:transport loglevel:PORTSIP_LOG_NONE logPath:@"" maxLine:8 agent:@"PortSIP SDK for IOS" audioDeviceLayer:0 videoDeviceLayer:0];
    
    if(ret != 0)
    {
        NSLog(@"initialize failure ErrorCode = %d",ret);
        return ;
    }
    
    int localPort = 10000 + arc4random()%1000;
    NSString* loaclIPaddress = @"0.0.0.0";//Auto select IP address
    if(transport == TRANSPORT_TCP ||
       transport == TRANSPORT_TLS){
        //TCP must use the specified IP
        int nicNumber = [portSIPSDK getNICNums];
        for(int i = 0 ; i < nicNumber; i++){
            NSLog(@"loaclIP %d = %@",i,[portSIPSDK getLocalIpAddress:i]);
        }
        
        loaclIPaddress = [portSIPSDK getLocalIpAddress:0];
    }
    
    ret = [portSIPSDK setUser:kUserName displayName:kDisplayName authName:kAuthName password:kPassword localIP:loaclIPaddress localSIPPort:localPort userDomain:kUserDomain SIPServer:kSIPServer SIPServerPort:kSIPServerPort STUNServer:@"" STUNServerPort:0 outboundServer:@"" outboundServerPort:0];
    if(ret != 0){
        NSLog(@"setUser failure ErrorCode = %d",ret);
        return ;
    }
    
    int rt = [portSIPSDK setLicenseKey:@"PORTSIP_TEST_LICENSE"];
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    if (state == UIApplicationStateBackground) {
        NSLog(@"setLicenseKey %d", rt);
    }else{
        if (rt == ECoreTrialVersionLicenseKey)
        {
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Warning"
                                  message: @"This trial version SDK just allows short conversation, you can't heairng anyting after 2-3 minutes, contact us: sales@portsip.com to buy official version."
                                  delegate: self
                                  cancelButtonTitle: @"OK"
                                  otherButtonTitles:nil];
            [alert show];
        }
        else if (rt == ECoreWrongLicenseKey)
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message: @"The wrong license key was detected, please check with sales@portsip.com or support@portsip.com"
                                  delegate: self
                                  cancelButtonTitle: @"OK"
                                  otherButtonTitles:nil];
            [alert show];
            NSLog(@"setLicenseKey failure ErrorCode = %d",rt);
            return ;
        }
        else if (rt == ECoreTrialVersionExpired)
        {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message: @"This trial version SDK has expired, please download new version at http://www.portsip.com/downloads.html."
                                  delegate: self
                                  cancelButtonTitle: @"OK"
                                  otherButtonTitles:nil];
            [alert show];
            NSLog(@"setLicenseKey failure ErrorCode = %d",rt);
            return ;
        }
    }
    
    
    [portSIPSDK addAudioCodec:AUDIOCODEC_PCMA];
    [portSIPSDK addAudioCodec:AUDIOCODEC_PCMU];
    [portSIPSDK addAudioCodec:AUDIOCODEC_SPEEX];
    [portSIPSDK addAudioCodec:AUDIOCODEC_G729];
    
    //[mPortSIPSDK addAudioCodec:AUDIOCODEC_GSM];
    //[mPortSIPSDK addAudioCodec:AUDIOCODEC_ILBC];
    //[mPortSIPSDK addAudioCodec:AUDIOCODEC_AMR];
    //[mPortSIPSDK addAudioCodec:AUDIOCODEC_SPEEXWB];
    
    //[mPortSIPSDK addVideoCodec:VIDEO_CODEC_H263];
    //[mPortSIPSDK addVideoCodec:VIDEO_CODEC_H263_1998];
    [portSIPSDK addVideoCodec:VIDEO_CODEC_H264];
    
    [portSIPSDK setVideoBitrate:300];//video send bitrate,300kbps
    [portSIPSDK setVideoFrameRate:10];
    [portSIPSDK setVideoResolution:352 height:288];
    [portSIPSDK setAudioSamples:20 maxPtime:60];//ptime 20
    
    //1 - FrontCamra 0 - BackCamra
    [portSIPSDK setVideoDeviceId:1];
    
    //enable video RTCP nack
    [portSIPSDK setVideoNackStatus:YES];
    
    //enable video decoder callback
    [portSIPSDK enableVideoDecoderCallback:YES];
    //enable srtp
    //[mPortSIPSDK setSrtpPolicy:SRTP_POLICY_FORCE];
    
    // Try to register the default identity
    ret = [portSIPSDK registerServer:90 retryTimes:0];
    if(ret != 0){
        [portSIPSDK unInitialize];
        NSLog(@"registerServer failure ErrorCode = %d",ret);
        return ;
    }
    
    if(transport == TRANSPORT_TCP ||
       transport == TRANSPORT_TLS){
        [portSIPSDK setKeepAliveTime:0];
    }
    
    [_activityIndicator startAnimating];
    
    [_labelDebugInfo setText:@"Registration..."];
    NSString* sipURL = nil;
    if(kSIPServerPort == 5060)
        sipURL = [[NSString alloc] initWithFormat:@"sip:%@:%@",kUserName,kUserDomain];
    else
        sipURL = [[NSString alloc] initWithFormat:@"sip:%@:%@:%d",kUserName,kUserDomain,kSIPServerPort];
    AppDelegate* appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    appDelegate.sipURL = sipURL;
    
    sipInitialized = YES;
}

- (void) offLine
{
    if(sipInitialized)
    {
        [portSIPSDK unRegisterServer];
        [portSIPSDK unInitialize];
        [_viewStatus setBackgroundColor:[UIColor redColor]];
        
        [_labelStatus setText:@"Not Connected"];
        [_labelDebugInfo setText:[NSString stringWithFormat: @"unRegisterServer"]];
        

        sipInitialized = NO;
    }
    if([_activityIndicator isAnimating])
        [_activityIndicator stopAnimating];
 
}

- (IBAction) onOnlineButtonClick: (id)sender
{
    [self onLine];
};

- (IBAction) onOfflineButtonClick: (id)sender
{
    [self offLine];
    sipRegistered = NO;
};

- (void)autoReRegisterTimer{
    //refreshRegisterServer just use for NetworkStatus not change case
    [portSIPSDK refreshRegisterServer:0];
    NSLog(@"process autoRegisterTimer");
}

- (int)onRegisterSuccess:(int)statusCode withStatusText:(char*) statusText
{
    [_viewStatus setBackgroundColor:[UIColor greenColor]];
    
    [_labelStatus setText:@"Connected"];
    
    [_labelDebugInfo setText:[NSString stringWithFormat: @"onRegisterSuccess: %s", statusText]];
    
    [_activityIndicator stopAnimating];
    
    sipRegistered = YES;
    return 0;
}


- (int)onRegisterFailure:(int)statusCode withStatusText:(char*) statusText
{
    [_viewStatus setBackgroundColor:[UIColor redColor]];
    
    [_labelStatus setText:@"Not Connected"];
    
    [_labelDebugInfo setText:[NSString stringWithFormat: @"onRegisterFailure: %s", statusText]];
    
    [_activityIndicator stopAnimating];
    
    if (sipRegistered) {
        //If the NetworkStatus not change, received onRegisterFailure event. can added a atuo reRegister Timer like this:
        autoRegisterTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(autoReRegisterTimer) userInfo:nil repeats:NO];
    }
    return 0;
};
@end
