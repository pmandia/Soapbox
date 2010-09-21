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

#import "SBAccount.h"

@implementation SBAccount

@synthesize twitterID;
@synthesize fullName;
@synthesize screenName;
@synthesize secret;
@synthesize key;
@synthesize homeTimelineLastDownloadTweetID;
@synthesize homeTimelineScrollViewLastContentOffset;
@synthesize mentionsTimelineLastDownloadTweetID;
@synthesize mentionsTimelineScrollViewLastContentOffset;
@synthesize bitlyUserName;
@synthesize bitlyApiKey;
@synthesize locationPostingPreference;
@synthesize enabledGeoPosting;
@synthesize isProtected;

- (id)initWithUserName:(NSString *)theUserName
{
  if ((self = [super init]))
  {
    self.twitterID = [NSNumber numberWithInteger:0];
    self.screenName = theUserName;
    self.secret = @"";
    self.key = @"";
    self.fullName = @"";
    self.homeTimelineLastDownloadTweetID = [NSNumber numberWithLongLong:0];
    self.homeTimelineScrollViewLastContentOffset = @"{0,0}";
    self.mentionsTimelineLastDownloadTweetID = [NSNumber numberWithLongLong:0];
    self.mentionsTimelineScrollViewLastContentOffset = @"{0,0}";
    self.bitlyUserName = @"";
    self.bitlyApiKey = @"";
    self.locationPostingPreference = SBAccountLocationManual;
    self.enabledGeoPosting = NO;
    self.isProtected = NO;
  }
  
  return self;
}

- (id)initWithUserDictionary:(NSDictionary *)theDictionary
{
  if ((self = [super init]))
  {
    self.twitterID = [NSNumber numberWithInteger:[[theDictionary objectForKey:@"UserDefaultTwitterID"] integerValue]];
    self.fullName = [theDictionary objectForKey:@"UserDefaultFullName"];
    self.screenName = [theDictionary objectForKey:@"UserDefaultUserName"];
    self.key = [theDictionary objectForKey:@"OAuthKey"];
    self.homeTimelineLastDownloadTweetID = [NSNumber numberWithLongLong:[[theDictionary objectForKey:@"HomeLastDownloadedTweetID"] longLongValue]];
    self.homeTimelineScrollViewLastContentOffset = [theDictionary objectForKey:@"HomeTimelineScrollViewLastContentOffset"];
    self.mentionsTimelineLastDownloadTweetID = [NSNumber numberWithLongLong:[[theDictionary objectForKey:@"MentionsLastDownloadedTweetID"] longLongValue]];
    self.mentionsTimelineScrollViewLastContentOffset = [theDictionary objectForKey:@"MentionsTimelineScrollViewLastContentOffset"];
    self.bitlyUserName = [theDictionary objectForKey:@"UserDefaultBitlyLogin"];
    
    if ((self.bitlyUserName != nil))
    {
      NSError *err = nil;
      self.bitlyApiKey = [SFHFKeychainUtils getPasswordForUsername:self.bitlyUserName andServiceName:kBitlyService error:&err];
      if ((err))
      {
        NSLog(@"Error fetching bit.ly credentials from keychain: %@", [err localizedDescription]);
      }
    }
    
    self.locationPostingPreference = [[theDictionary objectForKey:@"UserDefaultLocationPostingPreference"] integerValue];
    self.enabledGeoPosting = [[theDictionary objectForKey:@"UserDefaultGeoEnabled"] boolValue];
    self.isProtected = [[theDictionary objectForKey:@"UserDefaultIsProtected"] boolValue];
  }
  
  return self;  
}

- (void)dealloc
{
  [twitterID release];
  [fullName release];
  [screenName release];
  [secret release];
  [key release];
  [bitlyApiKey release];
  [bitlyUserName release];
  [homeTimelineLastDownloadTweetID release];
  [homeTimelineScrollViewLastContentOffset release];
  [mentionsTimelineLastDownloadTweetID release];
  [mentionsTimelineScrollViewLastContentOffset release];
  
  [super dealloc];
}

- (NSMutableDictionary *)serializeAsDictionary
{
  NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
  
  [dictionary setObjectOrNull:self.twitterID forKey:@"UserDefaultTwitterID"];
  [dictionary setObjectOrNull:self.fullName forKey:@"UserDefaultFullName"];
  [dictionary setObjectOrNull:self.screenName forKey:@"UserDefaultUserName"];
  [dictionary setObjectOrNull:self.key forKey:@"OAuthKey"];
  [dictionary setObjectOrNull:self.homeTimelineLastDownloadTweetID forKey:@"HomeLastDownloadedTweetID"];
  [dictionary setObjectOrNull:self.homeTimelineScrollViewLastContentOffset forKey:@"HomeTimelineScrollViewLastContentOffset"];
  [dictionary setObjectOrNull:self.mentionsTimelineLastDownloadTweetID forKey:@"MentionsLastDownloadedTweetID"];
  [dictionary setObjectOrNull:self.mentionsTimelineScrollViewLastContentOffset forKey:@"MentionsTimelineScrollViewLastContentOffset"];
  [dictionary setObjectOrNull:self.bitlyUserName forKey:@"UserDefaultBitlyLogin"];

  if ((self.bitlyUserName != nil)) 
  {
    NSError *err = nil;
    
    if ([SFHFKeychainUtils storeUsername:self.bitlyUserName andPassword:self.bitlyApiKey forServiceName:kBitlyService updateExisting:YES error:&err] == NO)
    {
      if ((err))
      {
        NSLog(@"Error storing bit.ly credentials: %@", [err localizedDescription]);
      }
    }    
  }

  [dictionary setObjectOrNull:[NSNumber numberWithInteger:self.locationPostingPreference] forKey:@"UserDefaultLocationPostingPreference"];
  [dictionary setObjectOrNull:[NSNumber numberWithBool:self.enabledGeoPosting] forKey:@"UserDefaultGeoEnabled"];  
  [dictionary setObjectOrNull:[NSNumber numberWithBool:self.isProtected] forKey:@"UserDefaultIsProtected"];
  
  return [dictionary autorelease];  
}

- (NSString *)locationPostingPreferenceTitle
{  
  NSString *locationPreferenceString = @"";
  
  switch ((self.locationPostingPreference))
  {
    case SBAccountLocationOff:
      locationPreferenceString = NSLocalizedString(@"Off", nil);
      break;
    case SBAccountLocationManual:
      locationPreferenceString = NSLocalizedString(@"Manual", nil);
      break;
    case SBAccountLocationAuto:
      locationPreferenceString = NSLocalizedString(@"Automatic", nil);
      break;
  }
  
  return locationPreferenceString;
}

@end
