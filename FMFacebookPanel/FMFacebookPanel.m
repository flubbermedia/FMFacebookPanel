//
//  FMFacebookPanel.m
//
//  Created by Maurizio Cremaschi and Andrea Ottolina on 1/16/12.
//  Copyright 2012 Flubber Media Ltd.
//
//  Distributed under the permissive zlib License
//  Get the latest version from https://github.com/flubbermedia/FMFacebookPanel
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "FMFacebookPanel.h"
#import "SVProgressHUD.h"
#import "LineTextView.h"
#import <QuartzCore/QuartzCore.h>

@interface FMFacebookPanel ()

@property (strong) FBRequest *userInfoRequest;
@property (strong) FBRequest *postRequest;

@end

@implementation FMFacebookPanel

@synthesize userInfoRequest;
@synthesize postRequest;
@synthesize facebook;
@synthesize image;
@synthesize text;
@synthesize link;
@synthesize backgroundImageView;
@synthesize containerView;
@synthesize textView;
@synthesize imageView;
@synthesize clipImageView;
@synthesize chromeImageView;
@synthesize nameTitleLabel;
@synthesize nameLabel;
@synthesize sendButton;
@synthesize cancelButton;
@synthesize logoutButton;

+ (FMFacebookPanel *)sharedViewController
{
    static FMFacebookPanel *sharedViewController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedViewController = [FMFacebookPanel new];
    });
    return sharedViewController;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    self.nameLabel.text = @"";
    
	self.imageView.backgroundColor = [UIColor darkGrayColor];
	self.imageView.layer.cornerRadius = 4.;
	
	CGRect chromeImageRect = CGRectInset(self.imageView.frame, -6., -4.);
	chromeImageRect = CGRectApplyAffineTransform(chromeImageRect, CGAffineTransformMakeTranslation(0., 2.));
	self.chromeImageView = [[UIImageView alloc] initWithFrame:chromeImageRect];
	self.chromeImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	self.chromeImageView.image = [[UIImage imageNamed:@"FBSheetImageBorderSquare.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(39., 41., 39., 42.)];	
	[self.containerView insertSubview:self.chromeImageView aboveSubview:self.imageView];
        
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:17.];
    self.textView.textColor = [UIColor blackColor];
	self.textView.contentInset = UIEdgeInsetsMake(8., 0., 0., 0.);
    self.textView.lineColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
    self.textView.lineWidth = 1.;
    self.textView.linesShouldFollowSuperview = YES;

	self.backgroundImageView.alpha = 0.;

	// Background
	self.containerView.layer.cornerRadius = 10.;
	self.containerView.layer.backgroundColor = [UIColor whiteColor].CGColor;

	UIView *paperView = [[UIView alloc] initWithFrame:self.containerView.bounds];
	paperView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	paperView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"FBSheetPaperTexture.png"]];
	
	[self.containerView insertSubview:paperView atIndex:0];
	
	UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FBSheetBottomShadow.png"]];
	gradientImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	gradientImageView.frame = self.containerView.bounds;
	
	[self.containerView insertSubview:gradientImageView aboveSubview:paperView];

	UIView *dividerRedView = [[UIView alloc] initWithFrame:CGRectMake(0., 40., self.containerView.frame.size.width, 3.)];
	dividerRedView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	dividerRedView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"FBSheetRedPerf.png"]];
	
	[self.containerView insertSubview:dividerRedView aboveSubview:gradientImageView];
	
	UIView *dividerGrayView = [[UIView alloc] initWithFrame:CGRectMake(0., 73., self.containerView.frame.size.width, 3.)];
	dividerGrayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	dividerGrayView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"FBSheetGrayPerf.png"]];
	
	[self.containerView insertSubview:dividerGrayView aboveSubview:gradientImageView];

	CGRect chromeRect = CGRectInset(self.containerView.bounds, -13., -34.);
	chromeRect = CGRectApplyAffineTransform(chromeRect, CGAffineTransformMakeTranslation(0., -1.));
	UIImageView *chromeView = [[UIImageView alloc] initWithFrame:chromeRect];
	chromeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	chromeView.image = [[UIImage imageNamed:@"FBSheetPaperChrome.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(64., 34., 64., 34.)];

	[self.containerView insertSubview:chromeView aboveSubview:gradientImageView];
	
	self.containerView.transform = CGAffineTransformMakeTranslation(0., -(self.containerView.center.y + CGRectGetHeight(self.containerView.frame)));
	
	// Buttons
	UIImage *cancelButtonImage = [[UIImage imageNamed:@"FBSheetCancelButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0., 5., 0., 5.)];
	UIImage *cancelButtonPressedImage = [[UIImage imageNamed:@"FBSheetCancelButtonPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0., 5., 0., 5.)];
	[self.cancelButton setBackgroundImage:cancelButtonImage forState:UIControlStateNormal];
	[self.cancelButton setBackgroundImage:cancelButtonPressedImage forState:UIControlStateHighlighted];

	UIImage *sendButtonImage = [[UIImage imageNamed:@"FBSheetSendButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0., 5., 0., 5.)];
	UIImage *sendButtonPressedImage = [[UIImage imageNamed:@"FBSheetSendButtonPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0., 5., 0., 5.)];
	[self.sendButton setBackgroundImage:sendButtonImage forState:UIControlStateNormal];
	[self.sendButton setBackgroundImage:sendButtonPressedImage forState:UIControlStateHighlighted];

	UIImage *logoutButtonImage = [[UIImage imageNamed:@"FBSheetCancelButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0., 5., 0., 5.)];
	UIImage *logoutButtonPressedImage = [[UIImage imageNamed:@"FBSheetCancelButtonPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0., 5., 0., 5.)];
	[self.logoutButton setBackgroundImage:logoutButtonImage forState:UIControlStateNormal];
	[self.logoutButton setBackgroundImage:logoutButtonPressedImage forState:UIControlStateHighlighted];
    
    if (![[UIApplication sharedApplication] isStatusBarHidden])
    {
        if ([UIApplication sharedApplication].keyWindow.rootViewController.wantsFullScreenLayout)
        {
            self.containerView.center = CGPointMake(containerView.center.x, containerView.center.y+10.);
        }
        else
        {
            self.containerView.center = CGPointMake(containerView.center.x, containerView.center.y-10.);
        }
    }
    
    [self showImageView:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.containerView = nil;
    self.textView = nil;
    self.imageView = nil;
    self.sendButton = nil;
    self.nameLabel = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"facebook.name"];
    
    if (![self.facebook isSessionValid])
    {
        NSArray * permissions = [[NSArray alloc] initWithObjects:@"publish_stream", @"offline_access", nil];
        [self.facebook authorize:permissions];
    } 
    else
    {
        if (!name.length)
        {
            [self requestuserInfo];
        }
        
        [self.textView becomeFirstResponder];
    }
    
    if (name.length)
    {
        self.nameLabel.text = name;
    }
    
    self.imageView.image = self.image;
    self.textView.text = self.text;
    
    [self showImageView:(self.image != nil)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.textView.text = @"";
    self.nameLabel.text = @"";
}

#pragma mark - Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        return interfaceOrientation == UIInterfaceOrientationPortrait;
    }
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {		
		if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
		{
			self.containerView.center = CGPointMake(self.view.bounds.size.width / 2, (self.view.bounds.size.height - 352) / 2);
			self.backgroundImageView.image = [UIImage imageNamed:@"FBSheetVignetteLandscape.png"];
		}
		else
		{
			self.containerView.center = CGPointMake(self.view.bounds.size.width / 2, (self.view.bounds.size.height - 264) / 2);
			self.backgroundImageView.image = [UIImage imageNamed:@"FBSheetVignettePortrait.png"];
		}
		
    }
}

#pragma mark - Public methods

- (IBAction)cancel:(id)sender
{
    [self dismiss];
}

- (IBAction)logout:(id)sender
{
    self.nameLabel.text = @"";
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"facebook.name"];
    [self.facebook logout];
    [self dismiss];
}

- (IBAction)send:(id)sender
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Posting to the wall", @"Facebook integration: Message displayed when the app tries to post a picture on the user's Facebook wall.") 
                         maskType:SVProgressHUDMaskTypeGradient];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.textView.text, @"message", nil];
    NSString *graphPath = [NSString stringWithFormat:@"/me/feed?access_token=%@", self.facebook.accessToken];
    
    if (self.image)
    {
        [params setObject:self.image forKey:@"source"];
		graphPath = [NSString stringWithFormat:@"/me/photos?access_token=%@", self.facebook.accessToken];
    }
	else if (self.link.length)
    {
        [params setObject:self.link forKey:@"link"];
		graphPath = [NSString stringWithFormat:@"/me/links?access_token=%@", self.facebook.accessToken];        
    }
	
	postRequest = [self.facebook requestWithGraphPath:graphPath
                                            andParams:params 
                                        andHttpMethod:@"POST" 
                                          andDelegate:self];
    
    [self dismiss];
}

- (void)setup:(NSString *)appID
{
	[self setup:appID withUrlSchemeSuffix:nil];
}

- (void)setup:(NSString *)appID withUrlSchemeSuffix:(NSString *)suffix
{
    if (suffix)
	{
		self.facebook = [[Facebook alloc] initWithAppId:appID urlSchemeSuffix:suffix andDelegate:self];
	}
	else
	{
		self.facebook = [[Facebook alloc] initWithAppId:appID andDelegate:self];
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
}

- (void)requestuserInfo
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Requesting user name", @"Facebook integration: Message displayed when the app tries to retriew the user's username from Facebook.")
                         maskType:SVProgressHUDMaskTypeGradient];
    
    userInfoRequest = [self.facebook requestWithGraphPath:@"me" andDelegate:self];
}

- (void)present
{
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.view.frame = rootVC.view.bounds;
	if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
		CGRect containerFrame = self.containerView.frame;
		containerFrame.size.width = 540;
		self.containerView.frame = containerFrame;
		self.containerView.center = CGPointMake(self.view.bounds.size.width / 2, (self.view.bounds.size.height - 264) / 2);
		if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
		{
			self.containerView.center = CGPointMake(self.view.bounds.size.width / 2, (self.view.bounds.size.height - 352) / 2);
		}
    }
    [rootVC.view addSubview:self.view];
    [self viewWillAppear:YES];
    
    [self.textView becomeFirstResponder];
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.backgroundImageView.alpha = 1.;
                         self.containerView.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         [self viewDidAppear:YES];
                     }];
}

- (void)dismiss
{
    [self viewWillDisappear:YES];
    
    [self.textView resignFirstResponder];
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationCurveEaseInOut
                     animations:^{
                         self.backgroundImageView.alpha = 0.;
						 self.containerView.transform = CGAffineTransformMakeTranslation(0., -(self.containerView.center.y + CGRectGetHeight(self.containerView.frame)));
					 } completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                         [self viewDidDisappear:YES];
                     }];
}

#pragma mark - Properties

- (void)setImage:(UIImage *)newImage
{
    image = newImage;    
    self.imageView.image = image;
    
    [self showImageView:(self.image != nil)];
}

- (void)setText:(NSString *)newText
{
    text = newText;
    self.textView.text = text;
}

#pragma mark - Facebook Session

- (void)fbDidLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [self requestuserInfo];
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
	[self dismiss];
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

- (void)fbDidLogout
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"])
    {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
}

- (void)fbSessionInvalidated
{
    
}

#pragma mark - Facebook Request

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error
{
    if ([request isEqual:userInfoRequest]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"User Info error", @"Facebook integration: Message displayed when an error occured while trying to retrieve info about the user from Facebook.")];
    } else if ([request isEqual:postRequest]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error while posting to the wall", @"Facebook integration: Message displayed when an error occured while trying to post a picture on the user's wall.")];
    }
}

