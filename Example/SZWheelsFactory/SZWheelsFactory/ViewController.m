//
//  ViewController.m
//  SZWheelsFactory
//
//  Created by ChaohuiChen on 2019/2/12.
//  Copyright © 2019 ChaohuiChen. All rights reserved.
//

#import "ViewController.h"
#import <SZWheels/ZTGInitDataChain.h>
@interface ViewController ()
@property (nonatomic, strong) ZTGInitDataChain *dataChain;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _dataChain = [[ZTGInitDataChain alloc] init];
    [_dataChain completeAllTaskInGroup:^{
        
    }];
}


@end
