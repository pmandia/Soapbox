/*
 
 The MIT License
 
 Copyright (c) 2010 Soapbox Developers
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 */


#import "UIViewController+SBExtensions.h"


@implementation UIViewController (SBExtensions)

- (void)dismissModalViewControllerWithAnimatedTransition:(UIViewControllerAnimationTransition)transition
{
	[self dismissModalViewControllerWithAnimatedTransition:transition WithDuration:0.75f];
}

- (void)presentModalViewController:(UIViewController*)viewController withAnimatedTransition:(UIViewControllerAnimationTransition)transition
{
	[self presentModalViewController:viewController withAnimatedTransition:transition WithDuration:0.75f];
}

- (void)dismissModalViewControllerWithAnimatedTransition:(UIViewControllerAnimationTransition)transition WithDuration:(float)duration
{	
	if ( transition >= UIViewControlerAnimationTransitionFlipFromLeft )
	{
		UIViewAnimationTransition trans = UIViewAnimationTransitionNone;
		switch (transition) 
		{
			case UIViewControlerAnimationTransitionFlipFromLeft:
				trans = UIViewAnimationTransitionFlipFromLeft;
				break;
			case UIViewControlerAnimationTransitionFlipFromRight:
				trans = UIViewAnimationTransitionFlipFromRight;
				break;
			case UIViewControlerAnimationTransitionCurlUp:
				trans = UIViewAnimationTransitionCurlUp;
				break;
			case UIViewControlerAnimationTransitionCurlDown:
				trans = UIViewAnimationTransitionCurlDown;
				break;
			default:
				break;
		}
    
		UIWindow * window = [[self view] window]; 
		
		[[self view] setClipsToBounds:NO];
    
		UIView * sview = [[self view] superview];
    
		[UIView beginAnimations: @"AnimatedTransition_DismissModal" context: nil];
		[UIView setAnimationTransition:trans forView:window cache:YES];
		[UIView setAnimationDuration:duration];
		[[self view] removeFromSuperview];
		[UIView commitAnimations];
    
		[sview addSubview:[self view]];
		[self.navigationController dismissModalViewControllerAnimated:NO];
	}
	else if ( transition >= UIViewControlerAnimationTransitionFade )
	{
		NSString * trans = nil;
		NSString * dir   = nil;
		switch (transition) 
		{
			case UIViewControlerAnimationTransitionFade:
				trans = kCATransitionFade;
				break;
			case UIViewControlerAnimationTransitionPushFromTop:
				trans = kCATransitionPush;
				dir   = kCATransitionFromTop;
				break;
			case UIViewControlerAnimationTransitionPushFromRight:
				trans = kCATransitionPush;
				dir   = kCATransitionFromRight;
				break;
			case UIViewControlerAnimationTransitionPushFromBottom:
				trans = kCATransitionPush;
				dir   = kCATransitionFromBottom;
				break;
			case UIViewControlerAnimationTransitionPushFromLeft:
				trans = kCATransitionPush;
				dir   = kCATransitionFromLeft;
				break;
			case UIViewControlerAnimationTransitionMoveInFromTop:
				trans = kCATransitionMoveIn;
				dir   = kCATransitionFromTop;
				break;
			case UIViewControlerAnimationTransitionMoveInFromRight:
				trans = kCATransitionMoveIn;
				dir   = kCATransitionFromRight;
				break;
			case UIViewControlerAnimationTransitionMoveInFromBottom:
				trans = kCATransitionMoveIn;
				dir   = kCATransitionFromBottom;
				break;
			case UIViewControlerAnimationTransitionMoveInFromLeft:
				trans = kCATransitionMoveIn;
				dir   = kCATransitionFromLeft;
				break;
			case UIViewControlerAnimationTransitionRevealFromTop:
				trans = kCATransitionReveal;
				dir   = kCATransitionFromTop;
				break;
			case UIViewControlerAnimationTransitionRevealFromRight:
				trans = kCATransitionMoveIn;
				dir   = kCATransitionFromRight;
				break;
			case UIViewControlerAnimationTransitionRevealFromBottom:
				trans = kCATransitionReveal;
				dir   = kCATransitionFromBottom;
				break;
			case UIViewControlerAnimationTransitionRevealFromLeft:
				trans = kCATransitionReveal;
				dir   = kCATransitionFromLeft;
				break;
			default:
				break;
		}
    
		[[self.parentViewController view] setClipsToBounds:NO];
    
		// Set up the animation
		CATransition *animation = [CATransition animation];
		[animation setType:trans];
		[animation setSubtype:dir];
		
		[self.parentViewController dismissModalViewControllerAnimated:NO];
		
		// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
		[animation setDuration:duration];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
		[[[self.parentViewController.view superview] layer] addAnimation:animation forKey:@"AnimateTransition"];
	}
	else
	{
		[self.navigationController dismissModalViewControllerAnimated:NO];
	}
  
}

