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


#import "SBTweetView.h"
#import "SBTweet.h"

#define DEFAULT_CELL_HEIGHT 75

#define AVATAR_OFFSET 10
#define AVATAR_WIDTH 46
#define AVATAR_VERTICAL_PADDING 4.0f

#define USERNAME_WIDTH 120

#define DATE_WIDTH 85
#define DATE_OFFSET 10.0f

#define TWEET_TEXT_OFFSET 67.0f
#define TWEET_TEXT_WIDTH 230
#define TWEET_TEXT_VERTICAL_PADDING 35.0f

#define PROTECTED_LOCK_PADDING 25.0f
#define RT_ICON_PLUS_PADDING 18.0

#define BG_VIEW_TOP 10.0  
#define UPPER_ROW_TOP 10.0
#define TOP_ROW_PADDING 5.0f
#define MIDDLE_ROW_TOP 35
#define LOWER_ROW_TOP 87  
#define BG_VIEW_BOTTOM 15.0    

#define NON_TWEET_TEXT_HEIGHT 50.0f
#define NON_TWEET_TEXT_HEIGHT_RETWEET 74.0f
#define MAX_HEIGHT 9999

static CGFloat kUserNameFontSize = 14.0f;
static CGFloat kRelativeDateFontSize = 14.0f;
static CGFloat kTweetTextFontSize = 14.0f;
static CGFloat kRetweetTextFontSize = 13.0f;


@implementation SBTweetView

@synthesize backgroundView;
@synthesize avatarImageView;
@synthesize userName;
@synthesize relativeDate;
@synthesize tweetText;
@synthesize retweetBarView;
@synthesize retweetImageView;
@synthesize retweetedByUserName;
@synthesize favoritedImageView;
@synthesize protectedImageView;
@synthesize userNameFormatPreference;
@synthesize highlighted;
@synthesize editing;
@synthesize fadeAvatar;
@synthesize tweet;

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) 
    {
      self.opaque = YES;
      self.backgroundColor = [[UIColor colorWithRed:0.710 green:0.733 blue:0.757 alpha:1.000] retain];
      self.avatarImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] retain];
      self.avatarImageView.image = [UIImage imageNamed:@"avatar-blank.png"];
      
      self.favoritedImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] retain];
      self.favoritedImageView.image = [UIImage imageNamed:@"star.png"];
      
      self.protectedImageView = [[[UIImageView alloc] initWithFrame:CGRectZero] retain];
      self.protectedImageView.image = [UIImage imageNamed:@"lock.png"];
      self.userNameFormatPreference = [[NSUserDefaults standardUserDefaults] integerForKey:kDisplayNameFormat];
    }
    return self;
}

- (void)dealloc
{
  [backgroundView release];
  [avatarImageView release];
  [userName release];
  [relativeDate release];
  [tweetText release];
  [retweetBarView release];
  [retweetImageView release];
  [retweetedByUserName release];
  [favoritedImageView release];
  [protectedImageView release];
  [tweet release];
  
  [super dealloc];
}

- (CGSize)tweetTextSize
{
  UIFont *tweetTextFont = [UIFont systemFontOfSize:kTweetTextFontSize];
  return [self.tweetText sizeWithFont:tweetTextFont constrainedToSize:CGSizeMake(TWEET_TEXT_WIDTH, MAX_HEIGHT) lineBreakMode:UILineBreakModeWordWrap];
}

- (CGRect)wrapperRectForBounds:(CGRect)theBounds
{
  CGSize tweetTextSize = [self tweetTextSize];
  CGFloat nonTweetTextHeight = ((self.tweet.tweetTypeValue == PTTweetTypeRetweet)) ? NON_TWEET_TEXT_HEIGHT_RETWEET : NON_TWEET_TEXT_HEIGHT;
  
  CGFloat backgroundViewHeight = MAX(tweetTextSize.height + nonTweetTextHeight, DEFAULT_CELL_HEIGHT);
  CGRect wrapperRect = CGRectMake(0.0f, BG_VIEW_TOP, theBounds.size.width - AVATAR_OFFSET, backgroundViewHeight - BG_VIEW_BOTTOM);
  wrapperRect.size.height += 5.0f;
  wrapperRect.origin.y = floor(0.5 * (self.frame.size.height - wrapperRect.size.height));

  return wrapperRect;
}

