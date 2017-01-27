//
//  CustomButton.h
//  Threeo
//
//  Created by Ken M. Haggerty on 9/26/12.
//  Copyright (c) 2012 MCMDI. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomButton;

@protocol CustomButtonDelegate <NSObject>
- (void)buttonIsBeingMoved:(CustomButton *)sender;
- (void)buttonIsDoneMoving:(CustomButton *)sender;
- (void)buttonWasTapped:(CustomButton *)sender;
@end

@interface CustomButton : UIImageView
@property (nonatomic, strong) id <CustomButtonDelegate> delegate;
@property (nonatomic, strong) UIImage *imageUntouched;
@property (nonatomic, strong) UIImage *imageActive;
@property (nonatomic, strong) UIImage *imageTouched;
@property (nonatomic) NSUInteger badge;
@property (nonatomic) CGPoint touchStart;
@property (nonatomic) CGPoint touchCurrent;
@property (nonatomic) NSMutableString *touchDirection;
@property (nonatomic) BOOL isBeingTouched;
@property (nonatomic) BOOL isBeingMoved;
@property (nonatomic, weak) UIView *viewForCoordinates;
@end
