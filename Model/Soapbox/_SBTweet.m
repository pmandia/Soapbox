// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBTweet.m instead.

#import "_SBTweet.h"

@implementation SBTweetID
@end

@implementation _SBTweet

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Tweet";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Tweet" inManagedObjectContext:moc_];
}

- (SBTweetID*)objectID {
	return (SBTweetID*)[super objectID];
}




@dynamic tweetType;



- (short)tweetTypeValue {
	NSNumber *result = [self tweetType];
	return result ? [result shortValue] : 0;
}

- (void)setTweetTypeValue:(short)value_ {
	[self setTweetType:[NSNumber numberWithShort:value_]];
}






@dynamic retweetDate;






@dynamic truncated;



- (BOOL)truncatedValue {
	NSNumber *result = [self truncated];
	return result ? [result boolValue] : 0;
}

- (void)setTruncatedValue:(BOOL)value_ {
	[self setTruncated:[NSNumber numberWithBool:value_]];
}






@dynamic lastAccessed;






@dynamic retweetedByScreenName;






@dynamic downloadedAsFollower;



- (BOOL)downloadedAsFollowerValue {
	NSNumber *result = [self downloadedAsFollower];
	return result ? [result boolValue] : 0;
}

- (void)setDownloadedAsFollowerValue:(BOOL)value_ {
	[self setDownloadedAsFollower:[NSNumber numberWithBool:value_]];
}






@dynamic longitude;



- (float)longitudeValue {
	NSNumber *result = [self longitude];
	return result ? [result floatValue] : 0;
}

- (void)setLongitudeValue:(float)value_ {
	[self setLongitude:[NSNumber numberWithFloat:value_]];
}






@dynamic creationDate;






@dynamic latitude;



- (float)latitudeValue {
	NSNumber *result = [self latitude];
	return result ? [result floatValue] : 0;
}

- (void)setLatitudeValue:(float)value_ {
	[self setLatitude:[NSNumber numberWithFloat:value_]];
}






@dynamic text;






@dynamic inReplyToScreenName;






@dynamic downloadedAsMention;



- (BOOL)downloadedAsMentionValue {
	NSNumber *result = [self downloadedAsMention];
	return result ? [result boolValue] : 0;
}

- (void)setDownloadedAsMentionValue:(BOOL)value_ {
	[self setDownloadedAsMention:[NSNumber numberWithBool:value_]];
}






@dynamic inReplyToUserID;



- (short)inReplyToUserIDValue {
	NSNumber *result = [self inReplyToUserID];
	return result ? [result shortValue] : 0;
}

- (void)setInReplyToUserIDValue:(short)value_ {
	[self setInReplyToUserID:[NSNumber numberWithShort:value_]];
}






@dynamic createdUsingApp;






@dynamic inReplyToStatusID;



- (long long)inReplyToStatusIDValue {
	NSNumber *result = [self inReplyToStatusID];
	return result ? [result longLongValue] : 0;
}

- (void)setInReplyToStatusIDValue:(long long)value_ {
	[self setInReplyToStatusID:[NSNumber numberWithLongLong:value_]];
}






@dynamic favorited;



- (BOOL)favoritedValue {
	NSNumber *result = [self favorited];
	return result ? [result boolValue] : 0;
}

- (void)setFavoritedValue:(BOOL)value_ {
	[self setFavorited:[NSNumber numberWithBool:value_]];
}






@dynamic tweetID;



- (long long)tweetIDValue {
	NSNumber *result = [self tweetID];
	return result ? [result longLongValue] : 0;
}

- (void)setTweetIDValue:(long long)value_ {
	[self setTweetID:[NSNumber numberWithLongLong:value_]];
}






@dynamic retweetID;



- (long long)retweetIDValue {
	NSNumber *result = [self retweetID];
	return result ? [result longLongValue] : 0;
}

- (void)setRetweetIDValue:(long long)value_ {
	[self setRetweetID:[NSNumber numberWithLongLong:value_]];
}






@dynamic user;

	



@end
