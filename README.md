Purpose
-------

**FMFacebookPanel** is a class that replicates SLComposeViewController native Facebook sharing functionalities introduced in iOS6 and extends their availability in iOS5. Three types of sharing are supported: text, link and photo.
Also it enables "Share attribution" on the content posted on the wall: content shared via the native SLComposeViewController gets an attribution of "via iOS", with **FMFacebookPanel** the content will be associated correctly to your app.

The component UI mimics the original native dialog and is optimized for all rotations and screen sizes.

![Screenshot](http://assets.flubbermedia.com/github/github-fmfacebookpanel-screen.png)

Installation
------------

**FMFacebookPanel** has been recently updated to use the version 3.5 of Facebook SDK. The latest version of the SDK requires two separate steps to grant "read" and "write" permission. However, due to the basic purpose of this component, **FMFacebookPanel** uses deprecated methods that allow to request read and write permissions at the same time.

1. Follow instructions for basic Facebook SDK integration: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/

1. Drag the FMFacebookPanel folder into your Xcode project

2. Add the `<QuartzCore/QuartzCore.h>` framework

3. Download the [SVProgressHUD](https://github.com/samvermette/SVProgressHUD) and add it to the project

4. Add the code below to your AppDelegate.m file:

```objectivec
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}
```

**NOTE: the supported build target is iOS 5.0 (Xcode 4.5)*

Usage
-----
(see sample Xcode project `/Demo`)

Use the shared view controller to set the initial text with an image:

```objectivec
[FMFacebookPanel sharedViewController].postText = @"Image text here";
[FMFacebookPanel sharedViewController].postImage = [UIImage imageNamed:@"Flubber.png"];
[[FMFacebookPanel sharedViewController] present];
```
or a link:

```objectivec
[FMFacebookPanel sharedViewController].postText = @"Link text here";
[FMFacebookPanel sharedViewController].postLink = @"http://flubbermedia.com";
[[FMFacebookPanel sharedViewController] present];
```

Credits
-------
FMFacebookPanel was created by [Maurizio Cremaschi](http://cremaschi.me) and [Andrea Ottolina](http://andreaottolina.com) for [Flubber Media Ltd](http://flubbermedia.com).

This component is currently used by these apps:

- Facebomb: https://itunes.apple.com/app/id523279606
- Stickers: https://itunes.apple.com/app/id527239154
