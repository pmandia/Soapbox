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


#import "SBTwitterManager.h"
#import "MGTwitterEngine.h"
#import "MGTwitterEngine.h"
#import "SBAccountManager.h"
#import "SBAccount.h"

@implementation SBTwitterManager

+ (SBTwitterManager *)manager
{
  return [[[SBTwitterManager alloc] init] autorelease];
}

+ (MGTwitterEngine *)createTwitterEngineForCurrentUserWithDelegate:(id)delegate
{
  SBTwitterManager *manager = [[[SBTwitterManager alloc] init] autorelease];
  
  SBAccount *account = [[SBAccountManager manager] loggedInUserAccount];
  if (account)
  {
    return [manager createTwitterEngineForUserAccount:account delegate:delegate];
  }
  
  return nil;  
}

- (MGTwitterEngine *)createTwitterEngineForUserAccount:(SBAccount *)account delegate:(id)delegate
{
  MGTwitterEngine *engine = nil;
  
  // Sanity check
  if ([kOAuthConsumerKey isEqualToString:@""] || [kOAuthConsumerSecret isEqualToString:@""])
  {
    NSString *message = @"Please add your Consumer Key and Consumer Secret from http://twitter.com/oauth_clients/details/<your app id> to the XAuthTwitterEngineDemoViewController.h before running the app. Thank you!";
    UIAlertViewQuick(@"Missing OAuth details", message, @"OK");
  }    
  
  // Create a TwitterEngine and set our login details.
  engine = [[[MGTwitterEngine alloc] initWithDelegate:delegate] autorelease];
  
  // set the consumer key and consumer secret.. 
  [engine setConsumerKey: kOAuthConsumerKey secret: kOAuthConsumerSecret];
  
  NSString *tokenString = account.secret;
  NSString *keyString = account.key;
  
  OAToken *accessToken = [[OAToken alloc] initWithKey:keyString secret:tokenString];
    
  [engine setAccessToken: accessToken];
    
  return engine;
}

- (void)dealloc
{
  [super dealloc];
}

@end
