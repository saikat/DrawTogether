/*
 * AppController.j
 * DrawTogether
 *
 * Created by Saikat Chakrabarti on April 20, 2010.
 */

@import <Foundation/CPObject.j>

@implementation RectWidget : CPView
{
    CPColor drawingColor;
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

- (void)drawRect:(CGRect)aRect
{
    var context = [[CPGraphicsContext currentContext] graphicsPort]; 
    CGContextSaveGState(context);
    CGContextSetStrokeColor(context,drawingColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextStrokeRect(context, aRect);
    CGContextRestoreGState(context);
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

- (void)mouseDown:(CPEvent)anEvent
{
    [self removeFromSuperview];
}
@end

@implementation Canvas : CPView
{
    CGPoint dragStart;
    RectWidget currentWidget;
}
- (void)mouseDown:(CPEvent)anEvent
{
    dragStart = [anEvent locationInWindow];
    var rectWidget = [[RectWidget alloc] initWithFrame:CGRectMake(dragStart.x, dragStart.y, 0, 0)];
    currentWidget = rectWidget;
    [self addSubview:rectWidget];
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

- (void)mouseUp:(CPEvent)anEvent
{
    currentWidget = nil;
}
@end


@implementation AppController : CPObject
{
    CPView canvas;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView],
        canvas = [[Canvas alloc] initWithFrame:[contentView bounds]];

    [contentView addSubview:canvas];
    [theWindow setAcceptsMouseMovedEvents:YES];
    [theWindow orderFront:self];
}


@end