- (CGRect)tweetTextRectForBounds:(CGRect)theBounds
{
  CGRect wrapperRect = [self wrapperRectForBounds:self.bounds];
  CGFloat boundsX = wrapperRect.origin.x;
  CGSize tweetSize = [self tweetTextSize];
  
  CGRect tweetRect = CGRectMake(boundsX + TWEET_TEXT_OFFSET, TWEET_TEXT_VERTICAL_PADDING, tweetSize.width, tweetSize.height);
  if ((self.tweet.tweetTypeValue == SBTweetTypePersonal)) // Flip the avatar to the right side.
  {
    tweetRect.origin.x = CGRectGetMinX(wrapperRect) + AVATAR_OFFSET;
  }
  
  return tweetRect;
}

- (CGRect)retweetBarRectForBounds:(CGRect)theBounds
{
  CGRect wrapperRect = [self wrapperRectForBounds:self.bounds];
  CGRect retweetRect = CGRectMake(wrapperRect.origin.x, self.bounds.size.height - 30.0f, self.bounds.size.width - AVATAR_OFFSET, 24.0f);
  
  return retweetRect;
}

- (CGRect)dateRectForBounds:(CGRect)theBounds
{
  UIFont *relativeDateFont = [UIFont systemFontOfSize:kRelativeDateFontSize];
  CGFloat actualFontSize;
  
  CGRect wrapperRect = [self wrapperRectForBounds:self.bounds];  
  CGFloat maxX = CGRectGetMaxX(wrapperRect);
  
  CGSize dateSize = [self.relativeDate sizeWithFont:relativeDateFont minFontSize:kRelativeDateFontSize actualFontSize:&actualFontSize forWidth:DATE_WIDTH lineBreakMode:UILineBreakModeTailTruncation];
  
  CGPoint point = CGPointMake(maxX - dateSize.width - DATE_OFFSET, wrapperRect.origin.y + TOP_ROW_PADDING);
  
  CGRect dateRect = CGRectMake(point.x, point.y, dateSize.width, dateSize.height);
  if ((self.tweet.tweetTypeValue == SBTweetTypePersonal)) // Flip the avatar to the right side.
  {
    dateRect.origin.x = CGRectGetMaxX(wrapperRect) - dateSize.width - DATE_OFFSET - AVATAR_WIDTH - AVATAR_OFFSET;
  }

  return dateRect;
}

- (UIColor *)colorForWrapperOfTweetType:(SBTweetType)theType
{
  UIColor *wrapperColor = nil;

  switch (theType)
  {
    case SBTweetTypeMention:
      wrapperColor = (!(self.highlighted)) ? [UIColor colorWithRed:0.631 green:0.816 blue:1.000 alpha:1.000] : [UIColor colorWithRed:0.502 green:0.753 blue:1.000 alpha:1.000];
      break;
    case SBTweetTypePersonal:
      wrapperColor = (!(self.highlighted)) ? [UIColor colorWithRed:0.804 green:1.000 blue:0.498 alpha:1.000] : [UIColor colorWithRed:0.725 green:1.000 blue:0.278 alpha:1.000];
      break;
    default:
      wrapperColor = (!(self.highlighted)) ? [UIColor colorWithWhite:1.000 alpha:1.000] : [UIColor colorWithRed:0.898 green:0.949 blue:1.000 alpha:1.000];
      break;
  }
  
  return wrapperColor;
}

- (void)drawBackgroundWrapper
{    
  UIColor *wrapperViewColor = [self colorForWrapperOfTweetType:self.tweet.tweetTypeValue];
  CGRect wrapperRect = [self wrapperRectForBounds:self.bounds];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  // jw: for some reason any shadows created on 4.0 in an image context appear flipped vertically. 
  // Inverted it for now, but also filed a radar since it seems like a regression. radar://7960946
  CGContextSetShadowWithColor(context, CGSizeMake(0.5f, 1.0f), 1.0f, [[UIColor blackColor] colorWithAlphaComponent:0.75].CGColor);
  CGContextSetFillColorWithColor(context, wrapperViewColor.CGColor);
  CGContextFillRect(context, wrapperRect);
  CGContextRestoreGState(context);
}

