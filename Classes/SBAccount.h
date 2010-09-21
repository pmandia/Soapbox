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

#import <Foundation/Foundation.h>

typedef enum _SBAccountLocationPostingType 
{
  SBAccountLocationOff     = 0,
  SBAccountLocationManual  = 1,
  SBAccountLocationAuto    = 2
} SBAccountLocationPostingType;


@interface SBAccount : NSObject
{
@private
  NSNumber *twitterID;
  NSString *fullName;
  NSString *screenName;
  NSString *secret;       // OAuth secret
  NSString *key;          // OAuth key
  
  NSString *bitlyUserName;
  NSString *bitlyApiKey;
  
  NSNumber *homeTimelineLastDownloadTweetID;
  NSString *homeTimelineScrollViewLastContentOffset;
  
  NSNumber *mentionsTimelineLastDownloadTweetID;
  NSString *mentionsTimelineScrollViewLastContentOffset;
  
  SBAccountLocationPostingType locationPostingPreference;
  
  BOOL enabledGeoPosting;
  BOOL isProtected;
}

@property (nonatomic, retain) NSNumber *twitterID;
@property (nonatomic, copy) NSString *fullName;
@property (nonatomic, copy) NSString *screenName;
@property (nonatomic, copy) NSString *secret;
@property (nonatomic, copy) NSString *key;

@property (nonatomic, copy) NSString *bitlyUserName;
@property (nonatomic, copy) NSString *bitlyApiKey;

@property (nonatomic, retain) NSNumber *homeTimelineLastDownloadTweetID;
@property (nonatomic, copy) NSString *homeTimelineScrollViewLastContentOffset;

@property (nonatomic, retain) NSNumber *mentionsTimelineLastDownloadTweetID;
@property (nonatomic, copy) NSString *mentionsTimelineScrollViewLastContentOffset;

@property (assign) SBAccountLocationPostingType locationPostingPreference;
@property (assign) BOOL enabledGeoPosting;
@property (assign) BOOL isProtected;

- (id)initWithUserName:(NSString *)theUserName;
- (id)initWithUserDictionary:(NSDictionary *)theDictionary;

- (NSMutableDictionary *)serializeAsDictionary;
- (NSString *)locationPostingPreferenceTitle;

@end
