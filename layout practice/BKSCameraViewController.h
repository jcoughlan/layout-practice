//
//  BKSCameraViewController.h
//  BKS base project
//
//  Created by James Coughlan on 24/02/2015.
//  Copyright (c) 2015 James Coughlan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface BKSCameraViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationView;
@property (strong, nonatomic)  AVCaptureSession *captureSession;
@property (strong, nonatomic)   AVCaptureVideoPreviewLayer* captureVideoPreviewLayer;
@end