- (void)drawUserName
{
  UIColor *userNameColor = (!(self.highlighted)) ? [UIColor blackColor] : [UIColor blackColor];
  UIFont *userNameFont = [UIFont boldSystemFontOfSize:kUserNameFontSize];
  CGFloat actualFontSize;

  CGRect wrapperRect = [self wrapperRectForBounds:self.bounds];
  CGFloat boundsX = wrapperRect.origin.x;
  
  [userNameColor set];
  [self.userName sizeWithFont:userNameFont minFontSize:kUserNameFontSize actualFontSize:&actualFontSize forWidth:USERNAME_WIDTH lineBreakMode:UILineBreakModeTailTruncation];
  CGPoint point = CGPointMake(boundsX + TWEET_TEXT_OFFSET, wrapperRect.origin.y + TOP_ROW_PADDING);
  if ((self.tweet.tweetTypeValue == SBTweetTypePersonal)) // Flip the avatar to the right side.
  {
    point.x = CGRectGetMinX(wrapperRect) + AVATAR_OFFSET;
  }
  
  [self.userName drawAtPoint:point forWidth:USERNAME_WIDTH withFont:userNameFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
  
}

- (void)drawRelativeDate
{
  UIColor *relativeDateColor = (!(self.highlighted)) ? [UIColor colorWithWhite:0.529 alpha:1.000] : [UIColor colorWithWhite:0.529 alpha:1.000];
  UIFont *relativeDateFont = [UIFont systemFontOfSize:kRelativeDateFontSize];

  [relativeDateColor set];

  CGRect dateRect = [self dateRectForBounds:self.bounds];
  [self.relativeDate drawInRect:dateRect withFont:relativeDateFont lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];  
}

- (void)drawTweetText
{
  UIColor *tweetTextColor = (!(self.highlighted)) ? [UIColor blackColor] : [UIColor blackColor];;
  UIFont *tweetTextFont = [UIFont systemFontOfSize:kTweetTextFontSize];
  
  CGRect wrapperRect = [self wrapperRectForBounds:self.bounds];
  [tweetTextColor set];
  
  CGRect tweetRect = [self tweetTextRectForBounds:wrapperRect];
  [self.tweetText drawInRect:tweetRect withFont:tweetTextFont lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];  
}

- (void)drawAvatar
{
  CGRect wrapperRect = [self wrapperRectForBounds:self.bounds];
  CGFloat boundsX = wrapperRect.origin.x;
  
  CGRect avatarRect = CGRectMake(boundsX + AVATAR_OFFSET, wrapperRect.origin.y + TOP_ROW_PADDING + AVATAR_VERTICAL_PADDING, AVATAR_WIDTH, AVATAR_WIDTH);    
  if ((self.tweet.tweetTypeValue == SBTweetTypePersonal)) // Flip the avatar to the right side.
  {
    avatarRect.origin.x = CGRectGetMaxX(wrapperRect) - AVATAR_WIDTH - AVATAR_OFFSET;
  }
  
  self.avatarImageView.frame = avatarRect;
  self.avatarImageView.alpha = 0.0f;
  [self addSubview:self.avatarImageView];
  
  if ((self.fadeAvatar == YES))
  {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self cache:YES];
    [UIView setAnimationDelegate:self]; 
    [UIView setAnimationDidStopSelector:@selector(avatarAnimationDone:finished:context:)];
  }
  self.avatarImageView.alpha = 1.0f;
  [UIView commitAnimations];  
}

- (void)avatarAnimationDone:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
  self.fadeAvatar = NO;
}

- (void)drawFavoriteStar
{
  CGRect wrapperRect = [self wrapperRectForBounds:self.bounds];    
  CGFloat maxX = CGRectGetMaxX(wrapperRect);
  CGFloat maxY = CGRectGetMaxY(wrapperRect);
  
#define FAVSTAR_VERTICAL_PADDING 18.0f
  
  CGRect starRect = CGRectMake(maxX - (AVATAR_OFFSET * 2), maxY - FAVSTAR_VERTICAL_PADDING, 11.0f, 10.0f);    
  self.favoritedImageView.frame = starRect;
  self.favoritedImageView.hidden = NO;
  [self addSubview:self.favoritedImageView];  
}

- (void)drawProtectedLock
{
  CGRect wrapperRect = [self wrapperRectForBounds:self.bounds];  
  CGFloat maxX = CGRectGetMaxX(wrapperRect);  
  CGRect dateRect = [self dateRectForBounds:wrapperRect];
  
  CGRect lockRect = CGRectMake(maxX - dateRect.size.width - PROTECTED_LOCK_PADDING, wrapperRect.origin.y + TOP_ROW_PADDING + AVATAR_VERTICAL_PADDING, 8.0f, 10.0f);    
  if ((self.tweet.tweetTypeValue == SBTweetTypePersonal)) // Flip the avatar to the right side.
  {
    lockRect.origin.x = CGRectGetMaxX(lockRect) - DATE_OFFSET - AVATAR_WIDTH - AVATAR_OFFSET;
  }
  
  self.protectedImageView.frame = lockRect;
  self.protectedImageView.hidden = NO;
  [self addSubview:self.protectedImageView];
}

