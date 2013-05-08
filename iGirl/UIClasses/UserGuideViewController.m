//
//  UserGuideViewController.m
//  iAccessories
//
//  Created by zhang on 13-4-25.
//  Copyright (c) 2013年 MobileWoo. All rights reserved.
//

#import "UserGuideViewController.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

#define ANIMATION_SPEED_TOP 0.1f
#define ANIMATION_SPEED_FAST 0.3f
#define ANIMATION_SPEED_NORMAL 0.6f
#define ANIMATION_SPEED_SLOW 1.5f

@implementation Ke

@synthesize text, image;

@end

@interface UserGuideViewController (Private)

- (void) preStartAnimation;
- (void) startHuanke;
- (void) hidePhoneImageView;
- (void) huangAnimation;
@end

@implementation UserGuideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:[UIColor clearColor]];
    isSkiped = NO;
    if (!ISPHONE5) {
        [phoneImageView setFrame:CGRectMake(phoneImageView.frame.origin.x, phoneImageView.frame.origin.y - 44, phoneImageView.frame.size.width, phoneImageView.frame.size.height)];
        [huangBodyView setFrame:CGRectMake(huangBodyView.frame.origin.x, huangBodyView.frame.origin.y - 44, huangBodyView.frame.size.width, huangBodyView.frame.size.height)];
        [skipButton setFrame:CGRectMake(skipButton.frame.origin.x, skipButton.frame.origin.y - 88, skipButton.frame.size.width, skipButton.frame.size.height)];
    }

    ke = [[NSMutableArray alloc] init];
    for (int i=0; i<16; i++) {
        Ke *k = [[Ke alloc] init];
        k.image = [NSString stringWithFormat:@"phone_%d", (i + 1)];
        [ke addObject:k];
    }
    for (int i=0; i<16; i++) {
        Ke *k = [[Ke alloc] init];
        k.image = [NSString stringWithFormat:@"phone_%d", (i + 1)];
        [ke addObject:k];
    }
    for (int i=0; i<16; i++) {
        Ke *k = [[Ke alloc] init];
        k.image = [NSString stringWithFormat:@"phone_%d", (i + 1)];
        [ke addObject:k];
    }
    for (int i=0; i<16; i++) {
        Ke *k = [[Ke alloc] init];
        k.image = [NSString stringWithFormat:@"phone_%d", (i + 1)];
        [ke addObject:k];
    }
    for (int i=0; i<16; i++) {
        Ke *k = [[Ke alloc] init];
        k.image = [NSString stringWithFormat:@"phone_%d", (i + 1)];
        [ke addObject:k];
    }
    for (int i=0; i<16; i++) {
        Ke *k = [[Ke alloc] init];
        k.image = [NSString stringWithFormat:@"phone_%d", (i + 1)];
        [ke addObject:k];
    }
    animationIndex = 0;
    
    [phoneLeftImageView setAlpha:0];
    [phoneRightImageView setAlpha:0];
    [self performSelector:@selector(preStartAnimation) withObject:nil afterDelay:0.5f];
}

- (void) preStartAnimation
{
    [phoneLeftImageView setAlpha:1];
    [phoneRightImageView setAlpha:0];
    [phoneLeftImageView setHidden:NO];
    [phoneRightImageView setHidden:NO];
    [phoneShadow setHidden:NO];
    [phoneShadow setAlpha:0];
    [UIView animateWithDuration:1
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [phoneLeftImageView setFrame:CGRectMake(82, phoneLeftImageView.frame.origin.y, phoneLeftImageView.frame.size.width, phoneLeftImageView.frame.size.height)];
                         [phoneRightImageView setFrame:CGRectMake(104, phoneLeftImageView.frame.origin.y, phoneLeftImageView.frame.size.width, phoneLeftImageView.frame.size.height)];
                         [phoneLeftImageView setAlpha:1.0f];
                         [phoneRightImageView setAlpha:1.0f];

                     }
                     completion:^(BOOL finished) {
                         [textLabel setAlpha:0];
                         [textLabel setHidden:NO];

                         [UIView animateWithDuration:0.5
                                          animations:^{
                                              [textLabel setAlpha:1];
                                              
                                              [phoneShadow setAlpha:1];
                                          }
                                          completion:^(BOOL finished) {
                                              [self startHuanke];
                                          }
                            ];
                     }];
}


