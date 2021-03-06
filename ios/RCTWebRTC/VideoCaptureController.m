
#import "VideoCaptureController.h"

#import <React/RCTLog.h>


@implementation VideoCaptureController {
    RTCCameraVideoCapturer *_capturer;
    NSString *_deviceId;
    BOOL _usingFrontCamera;
    int _width;
    int _height;
    int _fps;
}

-(instancetype)initWithCapturer:(RTCCameraVideoCapturer *)capturer
                 andConstraints:(NSDictionary *)constraints {
    self = [super init];
    if (self) {
        _capturer = capturer;

        // Default to the front camera.

        /**
         * <TABEEB> Set default "environment" camera when a user stars a call.
         *
         * Original code:
         * _usingFrontCamera = YES;
         */
        _usingFrontCamera = NO;
        // </TABEEB>

        // <TABEEB> Set VideoCapturer for snapshots.
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RTCVideoCapturerAdded" object:nil userInfo:@{@"VideoCapturer" : capturer}];
        // </TABEEB>
        
        // Check the video contraints: examine facingMode and sourceId
        // and pick a default if neither are specified.
        _deviceId = constraints[@"deviceId"];
        _width = [constraints[@"width"] intValue];
        _height = [constraints[@"height"] intValue];
        _fps = [constraints[@"frameRate"] intValue];

        id facingMode = constraints[@"facingMode"];

        if (facingMode && [facingMode isKindOfClass:[NSString class]]) {
            AVCaptureDevicePosition position;
            if ([facingMode isEqualToString:@"environment"]) {
                position = AVCaptureDevicePositionBack;
            } else if ([facingMode isEqualToString:@"user"]) {
                position = AVCaptureDevicePositionFront;
            } else {
                // If the specified facingMode value is not supported, fall back
                // to the back camera.
                
                /**
                * <TABEEB> Set default "environment" camera when a user stars a call.
                *
                * Original code:
                * position = AVCaptureDevicePositionFront;
                */
                position = AVCaptureDevicePositionBack;
                // </TABEEB>
            }

            _usingFrontCamera = position == AVCaptureDevicePositionFront;
        }
    }

    return self;
}

-(void)startCapture {
    AVCaptureDevice *device;
    if (_deviceId) {
        device = [AVCaptureDevice deviceWithUniqueID:_deviceId];
    }
    if (!device) {
        AVCaptureDevicePosition position
            = _usingFrontCamera
                ? AVCaptureDevicePositionFront
                : AVCaptureDevicePositionBack;
        device = [self findDeviceForPosition:position];
    }

    if (!device) {
        RCTLogWarn(@"[VideoCaptureController] No capture devices found!");

        return;
    }

    AVCaptureDeviceFormat *format
        = [self selectFormatForDevice:device
                      withTargetWidth:_width
                     withTargetHeight:_height];
    if (!format) {
        RCTLogWarn(@"[VideoCaptureController] No valid formats for device %@", device);

        return;
    }

    // Starting the capture happens on another thread. Wait for it.
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [_capturer startCaptureWithDevice:device format:format fps:_fps completionHandler:^(NSError *err) {
        if (err) {
            RCTLogError(@"[VideoCaptureController] Error starting capture: %@", err);
        } else {
            RCTLog(@"[VideoCaptureController] Capture started");
        }
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

-(void)stopCapture {
    // Stopping the capture happens on another thread. Wait for it.
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    [_capturer stopCaptureWithCompletionHandler:^{
        RCTLog(@"[VideoCaptureController] Capture stopped");
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

-(void)switchCamera {
    _usingFrontCamera = !_usingFrontCamera;

    [self startCapture];
    
    // <TABEEB>
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RTCLocalStreamsUpdated" object:nil userInfo:@{@"useBackCamera" : @(!_usingFrontCamera)}];
    // </TABEEB>
}

#pragma mark Private

- (AVCaptureDevice *)findDeviceForPosition:(AVCaptureDevicePosition)position {
    NSArray<AVCaptureDevice *> *captureDevices = [RTCCameraVideoCapturer captureDevices];
    for (AVCaptureDevice *device in captureDevices) {
        if (device.position == position) {
            return device;
        }
    }

    return [captureDevices firstObject];
}

- (AVCaptureDeviceFormat *)selectFormatForDevice:(AVCaptureDevice *)device
                                 withTargetWidth:(int)targetWidth
                                withTargetHeight:(int)targetHeight {
    NSArray<AVCaptureDeviceFormat *> *formats =
    [RTCCameraVideoCapturer supportedFormatsForDevice:device];
    AVCaptureDeviceFormat *selectedFormat = nil;
    int currentDiff = INT_MAX;

    for (AVCaptureDeviceFormat *format in formats) {
        CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        FourCharCode pixelFormat = CMFormatDescriptionGetMediaSubType(format.formatDescription);
        int diff = abs(targetWidth - dimension.width) + abs(targetHeight - dimension.height);
        if (diff < currentDiff) {
            selectedFormat = format;
            currentDiff = diff;
        } else if (diff == currentDiff && pixelFormat == [_capturer preferredOutputPixelFormat]) {
            selectedFormat = format;
        }
    }

    return selectedFormat;
}

@end
