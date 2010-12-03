/*
 * SCSocket.j
 * DrawTogether
 *
 * Created by Saikat Chakrabarti on April 22, 2010.
 *
 * See LICENSE file for license information.
 * 
 */

@import <Foundation/CPObject.j>
@import "socket.io.js"

var SharedSocket = nil;

@implementation SCSocket : CPObject
{
    JSObject socket;
    id delegate;
}

- (id)initWithURL:(CPURL)aURL
{
    self = [super init];
    if (self)
    {
        io.setPath('/');
        socket = new io.Socket([aURL host], {port:[aURL port], transports:['websocket', 'server-events', 'htmlfile', 'xhr-multipart', 'xhr-polling']});
        socket.connect();
    }
    return self;
}

- (void)setDelegate:(id)aDelegate
{
    delegate = aDelegate;
    if ([delegate respondsToSelector:@selector(socketDidConnect:)])
        socket.on('connect', function() {[delegate socketDidConnect:self]; [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];});
    if ([delegate respondsToSelector:@selector(socketDidClose:)])
        socket.on('close', function() {[delegate socketDidClose:self]; [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];});
    if ([delegate respondsToSelector:@selector(socketDidDisconnect:)])
        socket.on('disconnect', function() {[delegate socketDidDisconnect:self];[[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];});
    if ([delegate respondsToSelector:@selector(socket:didReceiveMessage:)])
        socket.on('message', function(message) {[delegate socket:self didReceiveMessage:message]; [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];});
}

- (void)sendMessage:(JSObject)jsonData
{
    socket.send([CPString JSONFromObject:jsonData]);
}

+ (SCSocket)sharedSocket
{
    if (!SharedSocket)
        SharedSocket = [[SCSocket alloc] initWithURL:[CPURL URLWithString:"http://localhost:8080"]];
    return SharedSocket;
}
@end
