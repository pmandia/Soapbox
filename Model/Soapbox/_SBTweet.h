// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBTweet.h instead.

#import <CoreData/CoreData.h>


@class SBUser;

@interface SBTweetID : NSManagedObjectID {}
@end

@interface _SBTweet : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SBTweetID*)objectID;



@property (nonatomic, retain) NSNumber *tweetType;

@property short tweetTypeValue;
- (short)tweetTypeValue;
- (void)setTweetTypeValue:(short)value_;

//- (BOOL)validateTweetType:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *retweetDate;

//- (BOOL)validateRetweetDate:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *truncated;

@property BOOL truncatedValue;
- (BOOL)truncatedValue;
- (void)setTruncatedValue:(BOOL)value_;

//- (BOOL)validateTruncated:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *lastAccessed;

//- (BOOL)validateLastAccessed:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *retweetedByScreenName;

//- (BOOL)validateRetweetedByScreenName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *downloadedAsFollower;

@property BOOL downloadedAsFollowerValue;
- (BOOL)downloadedAsFollowerValue;
- (void)setDownloadedAsFollowerValue:(BOOL)value_;

//- (BOOL)validateDownloadedAsFollower:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *longitude;

@property float longitudeValue;
- (float)longitudeValue;
- (void)setLongitudeValue:(float)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *creationDate;

//- (BOOL)validateCreationDate:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *latitude;

@property float latitudeValue;
- (float)latitudeValue;
- (void)setLatitudeValue:(float)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *text;

//- (BOOL)validateText:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *inReplyToScreenName;

//- (BOOL)validateInReplyToScreenName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *downloadedAsMention;

@property BOOL downloadedAsMentionValue;
- (BOOL)downloadedAsMentionValue;
- (void)setDownloadedAsMentionValue:(BOOL)value_;

//- (BOOL)validateDownloadedAsMention:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *inReplyToUserID;

@property short inReplyToUserIDValue;
- (short)inReplyToUserIDValue;
- (void)setInReplyToUserIDValue:(short)value_;

//- (BOOL)validateInReplyToUserID:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *createdUsingApp;

//- (BOOL)validateCreatedUsingApp:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *inReplyToStatusID;

@property long long inReplyToStatusIDValue;
- (long long)inReplyToStatusIDValue;
- (void)setInReplyToStatusIDValue:(long long)value_;

//- (BOOL)validateInReplyToStatusID:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *favorited;

@property BOOL favoritedValue;
- (BOOL)favoritedValue;
- (void)setFavoritedValue:(BOOL)value_;

//- (BOOL)validateFavorited:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *tweetID;

@property long long tweetIDValue;
- (long long)tweetIDValue;
- (void)setTweetIDValue:(long long)value_;

//- (BOOL)validateTweetID:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *retweetID;

@property long long retweetIDValue;
- (long long)retweetIDValue;
- (void)setRetweetIDValue:(long long)value_;

//- (BOOL)validateRetweetID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) SBUser* user;
//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;



@end

@interface _SBTweet (CoreDataGeneratedAccessors)

@end
