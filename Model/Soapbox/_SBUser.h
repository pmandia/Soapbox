// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBUser.h instead.

#import <CoreData/CoreData.h>


@class SBTweet;

@interface SBUserID : NSManagedObjectID {}
@end

@interface _SBUser : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SBUserID*)objectID;



@property (nonatomic, retain) NSNumber *protected;

@property BOOL protectedValue;
- (BOOL)protectedValue;
- (void)setProtectedValue:(BOOL)value_;

//- (BOOL)validateProtected:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *screenName;

//- (BOOL)validateScreenName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *favoritesCount;

@property short favoritesCountValue;
- (short)favoritesCountValue;
- (void)setFavoritesCountValue:(short)value_;

//- (BOOL)validateFavoritesCount:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *screenNameInitial;

//- (BOOL)validateScreenNameInitial:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *friendsCount;

@property short friendsCountValue;
- (short)friendsCountValue;
- (void)setFriendsCountValue:(short)value_;

//- (BOOL)validateFriendsCount:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *lastAccessed;

//- (BOOL)validateLastAccessed:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *geoEnabled;

@property BOOL geoEnabledValue;
- (BOOL)geoEnabledValue;
- (void)setGeoEnabledValue:(BOOL)value_;

//- (BOOL)validateGeoEnabled:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *location;

//- (BOOL)validateLocation:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *url;

//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *profileDescription;

//- (BOOL)validateProfileDescription:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *followersCount;

@property short followersCountValue;
- (short)followersCountValue;
- (void)setFollowersCountValue:(short)value_;

//- (BOOL)validateFollowersCount:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *verified;

@property BOOL verifiedValue;
- (BOOL)verifiedValue;
- (void)setVerifiedValue:(BOOL)value_;

//- (BOOL)validateVerified:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *joinDate;

//- (BOOL)validateJoinDate:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *avatarURL;

//- (BOOL)validateAvatarURL:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *following;

@property BOOL followingValue;
- (BOOL)followingValue;
- (void)setFollowingValue:(BOOL)value_;

//- (BOOL)validateFollowing:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *name;

//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *userID;

@property short userIDValue;
- (short)userIDValue;
- (void)setUserIDValue:(short)value_;

//- (BOOL)validateUserID:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *statusesCount;

@property short statusesCountValue;
- (short)statusesCountValue;
- (void)setStatusesCountValue:(short)value_;

//- (BOOL)validateStatusesCount:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSSet* tweets;
- (NSMutableSet*)tweetsSet;



@end

@interface _SBUser (CoreDataGeneratedAccessors)

- (void)addTweets:(NSSet*)value_;
- (void)removeTweets:(NSSet*)value_;
- (void)addTweetsObject:(SBTweet*)value_;
- (void)removeTweetsObject:(SBTweet*)value_;

@end
