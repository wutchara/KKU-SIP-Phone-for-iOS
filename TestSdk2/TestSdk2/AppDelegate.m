//
//  AppDelegate.m
//  SIPSample
//
//  Copyright (c) 2013 PortSIP Solutions, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "SoundService.h"
#import "Reachability.h"

@interface AppDelegate ()
{
    SoundService* _mSoundService;
    Reachability* internetReach;
}
- (int)findSession:(long)sessionId;
@end

@implementation AppDelegate

- (int)findSession:(long)sessionId
{
	int index = -1;
	for (int i=LINE_BASE; i<MAX_LINES; ++i)
	{
		if (sessionId == sessionArray[i].sessionId)
		{
			index = i;
			break;
		}
	}
    
	return index;
}

- (void) pressNumpadButton:(char )dtmf
{
    if(sessionArray[_activeLine].sessionState)
    {
        [portSIPSDK sendDtmf:sessionArray[_activeLine].sessionId dtmfMethod:DTMF_RFC2833 code:dtmf dtmfDration:160 playDtmfTone:YES];
    }
}

- (void) makeCall:(NSString*) callee
        videoCall:(BOOL)videoCall
{
    if(sessionArray[_activeLine].sessionState ||
       sessionArray[_activeLine].recvCallState)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Warning"
                              message: @"Current line is busy now, please switch a line"
                              delegate: nil
                              cancelButtonTitle: @"OK"
                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }

    
    long sessionId = [portSIPSDK call:callee sendSdp:YES videoCall:videoCall];
    
    if(sessionId >= 0)
    {
        sessionArray[_activeLine].sessionId = sessionId;
        sessionArray[_activeLine].sessionState = YES;
        sessionArray[_activeLine].videoState = videoCall;
        
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"Calling:%@ on line %zd", callee, _activeLine]];
    }
    else
    {
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"make call failure ErrorCode =%zd", sessionId]];
    }
}

- (void) hungUpCall
{
    
    if (_isConference) {
        [self removeFromConference:sessionArray[_activeLine].sessionId];
    }
    
    if (sessionArray[_activeLine].sessionState)
    {
        [portSIPSDK hangUp :sessionArray[_activeLine].sessionId];
        if (sessionArray[_activeLine].videoState) {
            [videoViewController onStopVideo:sessionArray[_activeLine].sessionId];
        }
        [sessionArray[_activeLine] reset];
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"Hungup call on line %zd", _activeLine]];

    }
    else if (sessionArray[_activeLine].recvCallState)
    {
        [portSIPSDK rejectCall:sessionArray[_activeLine].sessionId code:486];
        [sessionArray[_activeLine] reset];
        
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"Rejected call on line %zd", _activeLine]];
    }
    
    [_mSoundService stopRingTone];
    [_mSoundService stopRingBackTone];
    
    [self setLoudspeakerStatus:YES];
}

- (void) holdCall
{
    if (!sessionArray[_activeLine].sessionState ||
        sessionArray[_activeLine].holdState)
    {
        return;
    }
    
    [portSIPSDK hold:sessionArray[_activeLine].sessionId];
    sessionArray[_activeLine].holdState = YES;
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Hold the call on line %zd", (long)_activeLine]];
    
    if (_isConference) {
        [self holdAllCall];
    }
}

- (void) unholdCall
{
    if (!sessionArray[_activeLine].sessionState ||
        !sessionArray[_activeLine].holdState)
    {
        return;
    }
    
    [portSIPSDK unHold:sessionArray[_activeLine].sessionId];
    sessionArray[_activeLine].holdState = NO;
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"UnHold the call on line %zd", (long)_activeLine]];
    
    if (_isConference) {
        [self unholdAllCall];
    }
}

