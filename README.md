Purpose
-------

**FMFacebookPanel** is a class that replicates the Twitter interface in iOS 5.
This lets you easily post text with a link or an image on Facebook without taking care of the Facebook iOS SDK methods and delegates.

![Screenshot](http://assets.flubbermedia.com/github/github-fmfacebookpanel-screen.png)

**NOTE: the supported build target is iOS 5.1 (Xcode 4.4)*

Installation
------------

1. Drag the FMFacebookPanel files in the project

  ![Files](http://assets.flubbermedia.com/github/github-fmfacebookpanel-files.png)

2. Add the `<QuartzCore/QuartzCore.h>` framework

3. Download the [SVProgressHUD](https://github.com/samvermette/SVProgressHUD) and add it to the project

4. Add the url scheme in the info.plist using fb<YOUR_FACEBOOK_APP_ID>

  ![Plist](http://assets.flubbermedia.com/github/github-fmfacebookpanel-plist.png)

Setup
-----

1. Setup the sharedViewController with your Facebook App ID

	```objectivec
	- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
    	[[FMFacebookPanel sharedViewController] setup:kFacebookAppID];
    	return YES;
	}
	```

2. Let the Facebook property handle the url in the `application:handleOpenURL:`

	```objectivec
	- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
	{    
    	return [[FMFacebookPanel sharedViewController].facebook handleOpenURL:url];
	}
	```

Usage
-----
(see sample Xcode project `/Demo`)

Use the shared view controller to set the initial text with an image or a link

```objectivec
[[FMFacebookPanel sharedViewController] setText:text];
[[FMFacebookPanel sharedViewController] setImage:image];
[[FMFacebookPanel sharedViewController] present];
```

Credits
-------
FMFacebookPanel was created by [Maurizio Cremaschi](http://cremaschi.me) and [Andrea Ottolina](http://andreaottolina.com) for [Flubber Media Ltd](http://flubbermedia.com).