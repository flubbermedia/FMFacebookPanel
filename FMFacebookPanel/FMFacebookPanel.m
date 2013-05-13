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
#import <QuartzCore/QuartzCore.h>

@interface LineTextView ()

@property (strong) NSMutableArray *lines;

@end

@implementation LineTextView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		_lines = [NSMutableArray new];
		self.alwaysBounceVertical = YES;
	}
	return self;
}

#pragma mark - Properties

- (void)setText:(NSString *)text
{
	[self updateLines];
	[super setText:text];
}

- (void)setLineWidth:(CGFloat)lineWidth
{
	_lineWidth = lineWidth;
	[self updateLines];
}

- (void)setLineColor:(UIColor *)lineColor
{
	_lineColor = lineColor;
	[self updateLines];
}

#pragma mark - Lines utilites

- (void)updateLines
{
	[_lines makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[_lines removeAllObjects];
	
	NSInteger numberOfLines = self.contentSize.height / self.font.lineHeight + 15;
	CGFloat yOffset = 8.;
	
	for (int i = 1; i < numberOfLines; i++)
	{
		CGRect frame;
		frame.origin.x = 0.;
		frame.origin.y = self.font.lineHeight * i + yOffset;
		frame.size.width = self.bounds.size.width;
		frame.size.height = _lineWidth;
		
		if (_linesShouldFollowSuperview)
		{
			frame.origin.x = [self.superview convertPoint:CGPointZero toView:self].x;
			frame.size.width = self.superview.bounds.size.width;
		}
		
		UIView *line = [[UIView alloc] initWithFrame:frame];
		line.backgroundColor = _lineColor;
		
		[self addSubview:line];
		[_lines addObject:line];
	}
}

@end

@interface FMFacebookPanel ()

typedef enum {
	PostTypeText,
	PostTypeImage,
	PostTypeLink
} PostType;

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *textViewContainer;
@property (strong, nonatomic) IBOutlet LineTextView *textView;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIImageView *clipImageView;
@property (strong, nonatomic) IBOutlet UIImageView *chromeImageView;
@property (strong, nonatomic) IBOutlet UILabel *facebookLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UIButton *logoutButton;

@property (assign, nonatomic) PostType postType;

@end

@implementation FMFacebookPanel

+ (FMFacebookPanel *)sharedViewController
{
	static FMFacebookPanel *sharedViewController = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedViewController = [FMFacebookPanel new];
	});
	return sharedViewController;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		_postType = PostTypeText;
		
		_postRequestStartedMessage = NSLocalizedString(@"Posting to the wall", @"Facebook integration: Message displayed when the app tries to post a picture on the user's Facebook wall.");
		_postSuccessMessage = @"";
		_postErrorMessage = NSLocalizedString(@"Error while posting to the wall", @"Facebook integration: Message displayed when an error occured while trying to post a picture on the user's wall.");
		
		_textView = [LineTextView new];
		_imageView = [UIImageView new];
	}
	return self;
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
											 selector:@selector(applicationWillTerminate:)
												 name:UIApplicationWillTerminateNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didRotate:)
												 name:UIDeviceOrientationDidChangeNotification
											   object:nil];
	
	_backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	_backgroundImageView.image = [UIImage imageNamed:@"FMFacebookPanel.bundle/FBSheetVignettePortrait.png"];
	_backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_backgroundImageView.alpha = 0.;
	[self.view addSubview:_backgroundImageView];
	
	_containerView = [[UIView alloc] initWithFrame:CGRectMake(4., 21., 312., 222.)];
	_containerView.backgroundColor = [UIColor clearColor];
	_containerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
	_containerView.layer.cornerRadius = 10.;
	_containerView.layer.backgroundColor = [UIColor whiteColor].CGColor;
	_containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
	[self.view addSubview:_containerView];
	
	UIView *paperView = [[UIView alloc] initWithFrame:_containerView.bounds];
	paperView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	paperView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"FMFacebookPanel.bundle/FBSheetPaperTexture.png"]];
	[_containerView addSubview:paperView];
	
	UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"FMFacebookPanel.bundle/FBSheetBottomShadow.png"]];
	gradientImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	gradientImageView.frame = _containerView.bounds;
	[_containerView addSubview:gradientImageView];
	
	UIView *dividerRedView = [[UIView alloc] initWithFrame:CGRectMake(0., 40., _containerView.frame.size.width, 3.)];
	dividerRedView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	dividerRedView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"FMFacebookPanel.bundle/FBSheetRedPerf.png"]];
	[gradientImageView addSubview:dividerRedView];
	
	UIView *dividerGrayView = [[UIView alloc] initWithFrame:CGRectMake(0., 73., _containerView.frame.size.width, 3.)];
	dividerGrayView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	dividerGrayView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"FMFacebookPanel.bundle/FBSheetGrayPerf.png"]];
	[gradientImageView addSubview:dividerGrayView];
	
	CGRect chromeRect = CGRectInset(_containerView.bounds, -13., -34.);
	chromeRect = CGRectApplyAffineTransform(chromeRect, CGAffineTransformMakeTranslation(0., -1.));
	UIImageView *chromeView = [[UIImageView alloc] initWithFrame:chromeRect];
	chromeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	chromeView.image = [[UIImage imageNamed:@"FMFacebookPanel.bundle/FBSheetPaperChrome.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(64., 34., 64., 34.)];
	[gradientImageView addSubview:chromeView];
	
	_facebookLabel = [[UILabel alloc] initWithFrame:CGRectMake(101., 10., 110., 21.)];
	_facebookLabel.text = @"Facebook";
	_facebookLabel.textAlignment = UITextAlignmentCenter;
	_facebookLabel.textColor = [UIColor  darkGrayColor];
	_facebookLabel.font = [UIFont boldSystemFontOfSize:20.];
	_facebookLabel.shadowColor = [UIColor whiteColor];
	_facebookLabel.shadowOffset = CGSizeMake(0., -1.);
	_facebookLabel.backgroundColor = [UIColor clearColor];
	_facebookLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
	[_containerView addSubview:_facebookLabel];
	
	_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cancelButton.frame = CGRectMake(7., 6., 64., 30.);
	_cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.];
	_cancelButton.titleLabel.shadowOffset = CGSizeMake(0., 1.);
	[_cancelButton setTitle:NSLocalizedString(@"Cancel", @"Facebook integration") forState:UIControlStateNormal];
	[_cancelButton setTitleColor:[UIColor colorWithWhite:0.54 alpha:1.0] forState:UIControlStateNormal];
	[_cancelButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
	UIImage *cancelButtonImage = [[UIImage imageNamed:@"FMFacebookPanel.bundle/FBSheetCancelButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0., 5., 0., 5.)];
	UIImage *cancelButtonPressedImage = [[UIImage imageNamed:@"FMFacebookPanel.bundle/FBSheetCancelButtonPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0., 5., 0., 5.)];
	[_cancelButton setBackgroundImage:cancelButtonImage forState:UIControlStateNormal];
	[_cancelButton setBackgroundImage:cancelButtonPressedImage forState:UIControlStateHighlighted];
	[_containerView addSubview:_cancelButton];
	
	_sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_sendButton.frame = CGRectMake(250., 6., 54., 30.);
	_sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
	_sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.];
	_sendButton.titleLabel.shadowOffset = CGSizeMake(0., -1.);
	[_sendButton setTitle:NSLocalizedString(@"Send", @"Facebook integration") forState:UIControlStateNormal];
	[_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_sendButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[_sendButton addTarget:self action:@selector(post) forControlEvents:UIControlEventTouchUpInside];
	UIImage *sendButtonImage = [[UIImage imageNamed:@"FMFacebookPanel.bundle/FBSheetSendButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0., 5., 0., 5.)];
	UIImage *sendButtonPressedImage = [[UIImage imageNamed:@"FMFacebookPanel.bundle/FBSheetSendButtonPressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0., 5., 0., 5.)];
	[_sendButton setBackgroundImage:sendButtonImage forState:UIControlStateNormal];
	[_sendButton setBackgroundImage:sendButtonPressedImage forState:UIControlStateHighlighted];
	[_containerView addSubview:_sendButton];
	
	_textViewContainer = [[UIView alloc] initWithFrame:CGRectMake(5., 76., CGRectGetWidth(_containerView.frame) - 10., 110.)];
	_textViewContainer.backgroundColor = [UIColor clearColor];
	_textViewContainer.clipsToBounds = YES;
	_textViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[_containerView addSubview:_textViewContainer];
	
	_textView.frame = CGRectMake(0., -10., CGRectGetWidth(_textViewContainer.frame), CGRectGetHeight(_textViewContainer.frame));
	_textView.backgroundColor = [UIColor clearColor];
	_textView.delegate = self;
	_textView.font = [UIFont systemFontOfSize:17.];
	_textView.textColor = [UIColor blackColor];
	_textView.contentInset = UIEdgeInsetsMake(8., 0., 0., 0.);
	_textView.lineColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
	_textView.lineWidth = 1.;
	_textView.linesShouldFollowSuperview = YES;
	_textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[_textViewContainer addSubview:_textView];
	
	_imageView.frame = CGRectMake(232., 97., 72., 72.);
	_imageView.contentMode = UIViewContentModeScaleAspectFill;
	_imageView.clipsToBounds = YES;
	_imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
	_imageView.backgroundColor = [UIColor darkGrayColor];
	_imageView.layer.cornerRadius = 4.;
	[_containerView addSubview:_imageView];
	
	CGRect chromeImageRect = CGRectInset(_imageView.frame, -6., -4.);
	chromeImageRect = CGRectApplyAffineTransform(chromeImageRect, CGAffineTransformMakeTranslation(0., 2.));
	_chromeImageView = [[UIImageView alloc] initWithFrame:chromeImageRect];
	_chromeImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
	_chromeImageView.image = [[UIImage imageNamed:@"FMFacebookPanel.bundle/FBSheetImageBorderSquare.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(39., 41., 39., 42.)];
	[_containerView addSubview:_chromeImageView];
	
	_clipImageView = [[UIImageView alloc] initWithFrame:CGRectMake(239., 82., 79., 34.)];
	_clipImageView.image = [UIImage imageNamed:@"FMFacebookPanel.bundle/FBSheetPaperClip.png"];
	_clipImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
	[_containerView addSubview:_clipImageView];
	
	if (![[UIApplication sharedApplication] isStatusBarHidden])
	{
		if ([UIApplication sharedApplication].keyWindow.rootViewController.wantsFullScreenLayout)
		{
			_containerView.center = CGPointMake(_containerView.center.x, _containerView.center.y+10.);
		}
		else
		{
			_containerView.center = CGPointMake(_containerView.center.x, _containerView.center.y-10.);
		}
	}
	
	[self showHideImageView];
	
	_containerView.transform = CGAffineTransformMakeTranslation(0., -(_containerView.center.y + CGRectGetHeight(_containerView.frame)));
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	_postType = PostTypeText;
	// self to execute custom setter
	self.postImage = nil;
	self.postLink = nil;
	self.postText = nil;
	
	_textView.text = @"";
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

#pragma mark - Public methods

- (void)present
{
	UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
	self.view.frame = rootVC.view.bounds;
	if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
	{
		CGRect containerFrame = _containerView.frame;
		containerFrame.size.width = 540;
		_containerView.frame = containerFrame;
		_containerView.center = CGPointMake(self.view.bounds.size.width / 2, (self.view.bounds.size.height - 264) / 2);
		if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
		{
			_containerView.center = CGPointMake(self.view.bounds.size.width / 2, (self.view.bounds.size.height - 352) / 2);
		}
	}
	[rootVC.view addSubview:self.view];
	[self viewWillAppear:YES];
	
	[_textView becomeFirstResponder];
	[UIView animateWithDuration:0.3
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 _backgroundImageView.alpha = 1.;
						 _containerView.transform = CGAffineTransformIdentity;
					 } completion:^(BOOL finished) {
						 [self viewDidAppear:YES];
					 }];
}

- (void)dismiss
{
	[self viewWillDisappear:YES];
	
	[_textView resignFirstResponder];
	[UIView animateWithDuration:0.3
						  delay:0.0
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 _backgroundImageView.alpha = 0.;
						 _containerView.transform = CGAffineTransformMakeTranslation(0., -(_containerView.center.y + CGRectGetHeight(_containerView.frame)));
					 } completion:^(BOOL finished) {
						 [self.view removeFromSuperview];
						 [self viewDidDisappear:YES];
					 }];
}

#pragma mark - Properties


- (void)setPostText:(NSString *)text
{
	_postText = text;
	_postType = PostTypeText;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		_textView.text = text;
	});
}

- (void)setPostImage:(UIImage *)image
{
	_postImage = image;
	_postType = PostTypeImage;
	
	dispatch_async(dispatch_get_main_queue(), ^{
		[self showHideImageView];
	});
}

- (void)setPostLink:(NSString *)link
{
	_postLink = link;
	_postType = PostTypeLink;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	[_textView updateLines];
	return YES;
}

#pragma mark - Application Notifications

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	[FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[FBSession.activeSession close];
}

- (void)didRotate:(NSNotification *)notification
{
	if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
	{
		if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
		{
			_containerView.center = CGPointMake(self.view.bounds.size.width / 2, (self.view.bounds.size.height - 352) / 2);
			_backgroundImageView.image = [UIImage imageNamed:@"FMFacebookPanel.bundle/FBSheetVignetteLandscape.png"];
		}
		else
		{
			_containerView.center = CGPointMake(self.view.bounds.size.width / 2, (self.view.bounds.size.height - 264) / 2);
			_backgroundImageView.image = [UIImage imageNamed:@"FMFacebookPanel.bundle/FBSheetVignettePortrait.png"];
		}
	}
}

#pragma mark - Utilities

- (void)showHideImageView
{
	_imageView.image = _postImage;
	
	BOOL show = (_postImage != nil);
	
	_imageView.hidden = !show;
	_clipImageView.hidden = !show;
	_chromeImageView.hidden = !show;
	
	CGRect frame = _textViewContainer.frame;
	if (show)
	{
		frame.size.width = CGRectGetMinX(_imageView.frame) - 10.;
	}
	else
	{
		frame.size.width = CGRectGetWidth(_containerView.frame) - 10.;
	}
	_textViewContainer.frame = frame;
	[_textView updateLines];
}

#pragma mark - Facebook

- (void)post
{
	[SVProgressHUD showWithStatus:_postRequestStartedMessage maskType:SVProgressHUDMaskTypeGradient];
	
	NSArray *permissions = [NSArray arrayWithObject:@"publish_actions"];
	
	if (FBSession.activeSession.isOpen) {
		if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
			[FBSession.activeSession reauthorizeWithPublishPermissions:permissions
													   defaultAudience:FBSessionDefaultAudienceFriends
													 completionHandler:^(FBSession *session, NSError *error) {
														 if (!error) {
															 [self publishStory:^(FBRequestConnection *connection, id result, NSError *error) {
																 if (!error) {
																	 [SVProgressHUD showSuccessWithStatus:_postSuccessMessage];
																 } else {
																	 [SVProgressHUD showErrorWithStatus:_postErrorMessage];
																 }
															 }];
														 } else {
															 [SVProgressHUD showErrorWithStatus:_postErrorMessage];
														 }
													 }];
		} else {
			[self publishStory:^(FBRequestConnection *connection, id result, NSError *error) {
				if (!error) {
					[SVProgressHUD showSuccessWithStatus:_postSuccessMessage];
				} else {
					[SVProgressHUD showErrorWithStatus:_postErrorMessage];
				}
			}];
		}
		
	} else {
		[FBSession openActiveSessionWithPermissions:permissions
									   allowLoginUI:YES
								  completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
									  if (!error) {
										  [self publishStory:^(FBRequestConnection *connection, id result, NSError *error) {
											  if (!error) {
												  [SVProgressHUD showSuccessWithStatus:_postSuccessMessage];
											  } else {
												  [SVProgressHUD showErrorWithStatus:_postErrorMessage];
											  }
										  }];
									  } else {
										  [SVProgressHUD showErrorWithStatus:_postErrorMessage];
									  }
								  }];
	}
	
	[self dismiss];
}

- (void)publishStory:(void (^)(FBRequestConnection *connection, id result, NSError *error))completion
{
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:_textView.text, @"message", nil];
	
	NSString *graphPath = @"/me/feed";
	
	switch (_postType) {
		case PostTypeImage:
			[params setObject:_postImage forKey:@"source"];
			graphPath = @"/me/photos";
			break;
		case PostTypeLink:
			[params setObject:_postLink forKey:@"link"];
			graphPath = @"/me/links";
			break;
		default:
			break;
	}
	
	[FBRequestConnection startWithGraphPath:@"me/feed"
								 parameters:params
								 HTTPMethod:@"POST"
						  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
							  completion(connection, result, error);
						  }];
}

@end
