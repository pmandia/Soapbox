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

#import "SBAppDelegate.h"
#import "CCoreDataManager.h"
#import "SBRootViewController.h"
#import "SBHomeTimelineController.h"
#import "SBTimelineViewController.h"
#import "SBAuthenticationViewController.h"
#import "SBUserViewController.h"
#import "SBAccountManager.h"

#import "SBBitlyHelper.h"

@interface SBAppDelegate ()
- (void)showAuthenticationViewController;
- (void)showTimelineForLoggedInAccount:(NSString *)username;
- (void)loggedInUserChanged:(NSNotification *)theNotification;
- (void)fadeOutDefaultImage;
- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)initializeDefaultPreferencesIfNecessary;
@end


@implementation SBAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize coreDataManager;

+ (SBAppDelegate *)instance
{
  return (SBAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (id)init
{
  if ((self = [super init]))
  {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedInUserChanged:) name:kLoggedInAccountDidChange object:nil];
  }
  
  return self;
}

#pragma mark -
#pragma mark Application Lifecycle
// +--------------------------------------------------------------------
// | Application Lifecycle
// +--------------------------------------------------------------------

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
  // Override point for customization after app launch    
  [window addSubview:[navigationController view]];
  [window makeKeyAndVisible];
  
  [self promptForAccountIfNotCurrentlyLoggedIn];
  [self initializeDefaultPreferencesIfNecessary];
  [self fadeOutDefaultImage];
    
  return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
  if (self.coreDataManager != nil)
  {
    [self.coreDataManager save];
  }
}


// Currently Supported URL Schemes
// Open profile by username: x-soapbox://user?screen_name=justin

- (BOOL)application:(UIApplication *)theApplication handleOpenURL:(NSURL *)theURL 
{
  if ((!theURL))
  {  
    return NO; 
  }
  
  // Get parameters from query string.
  NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
  NSArray *keyValue = nil;
  
  for (NSString *parameter in [[theURL query] componentsSeparatedByString:@"&"]) 
  {
    keyValue = [parameter componentsSeparatedByString:@"="];
    
    if([keyValue count] == 2)
    {
      [parameters setObject:[keyValue objectAtIndex:1] forKey:[keyValue objectAtIndex:0]];
    }
  }
  
  if([[theURL host] isEqualToString:@"user"]) 
  {
    NSString *screenName = [parameters objectForKey:@"screen_name"];
    
    if ((screenName))
    {
      SBUserViewController *userViewController = [[SBUserViewController alloc] initWithNibName:NSStringFromClass([SBUserViewController class]) bundle:nil];
      [self.navigationController pushViewController:userViewController animated:YES];
      [userViewController release];
      return YES;
    }
  }
  
  [parameters release];
  
  return NO;
}


#pragma mark -
#pragma mark Memory Management
// +--------------------------------------------------------------------
// | Memory Management
// +--------------------------------------------------------------------

- (void)dealloc 
{
  [navigationController release]; self.navigationController = nil;
  [window release]; self.window = nil;

  [[NSNotificationCenter defaultCenter] removeObserver:kLoggedInAccountDidChange];
  
  [super dealloc];
}

#pragma mark -
#pragma mark Instance Methods
// +--------------------------------------------------------------------
// | Instance Methods
// +--------------------------------------------------------------------

- (void)promptForAccountIfNotCurrentlyLoggedIn
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *loggedInAccount = [defaults objectForKey:kLoggedInAccountName];
    
  if ((!loggedInAccount))
  {
    [self showAuthenticationViewController];
  }  
  else 
  {
    [self showTimelineForLoggedInAccount:loggedInAccount];
  }
}

- (void)showAuthenticationViewController
{
  SBAuthenticationViewController *accountController = [[SBAuthenticationViewController alloc] initWithNibName:NSStringFromClass([SBAuthenticationViewController class]) bundle:nil];
  UINavigationController *accountNavigationController = [[UINavigationController alloc] initWithRootViewController:accountController];
  [self.navigationController presentModalViewController:accountNavigationController animated:NO];
  [accountController release];
  [accountNavigationController release];      
}

- (void)showTimelineForLoggedInAccount:(NSString *)username;
{  
  SBAccount *account = [[SBAccountManager manager] loggedInUserAccount];
  NSString *twitterID = [account.twitterID  stringValue];
  NSDictionary *theOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, nil];
  self.coreDataManager = [[[CCoreDataManager alloc] initWithModelName:@"Soapbox" persistentStoreName:twitterID forceReplace:NO storeType:NULL storeOptions:theOptions] autorelease];
    
  SBRootViewController *rootViewController = [[SBRootViewController alloc] initWithNibName:NSStringFromClass([SBRootViewController class]) bundle:nil];
  [self.navigationController pushViewController:rootViewController animated:NO];
  [rootViewController release];
  
  SBHomeTimelineController *timelineController = [[SBHomeTimelineController alloc] initWithNibName:NSStringFromClass([SBTimelineViewController class]) bundle:nil];
  [self.navigationController pushViewController:timelineController animated:NO];  
  [timelineController release];
}
      
- (void)loggedInUserChanged:(NSNotification *)theNotification
{
  if ((self.coreDataManager != nil))
  {
    [coreDataManager save];
    coreDataManager = nil;
  }
  
  SBAccount *account = (SBAccount *)[theNotification object];
  NSString *twitterID = [account.twitterID stringValue];
  NSDictionary *theOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, nil];
  self.coreDataManager = [[[CCoreDataManager alloc] initWithModelName:@"Soapbox" persistentStoreName:twitterID forceReplace:NO storeType:NULL storeOptions:theOptions] autorelease];
}

- (void)startupAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
  [splashView removeFromSuperview];
  [splashView release];
}

- (void)fadeOutDefaultImage
{
  splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, 480)];
  splashView.image = [UIImage imageNamed:@"Default.png"];
  [window addSubview:splashView];
  [window bringSubviewToFront:splashView];
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:0.5];
  [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:window cache:YES];
  [UIView setAnimationDelegate:self]; 
  [UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
  splashView.alpha = 0.0;
  [UIView commitAnimations];  
}


- (void)initializeDefaultPreferencesIfNecessary
{
  NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
  NSString *testValue = [settings stringForKey:kDisplayNameFormat];
  if (testValue == nil)
  {
    NSString *bundle = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];
    NSDictionary *plist = [[NSDictionary dictionaryWithContentsOfFile:bundle] objectForKey:@"PreferenceSpecifiers"];
    NSMutableDictionary *defaults = [NSMutableDictionary new];
    
    // Loop through the bundle settings preferences and pull out the key/default pairs
    for (NSDictionary *setting in plist)
    {
      NSString *key = [setting objectForKey:@"Key"];
      if (key)
      {
        [defaults setObject:[setting objectForKey:@"DefaultValue"] forKey:key];
      }
    }
    
    // Persist the newly initialized default settings and reload them
    [settings setPersistentDomain:defaults forName:[[NSBundle mainBundle] bundleIdentifier]];
    settings = [NSUserDefaults standardUserDefaults];
  }
}

@end