- (void) referCall:(NSString*)referTo
{
    if (!sessionArray[_activeLine].sessionState)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Warning"
                              message: @"Need to make the call established first"
                              delegate: nil
                              cancelButtonTitle: @"OK"
                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    int errorCodec = [portSIPSDK refer:sessionArray[_activeLine].sessionId referTo:referTo];
    if (errorCodec != 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Warning"
                              message: @"Refer failed"
                              delegate: nil
                              cancelButtonTitle: @"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void) muteCall:(BOOL)mute
{
    if(sessionArray[_activeLine].sessionState){
        if(mute)
        {
            [portSIPSDK muteSession:sessionArray[_activeLine].sessionId
                   muteIncomingAudio:YES
                   muteOutgoingAudio:YES
                   muteIncomingVideo:YES
                   muteOutgoingVideo:YES];
            if (_isConference) {
                [self muteAllCall];
            }
        }
        else
        {
            [portSIPSDK muteSession:sessionArray[_activeLine].sessionId
                   muteIncomingAudio:NO
                   muteOutgoingAudio:NO
                   muteIncomingVideo:NO
                   muteOutgoingVideo:NO];
            if (_isConference) {
                [self unMuteAllCall];
            }
        }
    }
}

- (void) setLoudspeakerStatus:(BOOL)enable
{
    [portSIPSDK setLoudspeakerStatus:enable];
}

- (void)didSelectLine:(NSInteger)activeLine
{
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;

    [tabBarController dismissViewControllerAnimated:YES completion:nil];
    
    if (!sipRegistered || _activeLine == activeLine)
	{
		return;
	}
    
	if (sessionArray[_activeLine].sessionState &&
        !sessionArray[_activeLine].holdState &&
        !_isConference)
	{
		// Need to hold this line
        [portSIPSDK hold:sessionArray[_activeLine].sessionId];
        [portSIPSDK setRemoteVideoWindow:sessionArray[_activeLine].sessionId remoteVideoWindow:nil];
        
		sessionArray[_activeLine].holdState = YES;
        
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"Hold call on line %zd", _activeLine]];
	}
    
    _activeLine = activeLine;
    [numpadViewController.buttonLine setTitle:[NSString  stringWithFormat:@"Line%zd:", _activeLine] forState:UIControlStateNormal];
    
	if (sessionArray[_activeLine].sessionState &&
        sessionArray[_activeLine].holdState &&
        !_isConference)
	{
		// Need to unhold this line
        [portSIPSDK unHold:sessionArray[_activeLine].sessionId];
        [portSIPSDK setRemoteVideoWindow:sessionArray[_activeLine].sessionId remoteVideoWindow:videoViewController.viewRemoteVideo];

		sessionArray[_activeLine].holdState = NO;
        
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"unHold call on line %zd", _activeLine]];
	}
    
}

- (void) switchSessionLine
{
    UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    LineTableViewController* selectLineView  = [stryBoard instantiateViewControllerWithIdentifier:@"LineTableViewController"];
    
    selectLineView.delegate = self;
    selectLineView.activeLine = _activeLine;
    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
    [tabBarController presentViewController:selectLineView animated:YES completion:nil];
}

//
//	sip callback events implementation
//
//Register Event
- (void)onRegisterSuccess:(char*) statusText statusCode:(int)statusCode

{
    sipRegistered = YES;
    [loginViewController onRegisterSuccess:statusCode withStatusText:statusText];
};

- (void)onRegisterFailure:(char*) statusText statusCode:(int)statusCode
{
    sipRegistered = NO;
    [loginViewController onRegisterFailure:statusCode withStatusText:statusText];
};


//Call Event
- (void)onInviteIncoming:(long)sessionId
       callerDisplayName:(char*)callerDisplayName
                  caller:(char*)caller
       calleeDisplayName:(char*)calleeDisplayName
                  callee:(char*)callee
             audioCodecs:(char*)audioCodecs
             videoCodecs:(char*)videoCodecs
             existsAudio:(BOOL)existsAudio
             existsVideo:(BOOL)existsVideo
{
    int index = -1;
	for (int i=0; i< MAX_LINES; ++i)
	{
		if (!sessionArray[i].sessionState &&
            !sessionArray[i].recvCallState)
		{
			sessionArray[i].recvCallState = YES;
			index = i;
			break;
		}
	}
    
	if (index == -1)
	{
        [portSIPSDK rejectCall:sessionId code:486];
		return ;
	}
    
	sessionArray[index].sessionId = sessionId;
    sessionArray[index].videoState = existsVideo;
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Incoming call:%s on line %d",caller, index]];
    
    [_mSoundService playRingTone];
    
    if ([UIApplication sharedApplication].applicationState ==  UIApplicationStateBackground) {
        UILocalNotification* localNotif = [[UILocalNotification alloc] init];
        if (localNotif){
            localNotif.alertBody =[NSString  stringWithFormat:@"Call from <%s>%s on line %d", callerDisplayName,caller,index];
            localNotif.soundName = UILocalNotificationDefaultSoundName;
            localNotif.applicationIconBadgeNumber = 1;
            // In iOS 8.0 and later, your application must register for user notifications using -[UIApplication registerUserNotificationSettings:] before being able to schedule and present UILocalNotifications
            [[UIApplication sharedApplication]  presentLocalNotificationNow:localNotif];
        }
    }
    
    if(existsVideo)
    {//video call
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Incoming Call"
                              message: [NSString  stringWithFormat:@"Call from <%s>%s on line %d", callerDisplayName,caller,index]
                              delegate: self
                              cancelButtonTitle: @"Reject"
                              otherButtonTitles:@"Answer", @"Video",nil];
        alert.tag = index;
        [alert show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Incoming Call"
                              message: [NSString  stringWithFormat:@"Call from <%s>%s on line %d", callerDisplayName,caller,index]
                              delegate: self
                              cancelButtonTitle: @"Reject"
                              otherButtonTitles:@"Answer", nil];
        alert.tag = index;
        [alert show];
    }
};

