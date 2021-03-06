//
//  ViewController.m
//  Demo
//
//  Created by Maurizio Cremaschi on 7/24/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "ViewController.h"
#import "FMFacebookPanel.h"

@implementation ViewController

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
	[[FMFacebookPanel sharedViewController] setInitialText:@"Image text here"];
	[[FMFacebookPanel sharedViewController] addImage:[UIImage imageNamed:@"Flubber.png"]];
	[[FMFacebookPanel sharedViewController] present];
}

- (IBAction)didTapShareLink:(id)sender
{
	[[FMFacebookPanel sharedViewController] setInitialText:@"Link text here"];
	[[FMFacebookPanel sharedViewController] addURL:[NSURL URLWithString:@"http://flubbermedia.com"]];
	[[FMFacebookPanel sharedViewController] present];
}

@end