- (void)drawRetweetBar
{
  UIColor *retweetedTextColor = nil;
  UIFont *retweetedTextFont = [UIFont boldSystemFontOfSize:kRetweetTextFontSize];
  CGFloat actualFontSize;

  if ((self.highlighted))
  {
    retweetedTextColor = [UIColor blackColor]; 
  }
  else 
  {
    retweetedTextColor = [UIColor blackColor];
  }
  
  CGRect retweetBarRect = [self retweetBarRectForBounds:self.bounds];
  
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSaveGState(context);
  UIColor *retweetColor = (!(self.highlighted)) ? [UIColor colorWithRed:0.898 green:0.949 blue:1.000 alpha:1.000] : [UIColor colorWithRed:0.800 green:0.902 blue:1.000 alpha:1.000];
  CGContextSetFillColorWithColor(context, retweetColor.CGColor);
  CGContextFillRect(context, retweetBarRect);
  CGContextRestoreGState(context);
  CGFloat boundsX = retweetBarRect.origin.x;
  
  // Draw Retweet Icon
  UIImage *image = [UIImage imageNamed:@"retweet.png"];
  CGPoint imagePoint = CGPointMake(boundsX + TWEET_TEXT_OFFSET, retweetBarRect.origin.y + TOP_ROW_PADDING + AVATAR_VERTICAL_PADDING);
  [image drawAtPoint:imagePoint];
  
  // Draw Retweet String  
  NSString *retweetString = [NSString stringWithFormat:@"Retweeted by %@", self.retweetedByUserName];
  [retweetedTextColor set];
  [retweetString sizeWithFont:retweetedTextFont minFontSize:kRetweetTextFontSize actualFontSize:&actualFontSize forWidth:TWEET_TEXT_WIDTH lineBreakMode:UILineBreakModeTailTruncation];
  
  CGPoint stringPoint = CGPointMake(boundsX + TWEET_TEXT_OFFSET + RT_ICON_PLUS_PADDING, retweetBarRect.origin.y + TOP_ROW_PADDING);
  [retweetString drawAtPoint:stringPoint forWidth:TWEET_TEXT_WIDTH withFont:retweetedTextFont minFontSize:actualFontSize actualFontSize:&actualFontSize lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];
}

#pragma mark -
#pragma mark drawRect:
// +--------------------------------------------------------------------
// | drawRect:
// +--------------------------------------------------------------------


- (void)drawRect:(CGRect)rect 
{
  [self drawBackgroundWrapper];
  [self drawUserName];
  [self drawRelativeDate];
  [self drawTweetText];
  [self drawAvatar];
  
  if (([self.tweet.user.protected boolValue]))    
  {
    [self drawProtectedLock];    
  }
  
  if (([self.tweet.favorited boolValue]))    
  {
    [self drawFavoriteStar];
  }
 
  if ((self.tweet.tweetTypeValue == PTTweetTypeRetweet))
  {
    [self drawRetweetBar];  
  }
}

- (void)setNeedsDisplay
{
  [super setNeedsDisplay];

  UIImage *avatar = [self.tweet.user avatar];
  
  if (avatar != nil)  
  {
    self.avatarImageView.image = avatar;
  }
}

- (void)setHighlighted:(BOOL)isHighlighted 
{
	// If highlighted state changes, need to redisplay.
	if (highlighted != isHighlighted) {
		highlighted = isHighlighted;	
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Custom Accessor Methods
// +--------------------------------------------------------------------
// | Custom Accessor Methods
// +--------------------------------------------------------------------

- (void)setTweet:(SBTweet *)newTweet 
{
	if (tweet != newTweet) 
  {
		[tweet release];
		tweet = [newTweet retain];
		
    SBUser *user = tweet.user;
    
    NSString *theUserName = [[NSString alloc] initWithString:((userNameFormatPreference == SBUserNameFormatType)) ? user.screenName : user.name];    
    self.userName = theUserName;
    [theUserName release];
    
    UIImage *avatar = [user avatar];
    
    if (avatar != nil)
    {
      self.avatarImageView.image = avatar;
    }
    else 
    {
      self.avatarImageView.image = [UIImage imageNamed:@"avatar-blank.png"];
    }

    
    self.relativeDate = FormatNSDate(tweet.creationDate);
    
		self.tweetText = tweet.text;
    self.retweetedByUserName = tweet.retweetedByScreenName;
    
    BOOL isFavorited = [tweet.favorited boolValue];
    self.favoritedImageView.hidden = !isFavorited;
      
    BOOL isProtectedUser = [tweet.user.protected boolValue];
    self.protectedImageView.hidden = !isProtectedUser;
	}
  
	[self setNeedsDisplay];
}

@end
