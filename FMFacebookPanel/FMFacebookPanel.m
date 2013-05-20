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
	[super setText:text];
	[self updateLines];
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
	
	NSInteger numberOfLines = self.contentSize.height / self.font.lineHeight + 15.;
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
		line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		line.backgroundColor = _lineColor;
		
		[self addSubview:line];
		[_lines addObject:line];
	}
}

@end

@interface FMFacebookPanel ()

@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSURL *url;

@property (strong, nonatomic) NSDictionary *fbPayload;
@property (strong, nonatomic) NSArray *fbPermissions;

@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) UIImageView *headerImageView;
@property (strong, nonatomic) UIImageView *chromeImageView;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *postButton;
@property (strong, nonatomic) UILabel *facebookLabel;
@property (strong, nonatomic) UIView *contentContainerView;
@property (strong, nonatomic) UIView *textContainerView;
@property (strong, nonatomic) LineTextView *textView;
@property (strong, nonatomic) UIImageView *imageImageView;
@property (strong, nonatomic) UIImageView *imageChromeImageView;
@property (strong, nonatomic) UIImageView *imageClipImageView;

@property (assign, nonatomic) CGRect containerViewFrame;
@property (assign, nonatomic) CGPoint containerViewCenter;
@property (assign, nonatomic) CGRect headerImageViewFrame;
@property (assign, nonatomic) CGRect cancelButtonFrame;
@property (assign, nonatomic) CGRect postButtonFrame;
@property (assign, nonatomic) CGFloat buttonsFontSize;
@property (assign, nonatomic) CGFloat facebookLabelFontSize;
@property (assign, nonatomic) CGRect contentContainerViewFrame;
@property (strong, nonatomic) UIImage *backgroundImage;
@property (strong, nonatomic) UIImage *headerImage;
@property (strong, nonatomic) UIImage *chromeImage;
@property (strong, nonatomic) UIImage *cancelButtonImage;
@property (strong, nonatomic) UIImage *cancelButtonPressedImage;
@property (strong, nonatomic) UIImage *postButtonImage;
@property (strong, nonatomic) UIImage *postButtonPressedImage;

