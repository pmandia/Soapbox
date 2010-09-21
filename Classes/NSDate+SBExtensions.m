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


#import "NSDate+SBExtensions.h"

NSDate* ConvertIntervalToDate(NSNumber *number)
{
  NSNumber *createdAt = number;
  NSTimeInterval createdAtTimeInterval = [createdAt integerValue];
  NSDate *joinDate = [NSDate dateWithTimeIntervalSince1970:createdAtTimeInterval];
  
  return joinDate;
}

NSDate* ConvertStringToDate(NSString *date)
{
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"EEE LLL dd HH:mm:ss Z yyyy"];    
  
  NSDate *parsedDate = [formatter dateFromString:date];
  [formatter release];
  return parsedDate;
}

NSString* FormatNSDate(NSDate *date)
{
  if (date == nil) return @"";
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"EEE LLL dd HH:mm:ss Z yyyy"];    
  NSString *dateString = [NSDate dateDifferenceStringFromString:[formatter stringFromDate:date] withFormat:@"EEE LLL dd HH:mm:ss Z yyyy"];   
  [formatter release];
  return dateString;
}

@implementation NSDate (SBExtensions)

+ (NSString *)dateDifferenceStringFromString:(NSString *)dateString
                                  withFormat:(NSString *)dateFormat
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
  [dateFormatter setDateFormat:dateFormat];
  NSDate *date = [dateFormatter dateFromString:dateString];
  [dateFormatter release];
  NSDate *now = [NSDate date];
  double time = [date timeIntervalSinceDate:now];
  time *= -1;
  if(time < 1) {
    return dateString;
  } else if (time < 60) {
    return @"< 1 minute";
  } else if (time < 3600) {
    int diff = round(time / 60);
    if (diff == 1) 
      return [NSString stringWithFormat:@"1 minute", diff];
    return [NSString stringWithFormat:@"%d minutes", diff];
  } else if (time < 86400) {
    int diff = round(time / 60 / 60);
    if (diff == 1)
      return [NSString stringWithFormat:@"1 hour", diff];
    return [NSString stringWithFormat:@"%d hours", diff];
  } else if (time < 604800) {
    int diff = round(time / 60 / 60 / 24);
    if (diff == 1) 
      return [NSString stringWithFormat:@"yesterday", diff];
    if (diff == 7) 
      return [NSString stringWithFormat:@"last week", diff];
    return[NSString stringWithFormat:@"%d days", diff];
  } else {
    int diff = round(time / 60 / 60 / 24 / 7);
    if (diff == 1)
      return [NSString stringWithFormat:@"last week", diff];
    return [NSString stringWithFormat:@"%d weeks", diff];
  }   
}

@end
