Purpose
---

FMFacebookPanel is a class that replicates the Twitter interface in iOS 5.
This lets you easily post text with a link or an image on Facebook without taking care of the Facebook iOS SDK methods and delegates.

<img src="http://assets.flubbermedia.com/github/github-fmfacebookpanel-screen.png" />

Installation
---

1. Drag the FMFacebookPanel files in the project

  <img src="http://assets.flubbermedia.com/github/github-fmfacebookpanel-files.png" />

2. Add the QuartzCore framework

3. Add the SVProgressHUD class

  Download it at <a href="https://github.com/samvermette/SVProgressHUD">https://github.com/samvermette/SVProgressHUD</a> and add it to the project

4. Add the url scheme in the info.plist using fb<YOUR_FACEBOOK_APP_ID>

  <img src="http://assets.flubbermedia.com/github/github-fmfacebookpanel-plist.png" />

5. Setup some code in the AppligationDelegate.m

<pre>
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[FMFacebookPanel sharedViewController] setup:kFacebookAppID];   
    return YES;
}
</pre>

<pre>
- (void)applicationDidBecomeActive:(UIApplication *)application
{    
    [[FMFacebookPanel sharedViewController].facebook extendAccessTokenIfNeeded];
}
</pre>

<pre>
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{    
    return [[FMFacebookPanel sharedViewController].facebook handleOpenURL:url];
}
</pre>

Usage
---

Use the shared view controller to set the initial text with an image or a link

<pre>
[[FMFacebookPanel sharedViewController] setText:text];
[[FMFacebookPanel sharedViewController] setImage:image];
[[FMFacebookPanel sharedViewController] present];
</pre>

Credits
---
FMFacebookPanel was created by <a href="#">Maurizio Cremaschi</a> and <a href="#">Andrea Ottolina</a> for <a href="#">Flubber Media Ltd</a>