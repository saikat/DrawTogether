@import <AppKit/CPView.j>

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
    [[SCSocket sharedSocket] sendMessage:{'action' : 'delete', 'widget' : [self toJSON]}];
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
    if (newRect.size.width > 0 && newRect.size.height > 0)
    {
        CGContextSetLineWidth(context, 2.0);
        CGContextSetStrokeColor(context, drawingColor);
        CGContextStrokeEllipseInRect(context, newRect);
    }
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
