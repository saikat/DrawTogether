//
// CPWebSocket.j
//
// Copyright 2010 Sami Samhuri
//
// MIT license
//

@import <Foundation/CPObject.j>

CPWebSocketStateConnecting = 0,
CPWebSocketStateOpen       = 1,
CPWebSocketStateClosing    = 2,
CPWebSocketStateClosed     = 3;

@implementation CPWebSocket : CPObject
{
    JSObject _ws;
    id delegate;
}

+ (id) openWebSocketWithURL: (CPString)url_ delegate: (id) delegate_
{
    return  [[self alloc] initWithURL: url_ delegate: delegate_];
}

- (id) initWithURL: (CPString)url_ delegate: (id) delegate_
{
    self = [super init];
    if (self) {
        _ws = new WebSocket(url_);
        delegate = delegate_;
        [self _setupCallbacks];
    }
    return self;
}

- (void) _setupCallbacks
{
    _ws.onopen = function() {
        [delegate webSocketDidOpen: self];
    };
    _ws.onclose = function(event) {
        [delegate webSocketDidClose: self];
    };
    _ws.onmessage = function(event) {
        [delegate webSocket: self didReceiveMessage: event.data];
    };
    _ws.onerror = function(event) {
        [delegate webSocketDidReceiveError: self];
    };
}

- (CPString) URL
{
    return _ws.URL;
}

- (CPNumber) state
{
    return _ws.state;
}

- (CPNumber) bytesBuffered
{
    return _ws.bufferedAmount;
}

- (void) close
{
    _ws.close();
}

- (BOOL) send: (CPString) data
{
    // TODO check the state, should not be CPWebSocketConnecting
    return _ws.send(data);
}

@end
