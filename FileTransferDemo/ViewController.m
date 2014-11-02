//
//  ViewController.m
//  FileTransferDemo
//
//  Created by Jonathon Staff on 11/1/14.
//  Copyright (c) 2014 nplexity. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *inputUsername;
@property (weak, nonatomic) IBOutlet UITextField *inputPassword;

@end

@implementation ViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  // This method should really wait for confirmation that the user was able to
  // log in successfully before proceeding (i.e. use
  // shouldPerformSegueWithIdentifier:sender:, but again, this is a simple
  // demo; you're capable of handling error-checking in your own app.

  NSString *username = _inputUsername.text;
  NSString *password = _inputPassword.text;

  AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
  [appDelegate prepareStreamAndLogInWithJID:[XMPPJID jidWithString:username] password:password];
}

@end
