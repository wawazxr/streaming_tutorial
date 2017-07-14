//
//  ViewController.m
//  tutorial01
//
//  Created by zjc on 2017/7/14.
//  Copyright © 2017年 lecloud. All rights reserved.
//

#import "ViewController.h"
#import "LCCameraView.h"

@interface ViewController ()

@property (nonatomic, strong) LCCameraView *camareView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _camareView = [[LCCameraView alloc] init];
    [_camareView setupPreviewWithView:self.view];
    [_camareView startCapture];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
