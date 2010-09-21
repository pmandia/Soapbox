// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to SBFilter.m instead.

#import "_SBFilter.h"

@implementation SBFilterID
@end

@implementation _SBFilter

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Filter" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Filter";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Filter" inManagedObjectContext:moc_];
}

- (SBFilterID*)objectID {
	return (SBFilterID*)[super objectID];
}




@dynamic sourceFilter;



- (BOOL)sourceFilterValue {
	NSNumber *result = [self sourceFilter];
	return result ? [result boolValue] : 0;
}

- (void)setSourceFilterValue:(BOOL)value_ {
	[self setSourceFilter:[NSNumber numberWithBool:value_]];
}






@dynamic term;








@end
