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


#define DEFAULT_TINT_COLOR [UIColor colorWithRed:0.443 green:0.467 blue:0.525 alpha:1.000]
#define DEFAULT_TABLE_BG_COLOR [UIColor colorWithRed:0.710 green:0.733 blue:0.757 alpha:1.000]

extern NSString * const kSourceName;
extern NSString * const kBitlyService;
extern NSString * const kLoggedInAccountName;
extern NSString * const kLoggedInAccountDidChange;

extern NSString * const kOAuthConsumerKey;
extern NSString *	const kOAuthConsumerSecret;
extern NSString * kCachedXAuthAccessTokenStringKey;

extern NSString * const kDefaultBitlyUserName;
extern NSString * const kDefaultBitlyApiKey;

// Core Data Entities
extern NSString * const kAccountEntityName;
extern NSString * const kUserEntityName;
extern NSString * const kTweetEntityName;
extern NSString * const kFilterEntityName;

// User Defaults
extern CGFloat const kMaximumTweetLoad;
extern NSString * const kHasLaunchedBefore;
extern NSString * const kAccountListingOrder;
extern NSString * const kUserAccounts;
extern NSString * const kTweetInProgressReplyStatus;
extern NSString * const kTweetInProgressText;
extern NSString * const kTweetInProgressLatitude;
extern NSString * const kTweetInProgressLongitude;
extern NSString * const kTweetInProgressLocationString;

// Setting Bundle
extern NSString * const kDisplayNameFormat;

typedef enum _PTDisplayNameFormatType {
  SBUserNameFormatType = 0,
  PTFullNameFormatType
} PTDisplayFormatType;

// Notifications

extern NSString * const PTSelectedUserFromAddressBook;