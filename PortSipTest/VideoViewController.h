//
//  VideoViewController.h
//  SIPSample
//
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PortSIPLib/PortSIPSDK.h>

@interface VideoViewController : UIViewController{
@public
    PortSIPSDK *portSIPSDK;
    
@protected
    BOOL    isStartVideo;
    BOOL    isInitVideo;
    long    sessionId;
    UIInterfaceOrientation startVideoOrientation;
}


@property (retain, nonatomic) IBOutlet PortSIPVideoRenderView* viewLocalVideo;
@property (retain, nonatomic) IBOutlet PortSIPVideoRenderView *viewRemoteVideo;

- (void)onStartVideo:(long)sessionId;
- (void)onStopVideo:(long)sessionId;
- (void)onVideoDecoderCallback:(long)sessionID
                         width:(int)width
                        height:(int)height
                     framerate:(int)framerate
                       bitrate:(int)bitrate;

- (void)willResignActive;
- (void)didBecomeActive;

@end
