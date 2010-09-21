# Soapbox

## What Is This?

This is Soapbox, yet another Twitter client for iOS.  

After the demise of Buzz Andersen's excellent Birdfeed client, I started toiling away on my own Twitter client to meet my unique needs: mainly I need a client that filters tweets.  I also wanted a client that didn't look like yet another clone of Tweetie with a tab-bar along the bottom and plain table cells for tweet display.

When Loren Brichter sold Tweetie to Twitter, I stopped working on Soapbox full-time as I lost confidence in productizing it under the Second Gear umbrella.  This is now my project car that I tinker with in the garage on nights and weekends.

**What Works**

* Home timeline
* Mentions timeline
* Timeline filtering by word (Bieber) or source (Foursquare, Gowalla)
* Posting + Geolocation + Link shortening
* Multiple accounts
* In-app browser

**TODO**

* Multitasking support
* UI graphics need to be updated for retina display
* Single tweet view
* Direct messages
* Search
* User profiles
* Photo uploading
* Kitchen sink
* Everything else

**Building**

Soapbox should build so long as you are running the iOS 4.1 SDK.  

You will need to input your own OAuth keys for Twitter and Bit.ly in the `SBConstants.m` file.  Just look for where it says "CHANGEME"

**Contributing**

If you are interested in helping out, fork away.