//
//  AppDelegate.m
//  FileTransferDemo
//
//  Created by Jonathon Staff on 11/1/14.
//  Copyright (c) 2014 nplexity. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPPRoster.h"
#import "XMPPRosterMemoryStorage.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "XMPPLogging.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface AppDelegate () {
  XMPPStream *_xmppStream;
  XMPPRoster *_xmppRoster;
  XMPPRosterMemoryStorage *_xmppRosterStorage;
  XMPPIncomingFileTransfer *_xmppIncomingFileTransfer;

  // Yes, this is bad. I'm simply lazy and this is a demo...
  NSString *_password;
}

@end

@implementation AppDelegate


#pragma mark - UIApplicationDelegate Methods

- (BOOL)          application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [DDLog addLogger:[DDTTYLogger sharedInstance]
      withLogLevel:XMPP_LOG_LEVEL_VERBOSE | XMPP_LOG_FLAG_TRACE | XMPP_LOG_FLAG_SEND_RECV];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)dealloc
{
  [self tearDownStream];
}


#pragma mark - Public Methods

- (void)prepareStreamAndLogInWithJID:(XMPPJID *)jid password:(NSString *)password
{
  DDLogVerbose(@"Preparing the stream and logging in as %@", jid.full);

  _xmppStream = [XMPPStream new];
  _xmppStream.myJID = jid;

  _xmppRosterStorage = [XMPPRosterMemoryStorage new];
  _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterStorage];
  _xmppRoster.autoFetchRoster = YES;

  _xmppIncomingFileTransfer = [XMPPIncomingFileTransfer new];

  // Activate all modules
  [_xmppRoster activate:_xmppStream];
  [_xmppIncomingFileTransfer activate:_xmppStream];

  // Add ourselves as delegate to necessary methods
  [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
  [_xmppIncomingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];

  NSError *err;
  if (![_xmppStream connectWithTimeout:30 error:&err]) {
    DDLogInfo(@"%@: Error connecting: %@", THIS_FILE, err);
  } else {
    _password = password;
  }
}

#pragma mark - Private Methods

- (void)tearDownStream
{
  [_xmppStream removeDelegate:self];
  [_xmppIncomingFileTransfer removeDelegate:self];

  [_xmppRoster deactivate];
  [_xmppIncomingFileTransfer deactivate];

  [_xmppStream disconnect];

  _xmppStream = nil;
  _xmppRoster = nil;
  _xmppRosterStorage = nil;
  _xmppIncomingFileTransfer = nil;
}


#pragma mark - XMPPStreamDelegate Methods

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
  DDLogVerbose(@"%@: Connected successfully.", THIS_FILE);
  DDLogVerbose(@"%@: Logging in as %@...", THIS_FILE, sender.myJID.full);

  [_xmppStream authenticateWithPassword:_password error:nil];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
  DDLogVerbose(@"%@: Authenticated successfully.", THIS_FILE);

  XMPPPresence *presence = [XMPPPresence presence];
  [_xmppStream sendElement:presence];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
  DDLogInfo(@"%@: Stream disconnected with error: %@", THIS_FILE, error);
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
  DDLogInfo(@"%@: Authentication failed with error: %@", THIS_FILE, error);
}


#pragma mark - XMPPIncomingFileTransferDelegate Methods

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender
                didFailWithError:(NSError *)error
{
  DDLogVerbose(@"%@: Incoming file transfer failed with error: %@", THIS_FILE, error);
}

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender
               didReceiveSIOffer:(XMPPIQ *)offer
{
  DDLogVerbose(@"%@: Incoming file transfer did receive SI offer. Accepting...", THIS_FILE);
  [sender acceptSIOffer:offer];
}

- (void)xmppIncomingFileTransfer:(XMPPIncomingFileTransfer *)sender
              didSucceedWithData:(NSData *)data
                           named:(NSString *)name
{
  DDLogVerbose(@"%@: Incoming file transfer did succeed.", THIS_FILE);

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask,
                                                       YES);
  NSString *fullPath = [[paths lastObject] stringByAppendingPathComponent:name];
  [data writeToFile:fullPath options:0 error:nil];

  DDLogVerbose(@"%@: Data was written to the path: %@", THIS_FILE, fullPath);
}

@end