- (void)onInviteTrying:(long)sessionId
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}

    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Call is trying on line %d",index]];
};

- (void)onInviteSessionProgress:(long)sessionId
                    audioCodecs:(char*)audioCodecs
                    videoCodecs:(char*)videoCodecs
               existsEarlyMedia:(BOOL)existsEarlyMedia
                    existsAudio:(BOOL)existsAudio
                    existsVideo:(BOOL)existsVideo
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
	if (existsEarlyMedia)
	{
		// Checking does this call has video
		if (existsVideo)
		{
			// This incoming call has video
			// If more than one codecs using, then they are separated with "#",
			// for example: "g.729#GSM#AMR", "H264#H263", you have to parse them by yourself.
		}
        
		if (existsAudio)
		{
			// If more than one codecs using, then they are separated with "#",
			// for example: "g.729#GSM#AMR", "H264#H263", you have to parse them by yourself.
		}
	}
    
	sessionArray[index].existEarlyMedia = existsEarlyMedia;
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Call session progress on line %d",index]];
}

- (void)onInviteRinging:(long)sessionId
             statusText:(char*)statusText
             statusCode:(int)statusCode
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    if (!sessionArray[index].existEarlyMedia)
	{
		// No early media, you must play the local WAVE file for ringing tone
        [_mSoundService playRingBackTone];
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Call ringing on line %d",index]];
}

- (void)onInviteAnswered:(long)sessionId
       callerDisplayName:(char*)callerDisplayName
                  caller:(char*)caller
       calleeDisplayName:(char*)calleeDisplayName
                  callee:(char*)callee
             audioCodecs:(char*)audioCodecs
             videoCodecs:(char*)videoCodecs
             existsAudio:(BOOL)existsAudio
             existsVideo:(BOOL)existsVideo
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    // If more than one codecs using, then they are separated with "#",
	// for example: "g.729#GSM#AMR", "H264#H263", you have to parse them by yourself.
	// Checking does this call has video
	if (existsVideo)
	{
        [videoViewController onStartVideo:sessionId];
	}
    
	if (existsAudio)
	{
	}
    
	sessionArray[index].sessionState = YES;
    sessionArray[_activeLine].videoState = existsVideo;
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Call Established on line  %d",index]];
    
	// If this is the refer call then need set it to normal
	if (sessionArray[index].isReferCall)
	{
        
        sessionArray[index].isReferCall = NO;
        sessionArray[index].originCallSessionId = -1;
	}
    
    ///todo: joinConference(index);
    if (_isConference) {
        [self joinToConference:sessionId];
    }
    [_mSoundService stopRingBackTone];
}

- (void)onInviteFailure:(long)sessionId
                 reason:(char*)reason
                   code:(int)code
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}

    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Failed to call on line  %d,%s(%d)",index,reason,code]];
    
	if (sessionArray[index].isReferCall)
	{
		// Take off the origin call from HOLD if the refer call is failure
		long originIndex = -1;
		for (int i=LINE_BASE; i<MAX_LINES; ++i)
		{
			// Looking for the origin call
			if (sessionArray[i].sessionId == sessionArray[index].originCallSessionId)
			{
				originIndex = i;
				break;
			}
		}
        
		if (originIndex != -1)
		{
            [numpadViewController setStatusText:[NSString  stringWithFormat:@"Call failure on line  %d,%s(%d)",index,reason,code]];
            
			// Now take off the origin call
            [portSIPSDK unHold:sessionArray[index].originCallSessionId];

			sessionArray[originIndex].holdState = NO;
            
			// Switch the currently line to origin call line
			_activeLine = originIndex;
            
            NSLog(@"Current line is: %zd",_activeLine);
		}
	}
    
	[sessionArray[index] reset];
    
    [_mSoundService stopRingTone];
    [_mSoundService stopRingBackTone];
    [self setLoudspeakerStatus:YES];
    
}