- (void)startHuanke
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startHuanke) object:nil];
    if (isSkiped) {
        [self hidePhoneImageView];
        return;
    }
    Ke *keItem = [ke objectAtIndex:animationIndex];
    // 根据位置调整速度
    float animationSpeed = ANIMATION_SPEED_SLOW;
    if (animationIndex == 0) {
        [textLabel setAlpha:0.0f];
        [textLabel setText:@"你以为世界上只有这几种手机壳？"];
        [UIView animateWithDuration:0.3f
                         animations:^{
                             [textLabel setAlpha:1.0f];
                         }];
    } else if (animationIndex == 4){
        [UIView animateWithDuration:0.2f
                         animations:^{
                             [textLabel setAlpha:0];
                         }
                         completion:^(BOOL finished) {
                             [textLabel setText:@"其实还有这些..."];
                             [UIView animateWithDuration:0.3f
                                              animations:^{
                                                  [textLabel setAlpha:1.0f];
                                              }];
                         }];
    } else if (animationIndex == 15) {
        [UIView animateWithDuration:0.2f
                         animations:^{
                             [textLabel setAlpha:0];
                         }
                         completion:^(BOOL finished) {
                             [textLabel setText:@"还有更多..."];
                             [UIView animateWithDuration:0.3f
                                              animations:^{
                                                  [textLabel setAlpha:1.0f];
                                              }];
                         }];
    }
    
    if (animationIndex >= 4 && animationIndex < 8) {
        animationSpeed = ANIMATION_SPEED_NORMAL;
        [phoneRightImageView setAlpha:0.8f];
        [phoneLeftImageView setAlpha:0.8f];
    } else if (animationIndex >= 8 && animationIndex < 15) {
        animationSpeed = ANIMATION_SPEED_FAST;
        [phoneRightImageView setAlpha:0.6f];
        [phoneLeftImageView setAlpha:0.6f];
    } else if (animationIndex >= 15) {
        if (animationIndex == 30) {
            [self hidePhoneImageView];
        } else if (animationIndex < 30){
            [phoneRightImageView setAlpha:0.3f];
            [phoneLeftImageView setAlpha:0.3f];
        }
        animationSpeed = ANIMATION_SPEED_TOP;
    }
    
    UIImageView *disappearImageView;
    UIImageView *useingImageView;
    // 根据奇偶用不同的imageView
    if (animationIndex % 2 == 0) {
        disappearImageView = image1;
        useingImageView = image2;
    } else {
        disappearImageView = image2;
        useingImageView = image1;
    }
    [useingImageView setFrame:CGRectMake(phoneRightImageView.frame.origin.x + 50, phoneRightImageView.frame.origin.y, useingImageView.frame.size.width, useingImageView.frame.size.height)];
    // 消失
    if (animationIndex < 30) {
        [useingImageView setAlpha:0.0f];
        [disappearImageView setAlpha:1.0f];
        if (animationIndex == 0) {
            [disappearImageView setAlpha:0];
        }
    }
    [useingImageView setImage:[UIImage imageNamed:keItem.image]];
    
    [UIView animateWithDuration:animationSpeed
                     animations:^{
                         if (animationIndex < 30) {
                             [disappearImageView setAlpha:0.0f];
                             [useingImageView setAlpha:1.0f];
                         }
                         [disappearImageView setFrame:CGRectMake(0, phoneLeftImageView.frame.origin.y, disappearImageView.frame.size.width, disappearImageView.frame.size.height)];
                         [useingImageView setFrame:CGRectMake(phoneLeftImageView.frame.origin.x, phoneLeftImageView.frame.origin.y, useingImageView.frame.size.width, useingImageView.frame.size.height)];
                     }
                     completion:^(BOOL finished) {
                     }];
    animationIndex += 1;
    if (animationIndex < [ke count]) {
        [self performSelector:@selector(startHuanke) withObject:nil afterDelay:animationSpeed];
    }
}

- (void) hidePhoneImageView
{
    [UIView animateWithDuration:1.4f
                     animations:^{
                         [phoneImageView setAlpha:0.0f];
                     }
                     completion:^(BOOL finished) {
                         [skipButton setEnabled:NO];
                         [UIView animateWithDuration:0.2
                                          animations:^{
                                              [skipButton setAlpha:0];
                                          }];
                         [self huangAnimation];

                     }];
}

- (void) huangAnimation
{
    [huangBodyView setFrame:CGRectMake(350, huangBodyView.frame.origin.y, huangBodyView.frame.size.width, huangBodyView.frame.size.height)];
    
    [huangImage.layer setAnchorPoint:CGPointMake(0.5, 0.5)];

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform swingTransform = CGAffineTransformIdentity;
    swingTransform = CGAffineTransformRotate(swingTransform, (M_PI * -12 / 180));
    [UIView beginAnimations:@"swing" context:context];
    [UIView setAnimationDuration:0.1f];
    huangImage.transform = swingTransform;
    [UIView commitAnimations];

    [UIView animateWithDuration:0.5f
                     animations:^{
                         [huangBodyView setFrame:CGRectMake(0, huangBodyView.frame.origin.y, huangBodyView.frame.size.width, huangBodyView.frame.size.height)];
                     }
     completion:^(BOOL finished) {
         [self jobsSwing:huangImage times:0];
     }];

    [huangBodyView setHidden:NO];
    [huangImage setHidden:NO];

}


- (void)jobsSwing:(UIView *)view times:(int)times
{
    float duration = 0.8f;
    float angle = 0.0f;
    switch (times) {
        case 0:
            angle = M_PI * 8 / 180;
            break;
        case 1:
            angle = M_PI * -4 / 180;
            break;
        case 2:
            angle = M_PI * 0 / 180;
            break;
        case 3:
        {
            [closeButton setHidden:NO];
            [closeButton setAlpha:0];
            [UIView animateWithDuration:0.5f
                             animations:^{
                                 [closeButton setAlpha:1];
                             }];
        }
            return;
            break;
        default:
            return;
            break;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGAffineTransform swingTransform = CGAffineTransformIdentity;
    swingTransform = CGAffineTransformRotate(swingTransform, angle);
    [UIView beginAnimations:@"swing" context:context];
    [UIView setAnimationDuration:duration];
    view.transform = swingTransform;
    [UIView commitAnimations];
    
    times++;
    NSMethodSignature *methodSignature = [self methodSignatureForSelector:@selector(jobsSwing:times:)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setTarget:self];
    [invocation setSelector:@selector(jobsSwing:times:)];
    [invocation setArgument:&view atIndex:2];
    [invocation setArgument:&times atIndex:3];
    [NSTimer scheduledTimerWithTimeInterval:duration invocation:invocation repeats:NO];
}

- (IBAction)close:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:USERGUIDE_VERSION];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)skipButtonClick:(id)sender
{
    isSkiped = YES;
}

@end
