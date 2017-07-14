//
//  LCCameraView.m
//  tutorial01
//
//  Created by zjc on 2017/7/14.
//  Copyright © 2017年 lecloud. All rights reserved.
//

#import "LCCameraView.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>


@interface LCCameraView ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) dispatch_queue_t  cameraProcessingQueue;
@property (nonatomic, strong) dispatch_queue_t  audioProcessQueue;

@property (nonatomic, strong) AVCaptureDevice *inputCamareDevice;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput * videoInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutPut;

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation LCCameraView

- (instancetype) init {
    if (self = [super init]) {
        _cameraProcessingQueue = dispatch_queue_create("com.lecloud.cameraQuue", 0);
        _audioProcessQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        [self setupVideoCamareWithPosition:AVCaptureDevicePositionBack];
    }
    return self;
}

- (void) setupVideoCamareWithPosition:(AVCaptureDevicePosition) cameraPosition{
    
    // 1. get input device
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (device.position == cameraPosition) {
            self.inputCamareDevice = device;
        }
    }
    // 2. captureSession
    BOOL enableApplicationSession  =  YES;
    if (enableApplicationSession) {
        self.captureSession.automaticallyConfiguresApplicationAudioSession = YES;
        self.captureSession.usesApplicationAudioSession = YES;
    }
    [self.captureSession beginConfiguration];
    
    //  3. add input
    NSError * error = nil;
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_inputCamareDevice error:&error];
    if ([self.captureSession canAddInput:self.videoInput]) {
        [self.captureSession addInput:_videoInput];
    }
    
    // 4. add outPut
    [self.videoDataOutPut setSampleBufferDelegate:self queue:_cameraProcessingQueue];
    if ([self.captureSession canAddOutput:_videoDataOutPut]) {
        [self.captureSession addOutput:_videoDataOutPut];
    } else {
        NSLog(@"can't add video output");
    }
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    }
    [self.captureSession commitConfiguration];
}
//   5. setupPreivew
- (void) setupPreviewWithView:(UIView *) view{
    if (!view) {
        return;
    }
    CALayer *layer = view.layer;
    layer.masksToBounds = YES;
    self.previewLayer.frame = layer.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [layer insertSublayer:self.previewLayer atIndex:0];
}

- (void) startCapture{
    if (![_captureSession isRunning]) {
        [_captureSession startRunning];
    }
}


#pragma mark - busy

- (AVCaptureSession *) captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}

- (AVCaptureVideoDataOutput *) videoDataOutPut {
    if (!_videoDataOutPut) {
        _videoDataOutPut = [[AVCaptureVideoDataOutput alloc] init];
        [_videoDataOutPut setAlwaysDiscardsLateVideoFrames:NO];
        
        // 优先采集YUV数据
        BOOL supportFullYUVRange = NO;
        NSArray *supportPixelFormats = _videoDataOutPut.availableVideoCVPixelFormatTypes;
        for (NSNumber * pixelFormats in supportPixelFormats) {
            if ([pixelFormats integerValue] == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange){
                supportFullYUVRange = YES;
            }
        }
        
        BOOL useYUV = YES;

        if (supportFullYUVRange && useYUV) {
            // cfString 如何转化为NSString
            [_videoDataOutPut setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        }else{
            [_videoDataOutPut setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
        }
        
    }
    return _videoDataOutPut;
}
- (AVCaptureVideoPreviewLayer *) previewLayer{
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    }
    return _previewLayer;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{

}

@end
