//
//  AppDelegate.h
//  FileTransferDemo
//
//  Created by Jonathon Staff on 11/1/14.
//  Copyright (c) 2014 nplexity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPStream.h"
#import "XMPPIncomingFileTransfer.h"

@class XMPPStream;
@class XMPPJID;

@interface AppDelegate : UIResponder <UIApplicationDelegate,
                                      XMPPStreamDelegate,
                                      XMPPIncomingFileTransferDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;

- (void)prepareStreamAndLogInWithJID:(XMPPJID *)jid;

@end