- (void)request:(FBRequest *)request didLoad:(id)result
{
    if ([request isEqual:userInfoRequest]) {
        NSString *name = [result objectForKey:@"name"];
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"facebook.name"];
        self.nameLabel.text = name;
        [SVProgressHUD dismiss];
        [self.textView becomeFirstResponder];
    } else if ([request isEqual:postRequest]) {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"Post successfully submitted", @"Facebook integration: Message displayed when the picture is correctly posted on the user's wall.")];
        [self performSelector:@selector(cancel:) withObject:nil afterDelay:0.6];
    }
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self.textView updateLines];
    return YES;
}

#pragma mark - Utilities

- (void)showImageView:(BOOL)show
{
    self.imageView.hidden = !show;
    self.clipImageView.hidden = !show;
    self.chromeImageView.hidden = !show;
    
    CGRect frame = self.textView.frame;
    if (show)
    {
        frame.size.width = CGRectGetMinX(self.imageView.frame) - (CGRectGetMinX(frame) * 2);
    }
    else
    {
        frame.size.width = CGRectGetMaxX(self.imageView.frame) - CGRectGetMinX(frame);
    }
    self.textView.frame = frame;
    [self.textView updateLines];
}

#pragma mark - Application Notifications

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self.facebook extendAccessTokenIfNeeded];
}

- (void)didRotate:(NSNotification *)notification
{
	if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
    {
		if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
		{
			self.containerView.center = CGPointMake(self.view.bounds.size.width / 2, (self.view.bounds.size.height - 352) / 2);
			self.backgroundImageView.image = [UIImage imageNamed:@"FBSheetVignetteLandscape.png"];
		}
		else
		{
			self.containerView.center = CGPointMake(self.view.bounds.size.width / 2, (self.view.bounds.size.height - 264) / 2);
			self.backgroundImageView.image = [UIImage imageNamed:@"FBSheetVignettePortrait.png"];
		}
    }
}

@end