- (void)presentModalViewController:(UIViewController*)viewController withAnimatedTransition:(UIViewControllerAnimationTransition)transition WithDuration:(float)duration
{
	if ( transition >= UIViewControlerAnimationTransitionFlipFromLeft )
	{
		UIViewAnimationTransition trans = UIViewAnimationTransitionNone;
		switch (transition) {
			case UIViewControlerAnimationTransitionFlipFromLeft:
				trans = UIViewAnimationTransitionFlipFromLeft;
				break;
			case UIViewControlerAnimationTransitionFlipFromRight:
				trans = UIViewAnimationTransitionFlipFromRight;
				break;
			case UIViewControlerAnimationTransitionCurlUp:
				trans = UIViewAnimationTransitionCurlUp;
				break;
			case UIViewControlerAnimationTransitionCurlDown:
				trans = UIViewAnimationTransitionCurlDown;
				break;
			default:
				break;
		}
		
		UIViewController * topController = [self.navigationController topViewController];
		
		UIWindow * window = [[topController view] window]; 
    
		[[viewController view] setClipsToBounds:NO];
    
		[UIView beginAnimations: @"AnimatedTransition_PresentModal" context: nil];
		[UIView setAnimationTransition:trans forView:window cache:YES];
		[UIView setAnimationDuration:duration];
		[window addSubview:[viewController view]];
		[UIView commitAnimations];
    
		[self.navigationController presentModalViewController:viewController animated:NO];
	}
	else if ( transition >= UIViewControlerAnimationTransitionFade )
	{
		NSString * trans = nil;
		NSString * dir   = nil;
		switch (transition) 
		{
			case UIViewControlerAnimationTransitionFade:
				trans = kCATransitionFade;
				break;
			case UIViewControlerAnimationTransitionPushFromTop:
				trans = kCATransitionPush;
				dir   = kCATransitionFromTop;
				break;
			case UIViewControlerAnimationTransitionPushFromRight:
				trans = kCATransitionPush;
				dir   = kCATransitionFromRight;
				break;
			case UIViewControlerAnimationTransitionPushFromBottom:
				trans = kCATransitionPush;
				dir   = kCATransitionFromBottom;
				break;
			case UIViewControlerAnimationTransitionPushFromLeft:
				trans = kCATransitionPush;
				dir   = kCATransitionFromLeft;
				break;
			case UIViewControlerAnimationTransitionMoveInFromTop:
				trans = kCATransitionMoveIn;
				dir   = kCATransitionFromTop;
				break;
			case UIViewControlerAnimationTransitionMoveInFromRight:
				trans = kCATransitionMoveIn;
				dir   = kCATransitionFromRight;
				break;
			case UIViewControlerAnimationTransitionMoveInFromBottom:
				trans = kCATransitionMoveIn;
				dir   = kCATransitionFromBottom;
				break;
			case UIViewControlerAnimationTransitionMoveInFromLeft:
				trans = kCATransitionMoveIn;
				dir   = kCATransitionFromLeft;
				break;
			case UIViewControlerAnimationTransitionRevealFromTop:
				trans = kCATransitionReveal;
				dir   = kCATransitionFromTop;
				break;
			case UIViewControlerAnimationTransitionRevealFromRight:
				trans = kCATransitionMoveIn;
				dir   = kCATransitionFromRight;
				break;
			case UIViewControlerAnimationTransitionRevealFromBottom:
				trans = kCATransitionReveal;
				dir   = kCATransitionFromBottom;
				break;
			case UIViewControlerAnimationTransitionRevealFromLeft:
				trans = kCATransitionReveal;
				dir   = kCATransitionFromLeft;
				break;
			default:
				break;
		}
    
		[[viewController view] setClipsToBounds:NO];
		
		// Set up the animation
		CATransition *animation = [CATransition animation];
		[animation setType:trans];
		[animation setSubtype:dir];
    
		// Set the duration and timing function of the transtion -- duration is passed in as a parameter, use ease in/ease out as the timing function
		[animation setDuration:duration];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		
		[[self.parentViewController.view.superview layer] addAnimation:animation forKey:@"AnimateTransition"];
		
		[self.navigationController presentModalViewController:viewController animated:NO];
	}
	else 
	{
		[self.navigationController presentModalViewController:viewController animated:NO];
	}
}

@end
