//
//  ViewController.m
//  FileTransferDemo
//
//  Created by Jonathon Staff on 11/1/14.
//  Copyright (c) 2014 nplexity. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    NSLog(@"should i?");
    // TODO: perform login logic here, and if is valid, take the use to the next page
    return YES;
}

@end
