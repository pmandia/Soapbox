// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBFilter.h instead.

#import <CoreData/CoreData.h>



@interface SBFilterID : NSManagedObjectID {}
@end

@interface _SBFilter : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (SBFilterID*)objectID;



@property (nonatomic, retain) NSNumber *sourceFilter;

@property BOOL sourceFilterValue;
- (BOOL)sourceFilterValue;
- (void)setSourceFilterValue:(BOOL)value_;

//- (BOOL)validateSourceFilter:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *term;

//- (BOOL)validateTerm:(id*)value_ error:(NSError**)error_;




@end

@interface _SBFilter (CoreDataGeneratedAccessors)

@end
