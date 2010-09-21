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

#import "SBBitlyHelper.h"
#import <CFNetwork/CFNetwork.h>
#import "NSObject+YAJL.h"

static NSString *kBitlyApiURL = @"api.bit.ly";
static NSString *kBitlyApiFormat = @"json";
static NSString *kBitlyApiMethod = @"shorten";

@interface SBBitlyHelper ()
- (NSString *)encodeString:(NSString *)string;
- (void)handleError:(NSError *)error;
@end

@implementation SBBitlyHelper

@synthesize userName;
@synthesize apiKey;
@synthesize connection;
@synthesize responseData;
@synthesize delegate;

- (SBBitlyHelper *)initWithUserName:(NSString *)theUserName apiKey:(NSString *)theApiKey
{
  if ((self = [super init]))
  {
    self.userName = theUserName;
    self.apiKey = theApiKey;
  }
  
  return self;
}

- (void)dealloc
{
  [userName release]; self.userName = nil;
  [apiKey release]; self.apiKey = nil;
  [connection release]; self.connection = nil;
  [responseData release]; self.responseData = nil;
  [super dealloc];
}

- (void)shortenURL:(NSString *)theLongURL
{
  NSString *URLString = [NSString stringWithFormat:@"http://%@/%@?version=2.0.1&longUrl=%@&login=%@&apiKey=%@&format=%@&", 
                         kBitlyApiURL, kBitlyApiMethod, [self encodeString:theLongURL],
                         self.userName, self.apiKey, kBitlyApiFormat];

  NSURL *requestURL = [NSURL URLWithString:URLString];
  NSURLRequest *request = [[NSURLRequest alloc] initWithURL:requestURL];
  
  self.connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
  NSAssert(self.connection != nil, @"Failure to create URL connection.");
#if TARGET_OS_IPHONE == 1
  [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
#endif
  [request release];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response 
{
  self.responseData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)theData 
{
  [responseData appendData:theData];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
#if TARGET_OS_IPHONE == 1
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
#endif
  
  if ([error code] == kCFURLErrorNotConnectedToInternet) 
  {
    // if we can identify the error, we can present a more precise message to the user.
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:NSLocalizedString(@"No Connection Error", nil) forKey:NSLocalizedDescriptionKey];
    NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:userInfo];
    [self handleError:noConnectionError];
  } 
  else 
  {
    [self handleError:error];
  }
  
  self.connection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection 
{
  self.connection = nil;
#if TARGET_OS_IPHONE == 1
  [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
#endif

  NSDictionary *responseDictionary = [self.responseData yajl_JSON];
  NSDictionary *results = [responseDictionary objectForKey:@"results"];
  
  if (!results)
  {
    NSError *error = [[[NSError alloc] initWithDomain:@"SoapboxErrorDomain" code:-1 userInfo:responseDictionary] autorelease];
    [delegate shorteningFailedWithError:error];
  }
  else 
  {
    NSString *key = [[results allKeys] firstObject];
    NSString *shortURL = [[results objectForKey:key] objectForKey:@"shortUrl"];
    
    if ((shortURL != nil)) 
    {
      [delegate shorteningSucceededForURL:key withShortenedURL:shortURL];
    }    
  }
  
  self.responseData = nil;
}

#pragma mark -
#pragma mark Class Extension Methods
// +--------------------------------------------------------------------
// | Class Extension Methods
// +--------------------------------------------------------------------

- (void)handleError:(NSError *)theError 
{
  NSString *errorMessage = [theError localizedDescription];
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
  [alertView show];
  [alertView release];
}

- (NSString *)encodeString:(NSString *)string
{
  NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, 
                                                                         (CFStringRef)string, 
                                                                         NULL, 
                                                                         (CFStringRef)@";/?:@&=$+{}<>,",
                                                                         kCFStringEncodingUTF8);
  return [result autorelease];
}

@end
