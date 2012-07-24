//
//  ViewController.m
//  Demo
//
//  Created by Maurizio Cremaschi on 7/24/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "ViewController.h"
#import "FMFacebookPanel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Actions

- (IBAction)didTapShareImage:(id)sender
{
    NSString *text = @"Sharing images is very easy";
    UIImage *image = [UIImage imageNamed:@"Flubber.png"];
    
    [[FMFacebookPanel sharedViewController] setText:text];
    [[FMFacebookPanel sharedViewController] setImage:image];
    [[FMFacebookPanel sharedViewController] present];
}

- (IBAction)didTapShareLink:(id)sender
{
    NSString *text = @"Sharing links is very easy";
    NSString *link = @"http://flubbermedia.com";
    
    [[FMFacebookPanel sharedViewController] setText:text];
    [[FMFacebookPanel sharedViewController] setLink:link];
    [[FMFacebookPanel sharedViewController] present];
}

@end
