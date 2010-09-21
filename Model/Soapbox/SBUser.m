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


#import "SBUser.h"
#import "SBImageCache.h"

static NSString *kUserID = @"id";
static NSString *kUserScreenName = @"screen_name";
static NSString *kUserFullName = @"name";
static NSString *kUserJoinDate = @"created_at";
static NSString *kUserLocation = @"location";
static NSString *kUserDescription = @"description";
static NSString *kUserURL = @"url";
static NSString *kUserAvatarURL = @"profile_image_url";
static NSString *kUserFollowersCount = @"followers_count";
static NSString *kUserFavoritesCount = @"favourites_count";
static NSString *kUserFriendsCount = @"friends_count";
static NSString *kUserStatusCount = @"statuses_count";
static NSString *kUserFollowing = @"following";
static NSString *kUserGeoEnabled = @"geo_enabled";
static NSString *kUserProtected = @"protected";
static NSString *kUserVerified = @"verified";
static NSString *kUserInitial = @"screenNameInitial";

@implementation SBUser

+ (SBUser *)userWithScreenName:(NSString *)theScreenName usingManagedObjectContext:(NSManagedObjectContext *)moc
{
  NSFetchRequest *request = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:kUserEntityName inManagedObjectContext:moc];
  [request setEntity:entity];
  [request setFetchLimit:1];
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"screenName == %@", theScreenName];
  [request setPredicate:predicate];
  
  NSError *error = nil;
  SBUser *user = nil;
  user = [[moc executeFetchRequest:request error:&error] lastObject];  
  
  [request release];
  return user;
}

- (void)dealloc 
{
  [avatar release];
  [super dealloc];
}

- (void)awakeFromFetch
{
  [super awakeFromFetch];
  self.lastAccessed = [NSDate date];
}

- (void)markDirty
{
  [self willAccessValueForKey:@"id"];
  [self didAccessValueForKey:@"id"];
}

- (void)parseUserContentsFromDictionary:(NSDictionary *)theDictionary
{
  self.userID = [NSNumber numberWithInteger:[[theDictionary objectForKey:kUserID] integerValue]];
  self.screenName = [theDictionary objectForKey:kUserScreenName];
  self.name = [theDictionary objectForKey:kUserFullName];
  
  self.joinDate = ConvertStringToDate([theDictionary objectForKey:kUserJoinDate]);
  
  NSString *theLocation = [theDictionary objectForKey:kUserLocation];
  self.location = (!isNullable(theLocation)) ? theLocation : @"";

  NSString *theDescription = [theDictionary objectForKey:kUserDescription];
  self.profileDescription = (!isNullable(theDescription)) ? theDescription : @"";
  
  NSString *theURL = [theDictionary objectForKey:kUserURL];
  self.url = (!isNullable(theURL)) ? theURL : @"";
  
  self.avatarURL = [theDictionary objectForKey:kUserAvatarURL];

  self.followersCount = [NSNumber numberWithInteger:[[theDictionary objectForKey:kUserFollowersCount] integerValue]];
  self.favoritesCount = [NSNumber numberWithInteger:[[theDictionary objectForKey:kUserFavoritesCount] integerValue]];
  self.friendsCount = [NSNumber numberWithInteger:[[theDictionary objectForKey:kUserFriendsCount] integerValue]];
  self.statusesCount = [NSNumber numberWithInteger:[[theDictionary objectForKey:kUserStatusCount] integerValue]];
  
  NSNumber *isBeingFollowed = [theDictionary objectForKey:kUserFollowing];
  self.following = (!isNullable(isBeingFollowed)) ? isBeingFollowed : [NSNumber numberWithBool:NO];
  
  self.geoEnabled = ((BOOL)[[theDictionary objectForKey:kUserGeoEnabled] boolValue]) ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
  self.protected = ((BOOL)[[theDictionary objectForKey:kUserProtected] boolValue]) ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];  
  self.verified = ((BOOL)[[theDictionary objectForKey:kUserVerified] boolValue]) ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];  
}

#pragma mark -
#pragma mark Custom Accessor Methods
// +--------------------------------------------------------------------
// | Custom Accessor Methods
// +--------------------------------------------------------------------

- (UIImage *)avatar
{    
  if ((avatar != nil)) return avatar;
  
  UIImage *cachedImage = [[SBImageCache sharedImageCache] imageForUserName:self.screenName];
  
  if ((cachedImage != nil))
  {
    self.avatar = cachedImage;
  }
  else
  {
    avatar = nil;
  }
  
  return avatar;
}

- (void)setAvatar:(UIImage *)theAvatar
{
  if (avatar != theAvatar) 
  {
    [avatar release];
    avatar = [theAvatar retain];
    [[SBImageCache sharedImageCache] storeImage:theAvatar forUserName:self.screenName];
  }  
}

- (NSString *)screenNameInitial 
{
  [self willAccessValueForKey:kUserInitial];
  NSString *initial = [[[self screenName] substringToIndex:1] uppercaseString];
  [self didAccessValueForKey:kUserInitial];
  
  return initial;
}

@end
