//
//  ViewController.m
//  Pass Reader
//
//  Created by hideyukisaito on 12/11/07.
//  Copyright (c) 2012年 Uniba Inc. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "ViewController.h"
#import "ZXCapture.h"
#import "ZXDecodeHints.h"
#import "ZXResult.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UIButton *scanButton;

@property (nonatomic, retain) ZXCapture *capture;
@property (nonatomic, retain) IBOutlet UILabel *decodedLabel;
@property (nonatomic, retain) NSString *currentResult;

@property (nonatomic, retain) OSCOutPort *outPort;
@property (nonatomic, retain) OSCInPort  *inPort;

- (NSString *)displayForResult:(ZXResult *)result;

@end

@implementation ViewController

@synthesize scanButton;
@synthesize capture;
@synthesize decodedLabel;
@synthesize currentResult;
@synthesize manager;
@synthesize outPort;
@synthesize inPort;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (nil != self) {
        self.manager = [[OSCManager alloc] init];
        [self setupOSC];
        NSLog(@"init");
    }
    return self;
}

- (void)setupOSC
{
    self.outPort = [self.manager createNewOutputToAddress:DEST_HOST atPort:DEST_PORT];
    self.inPort = [self.manager createNewInputForPort:10001];
    
    NSLog(@"setupOSC outPort= %@", self.outPort);
}

- (IBAction)scanButtonPressed:(id)sender
{
    [self.view.layer addSublayer:self.capture.layer];
    [self.view bringSubviewToFront:self.decodedLabel];
    [self.capture start];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.capture = [[ZXCapture alloc] init];
    self.capture.delegate = self;
    self.capture.rotation = 90.0f;
    
    self.capture.camera = self.capture.back;
    
    self.capture.layer.frame = self.view.bounds;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self.capture stop];
    self.decodedLabel = nil;
}

- (BOOL)shouldAutorotate
{
    return NO;
}



- (NSString *)displayForResult:(ZXResult *)result
{
    NSString *formatString;
    
    switch (result.barcodeFormat) {
        case kBarcodeFormatAztec:
            formatString = @"Aztec";
            break;
            
        case kBarcodeFormatCodabar:
            formatString = @"CODABAR";
            break;
            
        case kBarcodeFormatCode39:
            formatString = @"Code 39";
            break;
            
        case kBarcodeFormatCode93:
            formatString = @"Code 93";
            break;
            
        case kBarcodeFormatCode128:
            formatString = @"Code 128";
            break;
            
        case kBarcodeFormatDataMatrix:
            formatString = @"Data Matrix";
            break;
            
        case kBarcodeFormatEan8:
            formatString = @"EAN-8";
            break;
            
        case kBarcodeFormatEan13:
            formatString = @"EAN-13";
            break;
            
        case kBarcodeFormatITF:
            formatString = @"ITF";
            break;
            
        case kBarcodeFormatPDF417:
            formatString = @"PDF417";
            break;
            
        case kBarcodeFormatQRCode:
            formatString = @"QR Code";
            break;
            
        case kBarcodeFormatRSS14:
            formatString = @"RSS 14";
            break;
            
        case kBarcodeFormatRSSExpanded:
            formatString = @"RSS Expanded";
            break;
            
        case kBarcodeFormatUPCA:
            formatString = @"UPCA";
            break;
            
        case kBarcodeFormatUPCE:
            formatString = @"UPCE";
            break;
            
        case kBarcodeFormatUPCEANExtension:
            formatString = @"UPC/EAN extension";
            break;
            
        default:
            formatString = @"Unknown";
            break;
    }
    
    return [NSString stringWithFormat:@"Scanned!\n\nFormat: %@\n\nContents:\n%@", formatString, result.text];
}



- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result
{
    if (result) {
        if (![self.currentResult isEqualToString:result.text]) {
            self.currentResult = result.text;
            
            NSLog(@"scaned %@", self.currentResult);
            
            [self.decodedLabel performSelectorOnMainThread:@selector(setText:) withObject:[self displayForResult:result] waitUntilDone:YES];
            
            OSCMessage *message = [OSCMessage createWithAddress:@"/unipass/scaned"];
            [message addString:self.currentResult];
            [self.outPort sendThisPacket:[OSCPacket createWithContent:message]];
        }
    } else {
        self.currentResult = @"";
    }
}

- (void)captureSize:(ZXCapture *)capture width:(NSNumber *)width height:(NSNumber *)height
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
