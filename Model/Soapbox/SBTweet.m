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


#import "SBTweet.h"
#import "SBAccountManager.h"
#import "SBUsersController.h"
#import "RegexKitLite.h"
#import "NSString+SBExtensions.h"

static NSString *kTweetID = @"id";
static NSString *kTweetCreatedAt = @"created_at";
static NSString *kTweetScreenName = @"screen_name";
static NSString *kTweetFavorited = @"favorited";
static NSString *kTweetTruncated = @"truncated";
static NSString *kTweetInReplyToScreenName = @"in_reply_to_screen_name";
static NSString *kTweetInReplyToStatusID = @"in_reply_to_status_id";
static NSString *kTweetInReplyToUserID = @"in_reply_to_user_id";
static NSString *kTweetSource = @"source";
static NSString *kTweetText = @"text";
static NSString *kTweetRetweetedStatus = @"retweeted_status";
static NSString *kTweetUser = @"user";
static NSString *kTweetGeo = @"geo";
static NSString *kTweetGeoCoordinates = @"coordinates";

@interface SBTweet ()
- (void)parseGeocoordinatesFromDictionary:(NSDictionary *)geoDictionary;
- (void)parseTweetDictionary:(NSDictionary *)theDictionary;
@end

@implementation SBTweet

+ (SBTweet *)tweetWithID:(NSNumber *)theID usingManagedObjectContext:(NSManagedObjectContext *)moc
{
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  [fetchRequest setEntity:[NSEntityDescription entityForName:kTweetEntityName inManagedObjectContext:moc]];
  [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(tweetID == %@)", theID]];

  NSError *error = nil;
  SBTweet *tweet = nil;
  tweet = [[moc executeFetchRequest:fetchRequest error:&error] lastObject];
  [fetchRequest release];
  
  return tweet;
}

- (void)awakeFromFetch
{
  [super awakeFromFetch];
  self.lastAccessed = [NSDate date];
}

- (unsigned long long)engineID
{
  return [self.tweetID longLongValue];
}

- (NSString *)contentFormattedForDisplay
{
  NSString *formattedString = [NSString stringWithFormat:@"\
                               <html>\n\
                               <style type=\"text/css\">\n\
                               body { \
                                font-family: Helvetica;\n\
                                font-size: 14px;\
                               }\
                               .meta { color: #666; }\n\
                               </style>\n\
                               <body>\n\
                               %@ \n\
                               <p class=\"meta\">\
                               %@<br />\
                               %@\
                               using %@\
                               %@\
                               </p>\
                               </body>\n\
                               </html>\n\
                               ", [self tweetTextAsHTML], [self formattedCreationDate], [self locationInfo], self.createdUsingApp, [self retweetInfo]];
  
  return formattedString;
}

- (NSString *)locationInfo
{
  if ((self.latitudeValue != 0.0))
  {
    return @"<strong>Location Info Coming Soon</strong><br />";
  }
  
  return @"";
}

- (NSString *)retweetInfo
{
  if ((self.retweetedByScreenName))
  {
    NSString *retweetString = [NSString stringWithFormat:@"<br />retweeted by @<a href=\"x-soapbox://user?screen_name=%@\">%@</a>", self.retweetedByScreenName, self.retweetedByScreenName];    
    return retweetString;    
  }
  
  return @"";
}

- (NSString *)tweetTextAsHTML
{
  NSString *tweetString = self.text;
  NSString *urlRegex = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
  NSString *usernameRegex = @"@([A-Za-z0-9_]+)";
  
  tweetString = [tweetString stringByReplacingOccurrencesOfRegex:urlRegex withString:@"<a href=\"$0\">$0</a>"];
  
  // Replace usernames with links
  NSArray *matchedUsernamesArray = [tweetString componentsMatchedByRegex:usernameRegex];  
  for (NSString *username in matchedUsernamesArray)
  {
    NSString *userNameLessAt = [username substringWithRange:NSMakeRange(1, [username length] - 1)];
    NSString *formattedUsername = [NSString stringWithFormat:@"@<a href=\"x-soapbox://user?screen_name=%@\">%@</a>",userNameLessAt, userNameLessAt];
    tweetString = [tweetString stringByReplacingOccurrencesOfString:username withString:formattedUsername];
  }
  
  return tweetString;
}

- (NSString *)tweetTextAsEmail
{
  NSString *tweetString = [NSString stringWithFormat:@"<p>%@</p><p>%@</p>", self.text, [self tweetURL]];
  NSString *urlRegex = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
  NSString *usernameRegex = @"@([A-Za-z0-9_]+)";
  
  tweetString = [tweetString stringByReplacingOccurrencesOfRegex:urlRegex withString:@"<a href=\"$0\">$0</a>"];
  
  // Replace usernames with links
  NSArray *matchedUsernamesArray = [tweetString componentsMatchedByRegex:usernameRegex];  
  for (NSString *username in matchedUsernamesArray)
  {
    NSString *userNameLessAt = [username substringWithRange:NSMakeRange(1, [username length] - 1)];
    NSString *formattedUsername = [NSString stringWithFormat:@"@<a href=\"http://twitter.com/%@\">%@</a>",userNameLessAt, userNameLessAt];
    tweetString = [tweetString stringByReplacingOccurrencesOfString:username withString:formattedUsername];
  }
  
  return tweetString;  
}

// April 10, 2010 3:40PM
- (NSString *)formattedCreationDate
{
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateStyle:NSDateFormatterLongStyle];
  [formatter setTimeStyle:NSDateFormatterShortStyle];
  NSString *formattedDate = [formatter stringFromDate:self.creationDate];  
  [formatter release];
  
  return formattedDate;
}

