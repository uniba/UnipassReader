//
//  ViewController.h
//  Pass Reader
//
//  Created by hideyukisaito on 12/11/07.
//  Copyright (c) 2012年 Uniba Inc. All rights reserved.
//

#define DEST_HOST @"10.4.0.63"
#define DEST_PORT 10000

#import <UIKit/UIKit.h>
#import "ZXCaptureDelegate.h"
#import "VVOSC.h"

@interface ViewController : UIViewController <ZXCaptureDelegate>

@property (nonatomic, strong) OSCManager *manager;

- (void)setupOSC;

- (IBAction)scanButtonPressed:(id)sender;

@end
