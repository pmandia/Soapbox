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


#import "SBImageCache.h"

@implementation SBImageCache

static SBImageCache *sharedImageCache;

+ (SBImageCache *)sharedImageCache
{
  if (!sharedImageCache)
  {
    sharedImageCache = [[SBImageCache alloc] init];
  }
  
  return sharedImageCache;  
}

- (NSString *)imageCacheDirectory 
{
  NSString *appSupportFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
  NSString *path = [NSString stringWithFormat:@"%@/avatars", appSupportFolder];
  
  return path;
}

- (id)init
{
  if ((self = [super init]))
  {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *imageCacheDirectory = [self imageCacheDirectory];
    NSError *error = nil;
    
    cacheFolder = [imageCacheDirectory retain];
    if (![fileManager fileExistsAtPath:imageCacheDirectory isDirectory:NULL]) 
    {
      if (![fileManager createDirectoryAtPath:imageCacheDirectory withIntermediateDirectories:NO attributes:nil error:&error]) 
      {
        NSAssert(NO, ([NSString stringWithFormat:@"Failed to create image cache directory %@ : %@", imageCacheDirectory, error]));
        NSLog(@"Error creating image cache directory at %@ : %@", imageCacheDirectory,error);
        return nil;
      }
    }
  }
  
  return self;
}

- (void)dealloc
{
  [cacheFolder release];
  [super dealloc];
}

- (UIImage *)imageForUserName:(NSString *)userName
{
  NSString *imagePath = [cacheFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", userName]];
  if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) 
  {
    return [[[UIImage alloc] initWithContentsOfFile:imagePath] autorelease];
  }
  
  return nil;
}

- (void)storeImage:(UIImage *)image forUserName:(NSString *)userName
{
  NSString *imagePath = [cacheFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", userName]];  
  NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(image)];
  if(![imageData writeToFile:imagePath atomically:NO]) 
  {
    NSLog(@"Failed to store image: %@", imagePath);
  }  
}

@end
