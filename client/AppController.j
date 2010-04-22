/*
 * AppController.j
 * DrawTogether
 *
 * Created by Saikat Chakrabarti on April 20, 2010.
 */

@import <Foundation/CPObject.j>
@import "Canvas.j"

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
    [[SCSocket sharedSocket] setDelegate:self];
}

- (void)socket:(SCSocket)aSocket didReceiveMessage:(CPString)aMessage
{
    var data = [aMessage objectFromJSON];
    if (!data.action)
        return;

    if (data.action === 'move')
    {
        var widgetToMove = [canvas widgetByJSObject:{'type' : data.widget.type,
                                                     'frame' : CGRectMake(data.startOrigin.x,
                                                                          data.startOrigin.y,
                                                                          data.widget.frame.size.width,
                                                                          data.widget.frame.size.height)}];
        [widgetToMove setFrameOrigin:data.widget.frame.origin];
    }
    if (data.action === 'fetch')
    {
        [[SCSocket sharedSocket] sendMessage:[canvas toJSON]];
    }
    else if (data.action === 'initialize')
    {
        [canvas refreshFromJSON:data.widgets];
    }
    else if (data.action === 'delete')
    {
        var widgetToDelete = [canvas widgetByJSObject:data.widget];
        [widgetToDelete delete];
    }
    else if (data.action === 'add')
        [canvas addWidget:[[CPClassFromString(data.widget.type) alloc] initWithFrame:data.widget.frame]];
}
@end


