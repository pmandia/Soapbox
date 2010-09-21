// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBUser.m instead.

#import "_SBUser.h"

@implementation SBUserID
@end

@implementation _SBUser

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"User";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc_];
}

- (SBUserID*)objectID {
	return (SBUserID*)[super objectID];
}




@dynamic protected;



- (BOOL)protectedValue {
	NSNumber *result = [self protected];
	return result ? [result boolValue] : 0;
}

- (void)setProtectedValue:(BOOL)value_ {
	[self setProtected:[NSNumber numberWithBool:value_]];
}






@dynamic screenName;






@dynamic favoritesCount;



- (short)favoritesCountValue {
	NSNumber *result = [self favoritesCount];
	return result ? [result shortValue] : 0;
}

- (void)setFavoritesCountValue:(short)value_ {
	[self setFavoritesCount:[NSNumber numberWithShort:value_]];
}






@dynamic screenNameInitial;






@dynamic friendsCount;



- (short)friendsCountValue {
	NSNumber *result = [self friendsCount];
	return result ? [result shortValue] : 0;
}

- (void)setFriendsCountValue:(short)value_ {
	[self setFriendsCount:[NSNumber numberWithShort:value_]];
}






@dynamic lastAccessed;






@dynamic geoEnabled;



- (BOOL)geoEnabledValue {
	NSNumber *result = [self geoEnabled];
	return result ? [result boolValue] : 0;
}

- (void)setGeoEnabledValue:(BOOL)value_ {
	[self setGeoEnabled:[NSNumber numberWithBool:value_]];
}






@dynamic location;






@dynamic url;






@dynamic profileDescription;






@dynamic followersCount;



- (short)followersCountValue {
	NSNumber *result = [self followersCount];
	return result ? [result shortValue] : 0;
}

- (void)setFollowersCountValue:(short)value_ {
	[self setFollowersCount:[NSNumber numberWithShort:value_]];
}






@dynamic verified;



- (BOOL)verifiedValue {
	NSNumber *result = [self verified];
	return result ? [result boolValue] : 0;
}

- (void)setVerifiedValue:(BOOL)value_ {
	[self setVerified:[NSNumber numberWithBool:value_]];
}






@dynamic joinDate;






@dynamic avatarURL;






@dynamic following;



- (BOOL)followingValue {
	NSNumber *result = [self following];
	return result ? [result boolValue] : 0;
}

- (void)setFollowingValue:(BOOL)value_ {
	[self setFollowing:[NSNumber numberWithBool:value_]];
}






@dynamic name;






@dynamic userID;



- (short)userIDValue {
	NSNumber *result = [self userID];
	return result ? [result shortValue] : 0;
}

- (void)setUserIDValue:(short)value_ {
	[self setUserID:[NSNumber numberWithShort:value_]];
}






@dynamic statusesCount;



- (short)statusesCountValue {
	NSNumber *result = [self statusesCount];
	return result ? [result shortValue] : 0;
}

- (void)setStatusesCountValue:(short)value_ {
	[self setStatusesCount:[NSNumber numberWithShort:value_]];
}






@dynamic tweets;

	
- (NSMutableSet*)tweetsSet {
	[self willAccessValueForKey:@"tweets"];
	NSMutableSet *result = [self mutableSetValueForKey:@"tweets"];
	[self didAccessValueForKey:@"tweets"];
	return result;
}
	



@end
