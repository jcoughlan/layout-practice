//
//  HomeViewController.h
//  BKS base project
//
//  Created by James Coughlan on 05/02/2015.
//  Copyright (c) 2015 James Coughlan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopoverViewController.h"
#import <WYPopoverController/WYPopoverController.h>
@interface HomeViewController : UIViewController <WYPopoverControllerDelegate>
{
    WYPopoverController* popoverController;
}

@property (weak, nonatomic) IBOutlet UIButton *popoverButton;

@property (nonatomic, retain) UIPopoverController* popoverViewController;

- (IBAction)popoverButtonPressed:(id)sender;

@end
