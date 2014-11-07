File Transfer using XMPPFramework
=================================

This application is merely a brief demo of how to use the file transfer extension of the XMPPFramework.

A detailed blog post can be found [here](jonathonstaff.com/tackling-file-transfers-with-the-xmppframework/).

Note that it uses [my specific fork](https://github.com/jonstaff/XMPPFramework) of the XMPPFramework unless/until they pull it into the master repo.  I'll update this readme accordingly if that happens.

Both incoming file transfers and outgoing file transfers are functional within this demo, but I've left a significant amount of error-handling out, so you'll want to include that in your app.

Server Settings
===============

In order for SOCKS5 to work properly, your server must be configured to handle proxy connections.  I've only tested this using **ejabberd**, but these are the `mod_proxy65` settings I used:

```
{mod_proxy65,  [
     {ip, {0,0,0,0}},
     {hostname, "myhostnamehere"},
     {port, 7777},
     {access, all},
     {shaper, c2s_shaper}
]},
```

If you're unable to get the proxy functioning, you always have the option to set `disableSOCKS5 = YES`, which will force an IBB transfer instead.  This is slower, but it's very widely supported.

Usage
=====

Incoming File Transfers
-----------------------

Instantiate a new `XMPPIncomingFileTransfer`, activate it, add a delegate, and wait for a file transfer request.

```objc
_xmppIncomingFileTransfer = [XMPPIncomingFileTransfer new];
[_xmppIncomingFileTransfer activate:_xmppStream];
[_xmppIncomingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
```

Responding to `disco#info` queries and the like are handled for you.  You'll get a delegate call when an SI offer is received, at which point you can decide whether or not you wish to accept.  You can also set `autoAcceptFileTransfers = YES` and you won't need to call `acceptSIOffer:` yourself.

```objc
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
```

Outgoing File Transfers
-----------------------

To start a new outgoing file transfer, simply create an instance of `XMPPOutgoingFileTransfer`, activate it, add a delegate, and send your data:

```objc
_fileTransfer = [[XMPPOutgoingFileTransfer alloc] initWithDispatchQueue:dispatch_get_main_queue()];
[_fileTransfer activate:[self appDelegate].xmppStream];
[_fileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];

NSError *err;
if (![_fileTransfer sendData:data
                       named:filename
                 toRecipient:[XMPPJID jidWithString:recipient]
                 description:@"Baal's Soulstone, obviously."
                       error:&err]) {
  DDLogInfo(@"You messed something up: %@", err);
}
```

The following delegate calls when get invoked when appropriate:

```objc
- (void)xmppOutgoingFileTransfer:(XMPPOutgoingFileTransfer *)sender
                didFailWithError:(NSError *)error
{
  DDLogInfo(@"Outgoing file transfer failed with error: %@", error);

  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                  message:@"There was an error sending your file. See the logs."
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
}

- (void)xmppOutgoingFileTransferDidSucceed:(XMPPOutgoingFileTransfer *)sender
{
  DDLogVerbose(@"File transfer successful.");

  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!"
                                                  message:@"Your file was sent successfully."
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
}
```

Developed By
============

[Jonathon Staff](http://jonathonstaff.com)


License
=======

    Copyright 2014 Jonathon Staff

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