- (void)onInviteUpdated:(long)sessionId
            audioCodecs:(char*)audioCodecs
            videoCodecs:(char*)videoCodecs
            existsAudio:(BOOL)existsAudio
            existsVideo:(BOOL)existsVideo
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
	// Checking does this call has video
	if (existsVideo)
	{
        [videoViewController onStartVideo:sessionId];
	}
	if (existsAudio)
	{
	}
    
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"The call has been updated on line %d",index]];
}

- (void)onInviteConnected:(long)sessionId
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"The call is connected on line %d",index]];
    if (sessionArray[index].videoState) {
        [self setLoudspeakerStatus:YES];
    }
    else{
        [self setLoudspeakerStatus:NO];
    }
    NSLog(@"onInviteConnected...");
}


- (void)onInviteBeginingForward:(char*)forwardTo
{
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Call has been forward to:%s" ,forwardTo]];
}

- (void)onInviteClosed:(long)sessionId
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Call closed by remote on line %d",index]];

    if (sessionArray[index].videoState) {
        [videoViewController onStopVideo:sessionId];
    }
    
    [sessionArray[index] reset];
    
    [_mSoundService stopRingTone];
    [_mSoundService stopRingBackTone];
    //Setting speakers for sound output (The system default behavior)
    [self setLoudspeakerStatus:YES];
    NSLog(@"onInviteClosed...");
}

- (void)onRemoteHold:(long)sessionId
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Placed on hold by remote on line %d",index]];
}

- (void)onRemoteUnHold:(long)sessionId
           audioCodecs:(char*)audioCodecs
           videoCodecs:(char*)videoCodecs
           existsAudio:(BOOL)existsAudio
           existsVideo:(BOOL)existsVideo
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Take off hold by remote on line  %d",index]];
}

//Transfer Event
- (void)onReceivedRefer:(long)sessionId
                referId:(long)referId
                     to:(char*)to
                   from:(char*)from
        referSipMessage:(char*)referSipMessage
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{//Not found the refer session, reject refer.
        [portSIPSDK rejectRefer:referId];
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Received the refer on line %d, refer to %s",index,to]];

    //auto accept refer
    long referSessionId = [portSIPSDK acceptRefer:referId referSignaling:[NSString stringWithUTF8String:referSipMessage]];
    if (referSessionId <= 0)
    {
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"Failed to accept the refer."]];
    }
    else
    {
        [portSIPSDK hangUp:sessionArray[index].sessionId];
        [sessionArray[index] reset];
        
        sessionArray[index].sessionId = referSessionId;
        sessionArray[index].sessionState = YES;
        sessionArray[index].isReferCall = YES;
        sessionArray[index].originCallSessionId = sessionArray[index].sessionId;
        
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"Accepted the refer, new call is trying on line %d",index]];
    }
    

    /*if you want to reject Refer
     [mPortSIPSDK rejectRefer:referId];
     [numpadViewController setStatusText:@"Rejected the the refer."];
     */
}

- (void)onReferAccepted:(long)sessionId
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Line %d, the REFER was accepted.",index]];
}

- (void)onReferRejected:(long)sessionId reason:(char*)reason code:(int)code
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Line %d, the REFER was rejected.",index]];
}

- (void)onTransferTrying:(long)sessionId
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Transfer trying on line %d",index]];
}

- (void)onTransferRinging:(long)sessionId
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Transfer ringing on line %d",index]];
}

- (void)onACTVTransferSuccess:(long)sessionId
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Transfer succeeded on line %d",index]];
    
    //Transfer has success, hangup call.
    [portSIPSDK hangUp:sessionId];
}

- (void)onACTVTransferFailure:(long)sessionId reason:(char*)reason code:(int)code
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Failed to transfer on line %d",index]];
}