@property (assign, nonatomic) CGRect containerViewFrameLandscape;
@property (assign, nonatomic) CGPoint containerViewCenterLandscape;
@property (assign, nonatomic) CGRect headerImageViewFrameLandscape;
@property (assign, nonatomic) CGRect cancelButtonFrameLandscape;
@property (assign, nonatomic) CGRect postButtonFrameLandscape;
@property (assign, nonatomic) CGFloat buttonsFontSizeLandscape;
@property (assign, nonatomic) CGFloat facebookLabelFontSizeLandscape;
@property (assign, nonatomic) CGRect contentContainerViewFrameLandscape;
@property (strong, nonatomic) UIImage *backgroundImageLandscape;
@property (strong, nonatomic) UIImage *headerImageLandscape;
@property (strong, nonatomic) UIImage *chromeImageLandscape;
@property (strong, nonatomic) UIImage *cancelButtonImageLandscape;
@property (strong, nonatomic) UIImage *cancelButtonPressedImageLandscape;
@property (strong, nonatomic) UIImage *postButtonImageLandscape;
@property (strong, nonatomic) UIImage *postButtonPressedImageLandscape;

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
		
		_postRequestStartedMessage = NSLocalizedString(@"Posting to Facebook", @"Facebook integration: Message displayed when the app tries to post a picture on the user's Facebook wall.");
		_postRequestSucceedMessage = @"";
		_postRequestErrorMessage = NSLocalizedString(@"Error posting to Facebook", @"Facebook integration: Message displayed when an error occured while trying to post a picture on the user's wall.");
		_postAuthenticationErrorMessage = NSLocalizedString(@"Error authenticating User", @"Facebook integration: Message displayed when an error occured while trying to authenticate the user.");
		
		_fbPermissions = @[@"public_profile", @"publish_actions"];
		
        dispatch_async(dispatch_get_main_queue(), ^{
            _backgroundImageView = [UIImageView new];
            _containerView = [UIView new];
            _contentContainerView = [UIView new];
            _textContainerView = [UIView new];
            _textView = [LineTextView new];
            _headerImageView = [UIImageView new];
            _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _postButton = [UIButton buttonWithType:UIButtonTypeCustom];
            _facebookLabel = [UILabel new];
            _chromeImageView = [UIImageView new];
            _imageImageView = [UIImageView new];
            _imageChromeImageView = [UIImageView new];
            _imageClipImageView = [UIImageView new];
        });
		
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
	
	_backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_backgroundImageView.alpha = 0.;
	[self.view addSubview:_backgroundImageView];
	
	_containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:_containerView];
	
	_contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_contentContainerView.backgroundColor = [UIColor whiteColor];
	_contentContainerView.layer.cornerRadius = 10.;
	_contentContainerView.layer.masksToBounds = YES;
	[_containerView addSubview:_contentContainerView];
	
	_textContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_textContainerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"FBSheetBottomShadow.png"]];
	[_contentContainerView addSubview:_textContainerView];
	
	_textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_textView.backgroundColor = [UIColor clearColor];
	_textView.delegate = self;
	_textView.font = [UIFont systemFontOfSize:17.];
	_textView.textColor = [UIColor blackColor];
	_textView.contentInset = UIEdgeInsetsMake(8., 0., 0., 0.);
	_textView.lineColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
	_textView.lineWidth = 1.;
	_textView.clipsToBounds = NO;
	_textView.showsVerticalScrollIndicator = NO;
	_textView.linesShouldFollowSuperview = YES;
	[_textContainerView addSubview:_textView];
	
	_headerImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[_containerView addSubview:_headerImageView];
	
	_cancelButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
	_cancelButton.titleLabel.shadowOffset = CGSizeMake(0., -1.);
	[_cancelButton setTitle:NSLocalizedString(@"Cancel", @"Facebook integration") forState:UIControlStateNormal];
	[_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_cancelButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[_cancelButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateHighlighted];
	[_cancelButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
	[_containerView addSubview:_cancelButton];
	
	_postButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
	_postButton.titleLabel.shadowOffset = CGSizeMake(0., -1.);
	[_postButton setTitle:NSLocalizedString(@"Post", @"Facebook integration") forState:UIControlStateNormal];
	[_postButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_postButton setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
	[_postButton addTarget:self action:@selector(post) forControlEvents:UIControlEventTouchUpInside];
	[_containerView addSubview:_postButton];
	
	_facebookLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
	_facebookLabel.text = @"Facebook";
	_facebookLabel.textAlignment = NSTextAlignmentCenter;
	_facebookLabel.textColor = [UIColor whiteColor];
	_facebookLabel.shadowColor = [UIColor darkGrayColor];
	_facebookLabel.shadowOffset = CGSizeMake(0., -1.);
	_facebookLabel.backgroundColor = [UIColor clearColor];
	[_containerView addSubview:_facebookLabel];
	
	_chromeImageView = [UIImageView new];
	_chromeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[_containerView addSubview:_chromeImageView];
	
	_imageImageView = [UIImageView new];
	_imageImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
	_imageImageView.contentMode = UIViewContentModeScaleAspectFill;
	_imageImageView.clipsToBounds = YES;
	_imageImageView.backgroundColor = [UIColor darkGrayColor];
	_imageImageView.layer.cornerRadius = 4.;
	[_contentContainerView addSubview:_imageImageView];
	
	_imageChromeImageView = [UIImageView new];
	_imageChromeImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
	[_contentContainerView addSubview:_imageChromeImageView];
	
	_imageClipImageView = [UIImageView new];
	_imageClipImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
	[_containerView addSubview:_imageClipImageView];
	
	// Frame setup
	
	// IPHONE 3.5"
	_containerViewFrame = CGRectMake(0., 0., 310., 200.);
	_containerViewCenter = CGPointMake(160., 115.);
	_headerImageViewFrame = CGRectMake(-4., -6., 318., 69.);
	_cancelButtonFrame = CGRectMake(7., 8., 61., 31.);
	_postButtonFrame = CGRectMake(255., 8., 49., 31.);
	_buttonsFontSize = 12.;
	_facebookLabelFontSize = 20.;
	_contentContainerViewFrame = CGRectMake(0., 36., CGRectGetWidth(_containerViewFrame), CGRectGetHeight(_containerViewFrame) - 36.);
	_backgroundImage = [UIImage imageNamed:@"FMFacebookPanel.bundle/ComposeSheetVignettePortrait.png"];
	_chromeImage = [[UIImage imageNamed:@"FMFacebookPanel.bundle/SLFacebookSheetBevel.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(90, 90, 90, 90)];
	_headerImage = [[UIImage imageNamed:@"FMFacebookPanel.bundle/SLFacebookSheetHeader.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 90, 0, 90)];
	_cancelButtonImage = [[UIImage imageNamed:@"FMFacebookPanel.bundle/SLFacebookSheetCancelButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	_cancelButtonPressedImage = [[UIImage imageNamed:@"FMFacebookPanel.bundle/SLFacebookSheetCancelButton-pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	_postButtonImage = [[UIImage imageNamed:@"FMFacebookPanel.bundle/SLFacebookSheetPostButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	_postButtonPressedImage = [[UIImage imageNamed:@"FMFacebookPanel.bundle/SLFacebookSheetPostButton-pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	
	_containerViewFrameLandscape = CGRectMake(0., 0., 470., 140.);
	_containerViewCenterLandscape = CGPointMake(240., 73.);
	_headerImageViewFrameLandscape = CGRectMake(-4., -17., 478., 66.);
	_cancelButtonFrameLandscape = CGRectMake(7., 3., 50., 26.);
	_postButtonFrameLandscape = CGRectMake(421., 3., 44., 26.);
	_buttonsFontSizeLandscape = 10.;
	_facebookLabelFontSizeLandscape = 16.;
	_contentContainerViewFrameLandscape = CGRectMake(0., 23., CGRectGetWidth(_containerViewFrameLandscape), CGRectGetHeight(_containerViewFrameLandscape) - 23.);
	_backgroundImageLandscape = [UIImage imageNamed:@"FMFacebookPanel.bundle/ComposeSheetVignetteLandscape.png"];
	_chromeImageLandscape = [[UIImage imageNamed:@"FMFacebookPanel.bundle/SLFacebookSheetFlatBevel.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(90, 90, 90, 90)];
	_headerImageLandscape = [[UIImage imageNamed:@"FMFacebookPanel.bundle/SLFacebookSheetHeader-landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 90, 0, 90)];
	_cancelButtonImageLandscape = [[UIImage imageNamed:@"FMFacebookPanel.bundle/SLFacebookSheetCancelButton-landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	_cancelButtonPressedImageLandscape = [[UIImage imageNamed:@"FMFacebookPanel.bundle/SLFacebookSheetCancelButton-landscape-pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	_postButtonImageLandscape = [[UIImage imageNamed:@"FMFacebookPanel.bundle/SLFacebookSheetPostButton-landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	_postButtonPressedImageLandscape = [[UIImage imageNamed:@"FMFacebookPanel.bundle/SLFacebookSheetPostButton-landscape-pressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	
	// IPHONE 4"
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && CGRectGetHeight([UIScreen mainScreen].bounds) == 568.)
	{
		_containerViewFrameLandscape = CGRectMake(0., 0., 558., 140.);
		_containerViewCenter = CGPointMake(160., 144.);
		_containerViewCenterLandscape = CGPointMake(284., 73.);
		_headerImageViewFrameLandscape = CGRectMake(-4., -17., 566., 66.);
		_postButtonFrameLandscape = CGRectMake(509., 3., 44., 26.);
		_contentContainerViewFrameLandscape = CGRectMake(0., 23., CGRectGetWidth(_containerViewFrameLandscape), CGRectGetHeight(_containerViewFrameLandscape) - 23.);
		_backgroundImage = [UIImage imageNamed:@"FMFacebookPanel.bundle/ComposeSheetVignettePortrait-568h.png"];
		_backgroundImageLandscape = [UIImage imageNamed:@"FMFacebookPanel.bundle/ComposeSheetVignetteLandscape-568h.png"];
	}
	
	// IPAD
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		_containerViewFrame = CGRectMake(0., 0., 540., 200.);
		_containerViewFrameLandscape = _containerViewFrame;
		_containerViewCenter = CGPointMake(384., 376.);
		_containerViewCenterLandscape = CGPointMake(512., 208.);
		_headerImageViewFrame = CGRectMake(-4., -6., 548., 69.);
		_postButtonFrame = CGRectMake(485., 8., 49., 31.);
		_contentContainerViewFrame = CGRectMake(0., 36., CGRectGetWidth(_containerViewFrame), CGRectGetHeight(_containerViewFrame) - 36.);
	}
	
	_backgroundImageView.frame = self.view.bounds;
	
	_imageClipImageView.image = [UIImage imageNamed:@"FMFacebookPanel.bundle/FBSheetPaperClip.png"];
	_imageChromeImageView.image = [[UIImage imageNamed:@"FMFacebookPanel.bundle/FBSheetImageBorderSquare.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(39., 41., 39., 42.)];
	
	[self updateLayout];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	// self to execute custom setter
	self.text = nil;
	self.image = nil;
	self.url = nil;
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
	
	[rootVC.view addSubview:self.view];
	[self viewWillAppear:YES];
	
	[self updateLayout];
	_containerView.transform = CGAffineTransformMakeTranslation(0., -(_containerView.center.y + CGRectGetHeight(_containerView.frame)));
	
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

- (void)setInitialText:(NSString *)text
{
	_text = text;
	dispatch_async(dispatch_get_main_queue(), ^{
		_textView.text = text;
	});
}

- (void)addImage:(UIImage *)image
{
	_image = image;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self showHideImageView];
	});
}

- (void)addURL:(NSURL *)url
{
	_url = url;
}

#pragma mark - Layout

- (void)updateLayout
{
	//	BOOL isLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
	
	// Using statusBarOrientation for better support in iOS5.
	BOOL isLandscape = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation);
	BOOL isiPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
	
	_backgroundImageView.image = (isLandscape) ? _backgroundImageLandscape : _backgroundImage;
	
	_containerView.frame = (isLandscape) ? _containerViewFrameLandscape : _containerViewFrame;
	_containerView.center = (isLandscape) ? _containerViewCenterLandscape : _containerViewCenter;
	
	_chromeImageView.frame = UIEdgeInsetsInsetRect(_containerView.bounds, UIEdgeInsetsMake(-8., -11., -32., -11.));
	_chromeImageView.image = (isLandscape && isiPhone) ? _chromeImageLandscape : _chromeImage;
	
	_headerImageView.frame = (isLandscape && isiPhone) ? _headerImageViewFrameLandscape : _headerImageViewFrame;
	_headerImageView.image = (isLandscape && isiPhone) ? _headerImageLandscape : _headerImage;
	
	_cancelButton.frame = (isLandscape && isiPhone) ? _cancelButtonFrameLandscape : _cancelButtonFrame;
	_cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize: (isLandscape && isiPhone) ? _buttonsFontSizeLandscape : _buttonsFontSize];
	[_cancelButton setBackgroundImage: (isLandscape && isiPhone) ? _cancelButtonImageLandscape : _cancelButtonImage forState:UIControlStateNormal];
	[_cancelButton setBackgroundImage: (isLandscape && isiPhone) ? _cancelButtonPressedImageLandscape : _cancelButtonPressedImage forState:UIControlStateHighlighted];
	
	_postButton.frame = (isLandscape && isiPhone) ? _postButtonFrameLandscape : _postButtonFrame;
	_postButton.titleLabel.font = [UIFont boldSystemFontOfSize: (isLandscape && isiPhone) ? _buttonsFontSizeLandscape : _buttonsFontSize];
	[_postButton setBackgroundImage: (isLandscape && isiPhone) ? _postButtonImageLandscape : _postButtonImage forState:UIControlStateNormal];
	[_postButton setBackgroundImage: (isLandscape && isiPhone) ? _postButtonPressedImageLandscape : _postButtonPressedImage forState:UIControlStateHighlighted];
	
	_facebookLabel.frame = CGRectMake(0., 0., 100., 20.);
	_facebookLabel.font = [UIFont boldSystemFontOfSize: (isLandscape && isiPhone) ? _facebookLabelFontSizeLandscape : _facebookLabelFontSize];
	_facebookLabel.center = CGPointMake(_headerImageView.center.x, _cancelButton.center.y);
	
	_contentContainerView.frame = (isLandscape && isiPhone) ? _contentContainerViewFrameLandscape : _contentContainerViewFrame;
	_textContainerView.frame =  UIEdgeInsetsInsetRect(_contentContainerView.bounds, UIEdgeInsetsMake(10., 0., -10., 0));
	_textView.frame = CGRectOffset(_textContainerView.bounds, 0., -10);
	
	_imageImageView.frame = CGRectMake(CGRectGetWidth(_containerView.bounds) - 78., 20., 72., 72.);
	_imageChromeImageView.frame = UIEdgeInsetsInsetRect(_imageImageView.frame, UIEdgeInsetsMake(-2., -6., -6., -6.));
	_imageClipImageView.frame = CGRectMake(CGRectGetWidth(_containerView.bounds) - 74., 60., 79., 34.);
	
	[self showHideImageView];
}

- (void)showHideImageView
{
	_imageImageView.image = _image;
	
	BOOL show = (_image != nil);
	
	_imageImageView.hidden = !show;
	_imageClipImageView.hidden = !show;
	_imageChromeImageView.hidden = !show;
	
	CGRect frame = _textView.frame;
	if (show)
	{
		frame.size.width = CGRectGetMinX(_imageImageView.frame) - 10.;
	}
	else
	{
		frame.size.width = CGRectGetWidth(_textContainerView.frame);
	}
	_textView.frame = frame;
	[_textView updateLines];
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
	[self updateLayout];
}

#pragma mark - Facebook

- (void)post
{
	_fbPayload = nil;
	
	NSString *path = @"/me/feed";
	
	NSMutableDictionary *params = [NSMutableDictionary new];
	[params addEntriesFromDictionary:@{@"message": _textView.text}];
	if (_image)
	{
		path = @"/me/photos";
		[params addEntriesFromDictionary:@{@"source": UIImageJPEGRepresentation(_image, 1.0)}];
	}
	else if (_url)
	{
		[params addEntriesFromDictionary:@{@"link": _url.absoluteString}];
	}
	
	_fbPayload = @{@"path": path, @"params": params};
	
	[self sendPayloadIfPossible];
	
	[self dismiss];
}

- (void)warmUpFacebookSession
{
	if (FBSession.activeSession.isOpen) {
		if ([self activeSessionHasPermissions:_fbPermissions]) {
			[self sendPayloadIfPossible];
		} else {
			[FBSession.activeSession reauthorizeWithPublishPermissions:_fbPermissions defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error) {
				[self sessionStateChanged:session state:session.state error:error];
			}];
		}
	} else {
		[FBSession openActiveSessionWithPermissions:_fbPermissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
			[self sessionStateChanged:session state:status error:error];
		}];
	}
}

- (void)sendPayloadIfPossible
{
	if (!_fbPayload)
		return;
	
	[SVProgressHUD showWithStatus:_postRequestStartedMessage maskType:SVProgressHUDMaskTypeGradient];
	
	if (FBSession.activeSession.isOpen && [self activeSessionHasPermissions:_fbPermissions])
	{
		[FBRequestConnection startWithGraphPath:_fbPayload[@"path"] parameters:_fbPayload[@"params"] HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
			
			_fbPayload = nil;
			
			if (!error) {
				FMLog(@"FMFacebookPanel posted a Facebook object successfully");
				if ([SVProgressHUD isVisible])
					[SVProgressHUD showSuccessWithStatus:_postRequestSucceedMessage];
			} else {
				FMLog(@"FMFacebookPanel failed to post on Facebook with error: %@", error);
				if ([SVProgressHUD isVisible])
					[SVProgressHUD showErrorWithStatus:_postRequestErrorMessage];
			}
		}];
	}
	else
	{
		[self warmUpFacebookSession];
	}
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error
{
	if (!error) {
		[self sendPayloadIfPossible];
	} else {
		FMLog(@"FMFacebookPanel failed Facebook authentication with error: %@", error);
		if ([SVProgressHUD isVisible]) {
			[SVProgressHUD showErrorWithStatus:_postAuthenticationErrorMessage];
		}
	}
}

- (BOOL)activeSessionHasPermissions:(NSArray *)permissions
{
	for (NSString *permission in permissions)
	{
		if ([FBSession.activeSession.permissions indexOfObject:permission] == NSNotFound)
		{
			return NO;
		}
	}
	return YES;
}

@end