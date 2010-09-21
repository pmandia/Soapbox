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


#import "SBAvatarDownloader.h"
#import "SBUser.h"

#define kAvatarIconHeight 48

@implementation SBAvatarDownloader

@synthesize user;
@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;

#pragma mark -
#pragma mark Memory Management
// +--------------------------------------------------------------------
// | Memory Management
// +--------------------------------------------------------------------

- (void)dealloc
{
  [user release];
  [indexPathInTableView release];
  
  [activeDownload release];
  
  [imageConnection cancel];
  [imageConnection release];
  
  [super dealloc];  
}

#pragma mark -
#pragma mark Instance Methods
// +--------------------------------------------------------------------
// | Instance Methods
// +--------------------------------------------------------------------

- (void)startDownload
{
  self.activeDownload = [NSMutableData data];
  // alloc+init and start an NSURLConnection; release on completion/failure
  NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                           [NSURLRequest requestWithURL:
                            [NSURL URLWithString:user.avatarURL]] delegate:self];
  self.imageConnection = conn;
  [conn release];
}

- (void)cancelDownload
{
  [self.imageConnection cancel];
  self.imageConnection = nil;
  self.activeDownload = nil;
}

#pragma mark -
#pragma mark NSURLConnectionDelegate Methods
// +--------------------------------------------------------------------
// | NSURLConnectionDelegate Methods
// +--------------------------------------------------------------------

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
  self.activeDownload = nil;
  
  // Release the connection now that it's finished
  self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  // Set appIcon and clear temporary data/image
  UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];

  self.user.avatar = image;
  
  self.activeDownload = nil;
  [image release];
  
  // Release the connection now that it's finished
  self.imageConnection = nil;
  
  // call our delegate and tell it that our icon is ready for display
  [delegate avatarDidLoad:self.indexPathInTableView];
}

@end