//Signaling Event
- (void)onReceivedSignaling:(long)sessionId message:(char*)message
{
    // This event will be fired when the SDK received a SIP message
    // you can use signaling to access the SIP message.
}

- (void)onSendingSignaling:(long)sessionId message:(char*)message
{
    // This event will be fired when the SDK sent a SIP message
    // you can use signaling to access the SIP message.
}

- (void)onWaitingVoiceMessage:(char*)messageAccount
        urgentNewMessageCount:(int)urgentNewMessageCount
        urgentOldMessageCount:(int)urgentOldMessageCount
              newMessageCount:(int)newMessageCount
              oldMessageCount:(int)oldMessageCount
{
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Has voice messages,%s(%d,%d,%d,%d)",messageAccount,urgentNewMessageCount,urgentOldMessageCount,newMessageCount,oldMessageCount]];
}

- (void)onWaitingFaxMessage:(char*)messageAccount
      urgentNewMessageCount:(int)urgentNewMessageCount
      urgentOldMessageCount:(int)urgentOldMessageCount
            newMessageCount:(int)newMessageCount
            oldMessageCount:(int)oldMessageCount
{
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Has Fax messages,%s(%d,%d,%d,%d)",messageAccount,urgentNewMessageCount,urgentOldMessageCount,newMessageCount,oldMessageCount]];
}

- (void)onRecvDtmfTone:(long)sessionId tone:(int)tone
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Received DTMF tone: %d  on line %d",tone, index]];
}

- (void)onRecvOptions:(char*)optionsMessage
{
    NSLog(@"Received an OPTIONS message:%s",optionsMessage);
}

- (void)onRecvInfo:(char*)infoMessage
{
    NSLog(@"Received an INFO message:%s",infoMessage);
}

//Instant Message/Presence Event
- (void)onPresenceRecvSubscribe:(long)subscribeId
                fromDisplayName:(char*)fromDisplayName
                           from:(char*)from
                        subject:(char*)subject
{
    [imViewController onPresenceRecvSubscribe:subscribeId fromDisplayName:fromDisplayName from:from subject:subject];
}

- (void)onPresenceOnline:(char*)fromDisplayName
                    from:(char*)from
               stateText:(char*)stateText
{
    [imViewController onPresenceOnline:fromDisplayName from:from
                             stateText:stateText];
}


- (void)onPresenceOffline:(char*)fromDisplayName from:(char*)from
{
    [imViewController onPresenceOffline:fromDisplayName from:from];
}


