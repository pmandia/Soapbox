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


#import "SBSoundEffect.h"


@implementation SBSoundEffect

+ (id)soundEffectWithContentsOfFile:(NSString *)thePath 
{
  if (thePath) {
    return [[[SBSoundEffect alloc] initWithContentsOfFile:thePath] autorelease];
  }
  return nil;
}


- (id)initWithContentsOfFile:(NSString *)thePath
{
  if ((self = [super init]))
  {
    NSURL *fileURL = [NSURL fileURLWithPath:thePath isDirectory:NO];
    
    // If the file exists, calls Core Audio to create a system sound ID.
    if (fileURL != nil)  
    {
      SystemSoundID aSoundID;
      OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)fileURL, &aSoundID);
      
      if (error == kAudioServicesNoError) { // success
        soundID = aSoundID;
      } 
      else 
      {
        NSLog(@"Error %d loading sound at path: %@", error, thePath);
        [self release], self = nil;
      }
    } 
    else 
    {
      NSLog(@"NSURL is nil for path: %@", thePath);
      [self release], self = nil;
    }
  }
  
  return self;
}

- (void)play
{
  AudioServicesPlaySystemSound(soundID);
}

- (void)dealloc 
{
  AudioServicesDisposeSystemSoundID(soundID);
  [super dealloc];
}

@end
