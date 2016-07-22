
#import <UIKit/UIKit.h>

/*!
 * @author Copyright (c) 2006-2015 PortSIP Solutions,Inc. All rights reserved.
 * @version 11.2.2
 * @see http://www.PortSIP.com
 * @class PortSIPVideoRenderView
 * @brief PortSIP VoIP SDK Video Render View class.
 
 PortSIP VoIP SDK Video Render View class description.
 */
@interface PortSIPVideoRenderView : UIView

/*!
 *  @brief Initialize the Video Render view. shoud Initialize render before use.
 */
- (void)initVideoRender;

/*!
 *  @brief release the Video Render.
 */
- (void)releaseVideoRender;

/*!
 *  @brief Don't use this.Just call by SDK.
 */
-(void*)getVideoRenderView;

/*!
 *  @brief change the Video Render size.
 @remark Example:
 @code
 NSRect rect = videoRenderView.frame;
 rect.size.width += 20;
 rect.size.height += 20;
 
 videoRenderView.frame = rect;
 [videoRenderView setNeedsDisplay:YES];
 
 NSRect renderRect = [videoRenderView bounds];
 [videoRenderView updateVideoRenderFrame:renderRect];
 @endcode
 */
-(void)updateVideoRenderFrame:(CGRect)frameRect;
@end