- (void)onRecvMessage:(long)sessionId
             mimeType:(char*)mimeType
          subMimeType:(char*)subMimeType
          messageData:(unsigned char*)messageData
    messageDataLength:(int)messageDataLength
{
    int index = [self findSession:sessionId];
	if (index == -1)
	{
		return;
	}
    
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Received a MESSAGE message on line %d",index]];

    
    if (strcmp(mimeType,"text") == 0 && strcmp(subMimeType,"plain") == 0)
    {
        NSString* recvMessage = [NSString stringWithUTF8String:(const char*)messageData];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"recvMessage"
                              message: recvMessage
                              delegate: nil
                              cancelButtonTitle: @"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    else if (strcmp(mimeType,"application") == 0 && strcmp(subMimeType,"vnd.3gpp.sms") == 0)
    {
        // The messageData is binary data
    }
    else if (strcmp(mimeType,"application") == 0 && strcmp(subMimeType,"vnd.3gpp2.sms") == 0)
    {
        // The messageData is binary data
    }
}

- (void)onRecvOutOfDialogMessage:(char*)fromDisplayName
                            from:(char*)from
                   toDisplayName:(char*)toDisplayName
                              to:(char*)to
                        mimeType:(char*)mimeType
                     subMimeType:(char*)subMimeType
                     messageData:(unsigned char*)messageData
               messageDataLength:(int)messageDataLength
{
    [numpadViewController setStatusText:[NSString  stringWithFormat:@"Received a message(out of dialog) from %s",from]];
    
    if (strcasecmp(mimeType,"text") == 0 && strcasecmp(subMimeType,"plain") == 0)
    {
        NSString* recvMessage = [NSString stringWithUTF8String:(const char*)messageData];
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[NSString  stringWithUTF8String:from]
                              message: recvMessage
                              delegate: nil
                              cancelButtonTitle: @"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    else if (strcasecmp(mimeType,"application") == 0 && strcasecmp(subMimeType,"vnd.3gpp.sms") == 0)
    {
        // The messageData is binary data
    }
    else if (strcasecmp(mimeType,"application") == 0 && strcasecmp(subMimeType,"vnd.3gpp2.sms") == 0)
    {
        // The messageData is binary data
    }
}

- (void)onSendMessageSuccess:(long)sessionId messageId:(long)messageId
{
    [imViewController onSendMessageSuccess:messageId];
}


- (void)onSendMessageFailure:(long)sessionId messageId:(long)messageId reason:(char*)reason code:(int)code
{
    [imViewController onSendMessageFailure:messageId reason:reason code:code];
}

- (void)onSendOutOfDialogMessageSuccess:(long)messageId
                        fromDisplayName:(char*)fromDisplayName
                                   from:(char*)from
                          toDisplayName:(char*)toDisplayName
                                     to:(char*)to
{
    [imViewController onSendMessageSuccess:messageId];
}


- (void)onSendOutOfDialogMessageFailure:(long)messageId
                        fromDisplayName:(char*)fromDisplayName
                                   from:(char*)from
                          toDisplayName:(char*)toDisplayName
                                     to:(char*)to
                                 reason:(char*)reason
                                   code:(int)code
{
    [imViewController onSendMessageFailure:messageId reason:reason code:code];
}

//Play file event
- (void)onPlayAudioFileFinished:(long)sessionId fileName:(char*)fileName
{
    
}

- (void)onPlayVideoFileFinished:(long)sessionId
{
    
}

//RTP/Audio/video stream callback data
- (void)onReceivedRTPPacket:(long)sessionId isAudio:(BOOL)isAudio RTPPacket:(unsigned char *)RTPPacket packetSize:(int)packetSize
{
    /* !!! IMPORTANT !!!
     
     Don't call any PortSIP SDK API functions in here directly. If you want to call the PortSIP API functions or
     other code which will spend long time, you should post a message to main thread(main window) or other thread,
     let the thread to call SDK API functions or other code.
     */
}

- (void)onSendingRTPPacket:(long)sessionId isAudio:(BOOL)isAudio RTPPacket:(unsigned char *)RTPPacket packetSize:(int)packetSize
{
    /* !!! IMPORTANT !!!
     
     Don't call any PortSIP SDK API functions in here directly. If you want to call the PortSIP API functions or
     other code which will spend long time, you should post a message to main thread(main window) or other thread,
     let the thread to call SDK API functions or other code.
     */
}

- (void)onAudioRawCallback:(long)sessionId
         audioCallbackMode:(int)audioCallbackMode
                      data:(unsigned char *)data
                dataLength:(int)dataLength
            samplingFreqHz:(int)samplingFreqHz
{
    /* !!! IMPORTANT !!!
     
     Don't call any PortSIP SDK API functions in here directly. If you want to call the PortSIP API functions or
     other code which will spend long time, you should post a message to main thread(main window) or other thread,
     let the thread to call SDK API functions or other code.
     */
}

- (void)onVideoRawCallback:(long)sessionId
         videoCallbackMode:(int)videoCallbackMode
                     width:(int)width
                    height:(int)height
                      data:(unsigned char *)data
                dataLength:(int)dataLength
{
    /* !!! IMPORTANT !!!
     
     Don't call any PortSIP SDK API functions in here directly. If you want to call the PortSIP API functions or
     other code which will spend long time, you should post a message to main thread(main window) or other thread,
     let the thread to call SDK API functions or other code.
     */
}

- (void)onVideoDecoderCallback:(long)sessionId
                         width:(int)width
                        height:(int)height
                     framerate:(int)framerate
                       bitrate:(int)bitrate
{
    [videoViewController onVideoDecoderCallback:sessionId width:width height:height framerate:framerate bitrate:bitrate];
}

- (void)alertView: (UIAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    [_mSoundService stopRingTone];
    
    NSInteger index = alertView.tag;
    if(buttonIndex == 0){//reject Call
        [portSIPSDK rejectCall:sessionArray[index].sessionId code:486];
        
        [numpadViewController setStatusText:[NSString  stringWithFormat:@"Reject Call on line %zd",index]];
    }
    else if (buttonIndex == 1){//Answer Call
        int nRet = [portSIPSDK answerCall:sessionArray[index].sessionId videoCall:NO];
        if(nRet == 0)
        {
            sessionArray[index].sessionState = YES;
            sessionArray[index].videoState = NO;
            
            [numpadViewController setStatusText:[NSString  stringWithFormat:@"Answer Call on line %zd",index]];
            [self didSelectLine:index];
            
            if (_isConference) {
                [self joinToConference:sessionArray[index].sessionId];
            }
        }
        else
        {
            [sessionArray[index] reset];
            [numpadViewController setStatusText:[NSString  stringWithFormat:@"Answer Call on line %zd Failed",index]];
        }
    }
    else if (buttonIndex == 2){//Answer Video Call
        int nRet = [portSIPSDK answerCall:sessionArray[index].sessionId videoCall:YES];
        if(nRet == 0)
        {
            sessionArray[index].sessionState = YES;
            sessionArray[index].videoState = YES;
            [videoViewController onStartVideo:sessionArray[index].sessionId];
            
            [numpadViewController setStatusText:[NSString  stringWithFormat:@"Answer Call on line %zd",index]];
            [self didSelectLine:index];
            
            if (_isConference) {
                [self joinToConference:sessionArray[index].sessionId];
            }
        }
        else
        {
            [sessionArray[index] reset];
            [numpadViewController setStatusText:[NSString  stringWithFormat:@"Answer Call on line %zd Failed",index]];
        }
    }
    
}


- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    if(loginViewController.sipRegistered)
    {
        switch (netStatus) {
            case kNotReachable:
                NSLog(@"reachabilityChanged:kNotReachable");
                break;
            case kReachableViaWWAN:
                [loginViewController offLine];
                [loginViewController onLine];
                NSLog(@"reachabilityChanged:kReachableViaWWAN");
                break;
            case kReachableViaWiFi:
                [loginViewController offLine];
                [loginViewController onLine];
                NSLog(@"reachabilityChanged:kReachableViaWiFi");
                break;
            default:
                break;
        }
    }
}

- (void)startNotifierNetwork
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
    
    [internetReach startNotifier];
}

