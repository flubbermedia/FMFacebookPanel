//
//  LineTextView.h
//
//  Created by Maurizio Cremaschi on 03/04/2012.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LineTextView : UITextView

@property (strong, nonatomic) UIColor *lineColor;
@property (assign, nonatomic) CGFloat lineWidth;
@property (assign, nonatomic) BOOL linesShouldFollowSuperview;

- (void)updateLines;

@end
