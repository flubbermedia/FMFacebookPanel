//
//  FMFacebookPanel.h
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

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#if DEBUG
#	define FMLog(...) NSLog(__VA_ARGS__)
#else
#   define FMLog(...)
#endif

@interface LineTextView : UITextView

@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) BOOL linesShouldFollowSuperview;

- (void)updateLines;

@end

@interface FMFacebookPanel : UIViewController <UITextViewDelegate>

@property (strong, nonatomic) NSString *postRequestStartedMessage;
@property (strong, nonatomic) NSString *postRequestSucceedMessage;
@property (strong, nonatomic) NSString *postRequestErrorMessage;
@property (strong, nonatomic) NSString *postAuthenticationErrorMessage;

+ (FMFacebookPanel *)sharedViewController;
- (void)present;
- (void)dismiss;

- (void)setInitialText:(NSString *)text;
- (void)addImage:(UIImage *)image;
- (void)addURL:(NSURL *)url;

@end