- (void)stopNotifierNetwork
{
    [internetReach stopNotifier];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    _mSoundService = [[SoundService alloc] init];
    
    portSIPSDK = [[PortSIPSDK alloc] init];
    portSIPSDK.delegate = self;

    for (int i = LINE_BASE; i < MAX_LINES; ++i) {
        sessionArray[i] = [[Session alloc] init];
    }
    
    _activeLine = 0;
    sipRegistered = NO;
    
    _isConference = NO;
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
            
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        }
    }
        

    
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
	loginViewController = [[tabBarController viewControllers] objectAtIndex:0];
    numpadViewController = [[tabBarController viewControllers] objectAtIndex:1];
    videoViewController = [[tabBarController viewControllers] objectAtIndex:2];
    imViewController = [[tabBarController viewControllers] objectAtIndex:3];
    settingsViewController = [[tabBarController viewControllers] objectAtIndex:4];

    loginViewController->portSIPSDK    = portSIPSDK;
    
    videoViewController->portSIPSDK    = portSIPSDK;
    imViewController->portSIPSDK       = portSIPSDK;
    settingsViewController->portSIPSDK = portSIPSDK;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInterruption:)
                                                 name:AVAudioSessionInterruptionNotification
                                               object:nil];
    
    internetReach = [Reachability reachabilityForInternetConnection];
    [self startNotifierNetwork];
    
    return YES;
}

