//
//  LCCameraView.h
//  tutorial01
//
//  Created by zjc on 2017/7/14.
//  Copyright © 2017年 lecloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface LCCameraView : NSObject

- (void) setupPreviewWithView:(UIView *) view;
- (void) startCapture;

@end
