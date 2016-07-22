//
//  AppDelegate.h
//  SIPSample
//
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <PortSIPLib/PortSIPSDK.h>

#import "LoginViewController.h"
#import "NumpadViewController.h"
#import "VideoViewController.h"
#import "IMViewController.h"
#import "SettingsViewController.h"
#import "Session.h"
#import "LineTableViewController.h"

#define shareAppDelegate      [AppDelegate sharedInstance]

@interface AppDelegate : UIResponder <UIApplicationDelegate,PortSIPEventDelegate,UIAlertViewDelegate,LineViewControllerDelegate>
{
    PortSIPSDK* portSIPSDK;
    LoginViewController* loginViewController;
    NumpadViewController* numpadViewController;
    VideoViewController* videoViewController;
    IMViewController* imViewController;
    SettingsViewController* settingsViewController;
    
    Session*     sessionArray[MAX_LINES];
    BOOL        sipRegistered;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSString *sipURL;
@property (nonatomic, assign) NSInteger activeLine;
@property (nonatomic, assign) BOOL isConference;

- (void) pressNumpadButton:(char )dtmf;
- (void) makeCall:(NSString*) callee
   videoCall:(BOOL)videoCall;
- (void) hungUpCall;
- (void) holdCall;
- (void) unholdCall;
- (void) referCall:(NSString*)referTo;
- (void) muteCall:(BOOL)mute;
- (void) setLoudspeakerStatus:(BOOL)enable;
- (void) switchSessionLine;


- (BOOL)createConference:(PortSIPVideoRenderView *)conferenceVideoWindow;
- (void)removeFromConference:(long)sessionId;
- (BOOL)joinToConference:(long)sessionId;
- (void)destoryConference:(UIView *)viewRemoteVideo;
@end