- (void)handleInterruption: (NSNotification*) notification
{
    if(notification.name != AVAudioSessionInterruptionNotification
       || notification.userInfo == nil){
        return;
    }
    
    UInt8 theInterruptionType = [[notification.userInfo valueForKey:AVAudioSessionInterruptionTypeKey] intValue];
    
    NSLog(@"Session interrupted > --- %s ---\n", theInterruptionType == AVAudioSessionInterruptionTypeBegan ? "Begin Interruption" : "End Interruption");
    
    if (theInterruptionType == AVAudioSessionInterruptionTypeBegan) {
        [self holdAllCall];    }
    
    if (theInterruptionType == AVAudioSessionInterruptionTypeEnded) {
        // make sure to activate the session
        NSError *error;
        bool success = [[AVAudioSession sharedInstance] setActive:YES error:&error];
        
        if (!success)
            
            NSLog(@"AVAudioSession set active failed with error: %@", [error localizedDescription]);
        
        else {
            
            [self unholdCall];
        }
    }
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if(sessionArray[_activeLine].sessionState)
    {//video display use OpenGl ES, So Must Stop before APP enter background
        [videoViewController willResignActive];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //Disable to save battery, or when you don't need incoming calls while APP is in background.
    //When you need background, TCP and TLS SIP transport is save battery, UDP takes more battery
    [portSIPSDK startKeepAwake];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [portSIPSDK stopKeepAwake];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if(sessionArray[_activeLine].sessionState)
    {
        [videoViewController didBecomeActive];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)createConference:(PortSIPVideoRenderView*)conferenceVideoWindow
{
    if (!_isConference) {
        int ret = [portSIPSDK createConference:conferenceVideoWindow videoWidth:352 videoHeight:288 displayLocalVideo:YES];        if (ret != 0) {
            NSLog(@"Create Conference fail");
            _isConference = NO;
            return NO;
        }
        
        _isConference = YES;
        
        for (int i = LINE_BASE; i < MAX_LINES; i++) {
            if (sessionArray[i].sessionState) {
                if (sessionArray[i].holdState) {
                    [portSIPSDK unHold:sessionArray[i].sessionId];
                    sessionArray[i].holdState = NO;
                }
                [self joinToConference:sessionArray[i].sessionId];
            }
        }
    }
    
    return YES;
}

- (BOOL)joinToConference:(long)sessionId
{
    if (_isConference) {
        int ret = [portSIPSDK joinToConference:sessionId];
        if (ret != 0) {
            NSLog(@"Join to Conference fail");
            return NO;
        }else{
            //Remove session remote video window, Only show conference video windows
            [portSIPSDK setRemoteVideoWindow:sessionId remoteVideoWindow:nil];
            [portSIPSDK sendVideo:sessionId sendState:YES];
            NSLog(@"Join to Conference success");
            return YES;
        }
    }
    return NO;
}


- (void)removeFromConference:(long)sessionId
{
    if (_isConference) {
        
        int ret = [portSIPSDK removeFromConference:sessionId];
        if (ret != 0) {
            NSLog(@"Session %zd Remove from Conference fail", sessionId);
        }else{
            NSLog(@"Session %zd Remove from Conference success", sessionId);
        }
    }
}

- (void)destoryConference:(UIView *)viewRemoteVideo
{
    if (_isConference) {
        
        for (int i = LINE_BASE; i < MAX_LINES; i++) {
            if (sessionArray[i].sessionState ) {
                
                [portSIPSDK removeFromConference:sessionArray[i].sessionId];
                
                if (i != _activeLine) {
                    if (!sessionArray[i].holdState) {
                        [portSIPSDK hold:sessionArray[i].sessionId];
                        sessionArray[i].holdState = YES;
                    }
                }
            }
        }
        
        [portSIPSDK destroyConference];
        _isConference = NO;
        NSLog(@"DestoryConference");
    }
}

- (void)holdAllCall
{
    for (int i = LINE_BASE; i < MAX_LINES; i++) {
        if (sessionArray[i].sessionState) {
            [portSIPSDK hold:sessionArray[i].sessionId];
            sessionArray[i].holdState = YES;
        }
    }
    NSLog(@"holdAllCall...");
}

- (void)unholdAllCall
{
    for (int i = LINE_BASE; i < MAX_LINES; i++) {
        if (sessionArray[i].sessionState) {
            [portSIPSDK unHold:sessionArray[i].sessionId];
            sessionArray[i].holdState = NO;
        }
    }
    NSLog(@"unholdAllCall...");
}

- (void)muteAllCall
{
    for (int i = LINE_BASE; i < MAX_LINES; i++) {
        if (sessionArray[i].sessionState) {
            [portSIPSDK muteSession:sessionArray[i].sessionId
                   muteIncomingAudio:YES
                   muteOutgoingAudio:YES
                   muteIncomingVideo:YES
                   muteOutgoingVideo:YES];
        }
    }
}

- (void)unMuteAllCall
{
    for (int i = LINE_BASE; i < MAX_LINES; i++) {
        if (sessionArray[i].sessionState) {
            [portSIPSDK muteSession:sessionArray[i].sessionId
                   muteIncomingAudio:NO
                   muteOutgoingAudio:NO
                   muteIncomingVideo:NO
                   muteOutgoingVideo:NO];
        }
    }
}
@end
