/*
 * AppController.j
 * DrawTogether
 *
 * Created by Saikat Chakrabarti on April 20, 2010.
 */

@import <Foundation/CPObject.j>
@import "socket.io.js"

var SharedSocket = nil;

@implementation Widget : CPView
{ 
    CPColor drawingColor;
    CGPoint dragStart;
    CGPoint startingOrigin;
}

- (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    if (self)
    {
        drawingColor = [CPColor blackColor];
    }
    return self;
}

- (void)mouseEntered:(CPEvent)anEvent
{
    drawingColor = [CPColor redColor];
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(CPEvent)anEvent
{
    drawingColor = [CPColor blackColor];
    [self setNeedsDisplay:YES];
}

- (void)delete
{
    [SharedSocket sendMessage:{'action' : 'delete', 'widget' : [self toJSON]}];
    [self removeFromSuperview];
}

- (void)mouseDown:(CPEvent)anEvent
{
    if ([anEvent clickCount] === 2)
        [self delete];
    else
    {
        dragStart = [anEvent locationInWindow];
        startingOrigin = [self frame].origin;
    }
}

- (void)mouseDragged:(CPEvent)anEvent
{
    var draggedToPoint = [anEvent locationInWindow],
        newOrigin = CGPointMake(startingOrigin.x + (draggedToPoint.x - dragStart.x),
                                startingOrigin.y + (draggedToPoint.y - dragStart.y));
    [self setFrameOrigin:newOrigin];
}

- (JSObject)toJSON
{
    return {'type' : CPStringFromClass([self class]),
            'frame' : [self frame]};
}

- (BOOL)isEqualToJSONWidget:(JSObject)anotherWidget
{
    if (CGRectEqualToRect([self frame], anotherWidget.frame) &&
        anotherWidget.type === CPStringFromClass([self class]))
        return YES;
    return NO;
}
@end

@implementation CircleWidget : Widget { }

- (void)drawRect:(CGRect)aRect
{
    var context = [[CPGraphicsContext currentContext] graphicsPort],
        newRect = CPRectInset(aRect, 1.0, 1.0);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColor(context, drawingColor);
    CGContextStrokeEllipseInRect(context, newRect);
}
@end

@implementation RectWidget : Widget { }

- (void)drawRect:(CGRect)aRect
{
    var context = [[CPGraphicsContext currentContext] graphicsPort]; 
    CGContextSaveGState(context);
    CGContextSetStrokeColor(context,drawingColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokeRect(context, CPRectInset(aRect, 1.0, 1.0));
    CGContextRestoreGState(context);
}
@end

@implementation Canvas : CPView
{
    CGPoint dragStart;
    Widget currentWidget;
    Class drawClass;
}

- (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];
    if (self)
    {
        drawClass = RectWidget;
    }
    return self;
}

- (void)addWidget:(Widget)aWidget
{
    [self addSubview:aWidget];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(CPEvent)anEvent
{
    if ([anEvent characters] == "c")
        drawClass = CircleWidget;
    else if ([anEvent characters] == "r")
        drawClass = RectWidget;
}

- (void)mouseDown:(CPEvent)anEvent
{
    dragStart = [anEvent locationInWindow];
    var widget = [[drawClass alloc] initWithFrame:CGRectMake(dragStart.x, dragStart.y, 0, 0)];
    currentWidget = widget;
    [self addSubview:widget];
}

- (void)mouseDragged:(CPEvent)anEvent
{
    if (currentWidget)
    {
        mouseLoc = [anEvent locationInWindow];
        var newWidth = mouseLoc.x - dragStart.x,
            newHeight = mouseLoc.y - dragStart.y,
            newX = dragStart.x,
            newY = dragStart.y;
        if (newWidth < 0)
            newX = dragStart.x + newWidth;
        if (newHeight < 0)
            newY = dragStart.y + newHeight;
        [currentWidget setFrame:CGRectMake(newX, newY, Math.abs(newWidth), Math.abs(newHeight))];
    }
}

- (Widget)widgetByJSObject:(JSObject)jsWidget
{
    var widgets = [self subviews],
        count = [widgets count];
    while (count--)
    {
        if ([widgets[count] isEqualToJSONWidget:jsWidget])
            return widgets[count];
    }
    return nil;
}

- (void)mouseUp:(CPEvent)anEvent
{
    if (currentWidget)
    {
        [SharedSocket sendMessage:{'action' : 'add', 'widget' : [currentWidget toJSON]}];
        currentWidget = nil;
    }
}
@end

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
        socket.addEvent('connect', function() {[delegate socketDidConnect:self];});
    if ([delegate respondsToSelector:@selector(socketDidClose:)])
        socket.addEvent('close', function() {[delegate socketDidClose:self];});
    if ([delegate respondsToSelector:@selector(socketDidDisconnect:)])
        socket.addEvent('disconnect', function() {[delegate socketDidDisconnect:self];});
    if ([delegate respondsToSelector:@selector(socket:didReceiveMessage:)])
        socket.addEvent('message', function(message) {[delegate socket:self didReceiveMessage:message];});
}

- (void)sendMessage:(JSObject)jsonData
{
    socket.send([CPString JSONFromObject:jsonData]);
}
@end

@implementation AppController : CPObject
{
    Canvas canvas;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView],
        canvas = [[Canvas alloc] initWithFrame:[contentView bounds]];

    [contentView addSubview:canvas];
    [theWindow setAcceptsMouseMovedEvents:YES];
    [theWindow orderFront:self];
    SharedSocket = [[SCSocket alloc] initWithURL:[CPURL URLWithString:"http://localhost:8080"]];
    [SharedSocket setDelegate:self];
}

- (void)socket:(SCSocket)aSocket didReceiveMessage:(CPString)aMessage
{
    var data = [aMessage objectFromJSON];
    if (!data.action)
        return;

    if (data.action === 'delete')
    {
        var widgetToDelete = [canvas widgetByJSObject:data.widget];
        [widgetToDelete delete];
    }
    else if (data.action === 'add')
    {
        [canvas addWidget:[[CPClassFromString(data.widget.type) alloc] initWithFrame:data.widget.frame]];
    }
    [[CPRunLoop currentRunLoop] limitDateForMode:CPDefaultRunLoopMode];
}
@end