- (NSString *)tweetURL
{
  return [NSString stringWithFormat:@"http://twitter.com/%@/status/%@", self.user.screenName, self.tweetID];
}
                           
- (void)markDirty
{
  [self willAccessValueForKey:@"lastAccessed"];
  self.lastAccessed = [NSDate date];
  [self didAccessValueForKey:@"lastAccessed"];
}

- (void)parseTweetContentsFromDictionary:(NSDictionary *)theDictionary
{  
  NSDictionary *tweetDictionary = theDictionary;
  NSDictionary *retweetDictionary = [theDictionary objectForKey:kTweetRetweetedStatus];

  if ((retweetDictionary != nil))
  {
    [self parseTweetDictionary:retweetDictionary];    
    self.tweetTypeValue = PTTweetTypeRetweet;
    self.retweetedByScreenName = [[theDictionary objectForKey:kTweetUser] objectForKey:kTweetScreenName];    
    
    // Set the tweet_id (and date values) to be the parent tweet's ID / date so we don't fetch it twice.
    self.retweetDate = ConvertStringToDate([retweetDictionary objectForKey:kTweetCreatedAt]);
    self.creationDate = ConvertStringToDate([tweetDictionary objectForKey:kTweetCreatedAt]);
    self.retweetID = [NSNumber numberWithLongLong:[[retweetDictionary objectForKey:kTweetID] longLongValue]];
    self.tweetID = [NSNumber numberWithLongLong:[[tweetDictionary objectForKey:kTweetID] longLongValue]];
  }  
  else
  {
    [self parseTweetDictionary:tweetDictionary];
  }
}

#pragma mark -
#pragma mark Class Extension Methods
// +--------------------------------------------------------------------
// | Class Extension Methods
// +--------------------------------------------------------------------

- (void)parseTweetDictionary:(NSDictionary *)theDictionary
{
  NSDictionary *tweetDictionary = [theDictionary retain]; 
  
  self.tweetID = [NSNumber numberWithLongLong:[[tweetDictionary objectForKey:kTweetID] longLongValue]];  
  self.creationDate = ConvertStringToDate([tweetDictionary objectForKey:kTweetCreatedAt]);
  
  self.favorited = ((BOOL)[[tweetDictionary objectForKey:kTweetFavorited] boolValue]) ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
  self.truncated = ((BOOL)[[tweetDictionary objectForKey:kTweetTruncated] boolValue]) ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
  
  NSString *inReplyToScreenName = [tweetDictionary objectForKey:kTweetInReplyToScreenName];
  self.inReplyToScreenName = (!isNullable(inReplyToScreenName)) ? inReplyToScreenName : @"";
  
  NSNumber *inReplyToStatusID = [tweetDictionary objectForKey:kTweetInReplyToStatusID];
  self.inReplyToStatusID = (!isNullable(inReplyToStatusID)) ? inReplyToStatusID : [NSNumber numberWithLongLong:0.0];
  
  NSNumber *inReplyToUserID = [tweetDictionary objectForKey:kTweetInReplyToUserID];
  self.inReplyToUserID = (!isNullable(inReplyToUserID)) ? inReplyToUserID : [NSNumber numberWithInteger:0];
  
  self.createdUsingApp = [tweetDictionary objectForKey:kTweetSource];
  self.text = [[tweetDictionary objectForKey:kTweetText] stringByUnescapingEntities];   
  
  NSString *loggedInUser = [[SBAccountManager manager] loggedInUserAccount].screenName;
  if (([self.inReplyToScreenName isEqualToString:loggedInUser]))
  {
    self.tweetTypeValue = SBTweetTypeMention;
  }
  else if (([self.user.screenName isEqualToString:loggedInUser]))
  {
    self.tweetTypeValue = SBTweetTypePersonal;
  }
  
  NSDictionary *geoDictionary = [tweetDictionary objectForKey:kTweetGeo];
  if (([geoDictionary respondsToSelector:@selector(objectForKey:)]))
  {
    [self parseGeocoordinatesFromDictionary:geoDictionary];
  }
  
  [tweetDictionary release];
}

- (void)parseGeocoordinatesFromDictionary:(NSDictionary *)geoDictionary
{
  NSArray *coordinates = [geoDictionary objectForKey:kTweetGeoCoordinates];
  NSNumber *latitude = [coordinates objectAtIndex:0];
  NSNumber *longitude = [coordinates objectAtIndex:1];
  self.latitude = latitude;
  self.longitude = longitude;  
}

@end
