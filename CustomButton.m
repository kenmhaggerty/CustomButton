//
//  CustomButton.m
//  Threeo
//
//  Created by Ken M. Haggerty on 9/26/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#pragma mark - // NOTES (Private) //

#pragma mark - // IMPORTS (Private) //

#import "CustomButton.h"
#import "CustomBadge.h"

#pragma mark - // DEFINITIONS (Private) //

@interface CustomButton ()
@property (nonatomic, strong) CustomBadge *badgeView;
- (void)setToDefaults;
- (void)buttonIsBeingMoved;
- (void)buttonIsDoneMoving;
- (void)buttonWasTapped;
@end

@implementation CustomButton

#pragma mark - // SETTERS AND GETTERS //

@synthesize delegate = _delegate;
@synthesize imageUntouched = _imageUntouched;
@synthesize imageActive = _imageActive;
@synthesize imageTouched = _imageTouched;
@synthesize badge = _badge;
@synthesize touchStart = _touchStart;
@synthesize touchCurrent = _touchCurrent;
@synthesize touchDirection = _touchDirection;
@synthesize isBeingTouched = _isBeingTouched;
@synthesize isBeingMoved = _isBeingMoved;
@synthesize viewForCoordinates = _viewForCoordinates;

- (void)setImageUntouched:(UIImage *)imageUntouched
{
    _imageUntouched = imageUntouched;
    if ((self.badge == 0) && (!self.isBeingTouched))
    {
        self.image = imageUntouched;
        [self setNeedsDisplay];
    }
}

- (void)setImageActive:(UIImage *)imageActive
{
    _imageActive = imageActive;
    if ((self.badge != 0) && (!self.isBeingTouched))
    {
        self.image = imageActive;
        [self setNeedsDisplay];
    }
}

- (void)setImageTouched:(UIImage *)imageTouched
{
    _imageTouched = imageTouched;
    if (self.isBeingTouched)
    {
        self.image = imageTouched;
        [self setNeedsDisplay];
    }
}

- (void)setTouchDirection:(NSMutableString *)touchDirection
{
    _touchDirection = touchDirection;
}

- (NSMutableString *)touchDirection
{
    if (!_touchDirection) _touchDirection = [[NSMutableString alloc] init];
    return _touchDirection;
}

- (void)setIsBeingTouched:(BOOL)isBeingTouched
{
    _isBeingTouched = isBeingTouched;
    if (isBeingTouched) self.image = self.imageTouched;
    else if (self.badge != 0) self.image = self.imageActive;
    else self.image = self.imageUntouched;
    [self setNeedsDisplay];
}

- (BOOL)isBeingTouched
{
    return _isBeingTouched;
}

- (void)setBadge:(NSUInteger)badge
{
    _badge = badge;
    if (badge != 0)
    {
        self.image = self.imageActive;
        NSMutableString *badgeString = [NSMutableString stringWithFormat:@"%i", badge];
        if (badge > 99) badgeString = [NSMutableString stringWithFormat:@"99+"];
        if (self.badgeView)
        {
            [self.badgeView autoBadgeSizeWithString:badgeString];
            self.badgeView.center = CGPointMake(self.badgeView.superview.bounds.size.width*0.75, self.badgeView.superview.bounds.size.height*0.25);
        }
        else
        {
            self.badgeView = [CustomBadge customBadgeWithString:badgeString];
//            self.badgeView.badgeShining = YES;
            self.badgeView.userInteractionEnabled = NO;
            [self addSubview:self.badgeView];
            self.badgeView.center = CGPointMake(self.badgeView.superview.bounds.size.width*0.75, self.badgeView.superview.bounds.size.height*0.25);
        }
    }
    else
    {
        self.image = self.imageUntouched;
        [self.badgeView removeFromSuperview];
        self.badgeView = nil;
    }
    [self setNeedsDisplay];
}

- (NSUInteger)badge
{
    return _badge;
}

#pragma mark - // INITS AND LOADS //

- (void)setToDefaults
{
    self.badge = 0;
    self.isBeingTouched = NO;
    self.isBeingMoved = NO;
    self.touchDirection = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setToDefaults];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setToDefaults];
}

#pragma mark - // PUBLIC FUNCTIONS //

#pragma mark - // DELEGATED FUNCTIONS //

#pragma mark - // PRIVATE FUNCTIONS //

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([touch view] == self)
    {
        self.isBeingTouched = YES;
        self.touchStart = [touch locationInView:self.viewForCoordinates];
        self.touchCurrent = [touch locationInView:self.viewForCoordinates];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([touch view] == self)
    {
        self.isBeingMoved = YES;
        if (self.touchCurrent.y < [touch locationInView:self.viewForCoordinates].y) self.touchDirection = [NSMutableString stringWithFormat:@"S"];
        else if ([touch locationInView:self.viewForCoordinates].y < self.touchCurrent.y) self.touchDirection = [NSMutableString stringWithFormat:@"N"];
        if (self.touchCurrent.x < [touch locationInView:self.viewForCoordinates].x)
        {
            if ([self.touchDirection isEqualToString:@"N"]) self.touchDirection = [NSMutableString stringWithFormat:@"NE"];
            else if ([self.touchDirection isEqualToString:@"S"]) self.touchDirection = [NSMutableString stringWithFormat:@"SE"];
            else self.touchDirection = [NSMutableString stringWithFormat:@"E"];
        }
        else if ([touch locationInView:self.viewForCoordinates].x < self.touchCurrent.x)
        {
            if ([self.touchDirection isEqualToString:@"N"]) self.touchDirection = [NSMutableString stringWithFormat:@"NW"];
            else if ([self.touchDirection isEqualToString:@"S"]) self.touchDirection = [NSMutableString stringWithFormat:@"SW"];
            else self.touchDirection = [NSMutableString stringWithFormat:@"W"];
        }
        self.touchCurrent = [touch locationInView:self.viewForCoordinates];
        [self.delegate buttonIsBeingMoved:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([touch view] == self)
    {
        [self actionsToPerformWhenTouchesEnded:touches withEvent:event andTouch:touch];
        if (!self.isBeingMoved)
        {
            [self buttonWasTapped];
        }
        else self.isBeingMoved = NO;
    }
    else
    {
        self.isBeingMoved = NO;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([touch view] == self)
    {
        [self actionsToPerformWhenTouchesEnded:touches withEvent:event andTouch:touch];
        if (!self.isBeingMoved)
        {
            [self buttonWasTapped];
        }
        else self.isBeingMoved = NO;
    }
    else
    {
        self.isBeingMoved = NO;
    }
}

- (void)actionsToPerformWhenTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event andTouch:(UITouch *)touch
{
    [self.delegate buttonIsDoneMoving:self];
    self.isBeingTouched = NO;
    self.touchStart = CGPointZero;
    self.touchCurrent = CGPointZero;
}

- (void)buttonIsBeingMoved;
{
    [self.delegate buttonIsBeingMoved:self];
}

- (void)buttonIsDoneMoving
{
    [self.delegate buttonIsDoneMoving:self];
}

- (void)buttonWasTapped
{
    [self.delegate buttonWasTapped:self];
}

@end
