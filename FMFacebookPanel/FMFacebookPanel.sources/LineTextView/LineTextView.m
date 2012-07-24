//
//  LineTextView.m
//
//  Created by Maurizio Cremaschi on 03/04/2012.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "LineTextView.h"

@interface LineTextView ()

@property (strong) NSMutableArray *lines;

@end

@implementation LineTextView

@synthesize lines;
@synthesize lineColor;
@synthesize lineWidth;
@synthesize linesShouldFollowSuperview;

- (void)awakeFromNib
{
    self.lines = [NSMutableArray new];
    self.alwaysBounceVertical = YES;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self awakeFromNib];
    }
    return self;
}

#pragma mark - Properties

- (void)setText:(NSString *)text
{
    [self updateLines];
    [super setText:text];
}

- (void)setLineWidth:(CGFloat)aLineWidth
{
    lineWidth = aLineWidth;
    [self updateLines];
}

- (void)setLineColor:(UIColor *)aLineColor
{
    lineColor = aLineColor;
    [self updateLines];
}

#pragma mark - Lines utilites

- (void)updateLines
{
    [self.lines makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[self.lines removeAllObjects];
	
    NSInteger numberOfLines = self.contentSize.height / self.font.lineHeight + 15;
    CGFloat yOffset = 8.;
    
    for (int i = 1; i < numberOfLines; i++)
    {
        CGRect frame;
        frame.origin.x = 0.;
        frame.origin.y = self.font.lineHeight * i + yOffset;
        frame.size.width = self.bounds.size.width;
        frame.size.height = self.lineWidth;
        
        if (self.linesShouldFollowSuperview)
        {
            frame.origin.x = [self.superview convertPoint:CGPointZero toView:self].x;
            frame.size.width = self.superview.bounds.size.width;
        }
        
        UIView *line = [[UIView alloc] initWithFrame:frame];
        line.backgroundColor = self.lineColor;
        
        [self addSubview:line];
        [self.lines addObject:line];
    }
}

@end
