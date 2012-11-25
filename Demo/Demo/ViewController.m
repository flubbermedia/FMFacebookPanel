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
    
}

- (IBAction)didTapShareLink:(id)sender
{
    [FMFacebookPanel sharedViewController].postTitle = @"My link sharing";
    [FMFacebookPanel sharedViewController].postCaption = @"This is the best link sharing ever";
    [FMFacebookPanel sharedViewController].postDescription = @"I'd like to describe my link sharing, it's so wow!";
    //[FMFacebookPanel sharedViewController].postImageURL = @"";
    [FMFacebookPanel sharedViewController].postLink = @"http://flubbermedia.com";
    [FMFacebookPanel sharedViewController].initialPostText = @"Type your thought here";
    [[FMFacebookPanel sharedViewController] present];
}

@end
