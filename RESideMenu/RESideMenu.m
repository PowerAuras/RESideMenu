//
// REFrostedViewController.m
// RESideMenu
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "RESideMenu.h"
#import "UIViewController+RESideMenu.h"
#import "RECommonFunctions.h"

@interface RESideMenu ()

@property (strong, readwrite, nonatomic) UIImageView *backgroundImageView;
@property (assign, readwrite, nonatomic) BOOL visible;
@property (assign, readwrite, nonatomic) CGPoint originalPoint;
@property (strong, readwrite, nonatomic) UIButton *contentButton;
@property (strong, readwrite, nonatomic) UIView *menuViewContainer;

@end

@implementation RESideMenu

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _animationDuration = 0.35f;
    _panGestureEnabled = YES;
    _interactivePopGestureRecognizerEnabled = YES;
  
    _scaleContentView      = YES;
    _contentViewScaleValue = 0.7f;
    
    _scaleBackgroundImageView = YES;
  
    _parallaxEnabled = YES;
    _parallaxMenuMinimumRelativeValue = @(-15);
    _parallaxMenuMaximumRelativeValue = @(15);
    
    _parallaxContentMinimumRelativeValue = @(-25);
    _parallaxContentMaximumRelativeValue = @(25);

    _bouncesHorizontally = YES;
    
    _menuViewContainer = [[UIView alloc] init];
}

- (id)initWithContentViewController:(UIViewController *)contentViewController menuViewController:(UIViewController *)menuViewController
{
    self = [self init];
    if (self) {
        _contentViewController = contentViewController;
        _menuViewController = menuViewController;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    if (!_contentViewInLandscapeOffsetCenterX)
        _contentViewInLandscapeOffsetCenterX = CGRectGetHeight(self.view.frame) + 30.f;
    
    if (!_contentViewInPortraitOffsetCenterX)
        _contentViewInPortraitOffsetCenterX  = CGRectGetWidth(self.view.frame) + 30.f;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundImageView = ({
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageView.image = self.backgroundImage;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView;
    });
    self.contentButton = ({
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectNull];
        [button addTarget:self action:@selector(hideMenuViewController) forControlEvents:UIControlEventTouchUpInside];
        button;
    });
    
    [self.view addSubview:self.backgroundImageView];
    [self.view addSubview:self.menuViewContainer];
    
    self.menuViewContainer.frame = self.view.bounds;
    
    if (self.menuViewController) {
        [self addChildViewController:self.menuViewController];
        self.menuViewController.view.frame = self.view.bounds;
        self.menuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.menuViewContainer addSubview:self.menuViewController.view];
        [self.menuViewController didMoveToParentViewController:self];
    }
    
    if (self.tempViewController) {
        [self addChildViewController:self.tempViewController];
        self.tempViewController.view.frame = self.view.bounds;
        self.tempViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.menuViewContainer addSubview:self.tempViewController.view];
        [self.tempViewController didMoveToParentViewController:self];
    }
    
    [self re_displayController:self.contentViewController frame:self.view.bounds];
    
    self.menuViewContainer.alpha = 0;
    if (self.scaleBackgroundImageView)
        self.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
    
    [self addMenuViewControllerMotionEffects];
    
    if (self.panGestureEnabled) {
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        panGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:panGestureRecognizer];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark -

- (void)presentMenuViewController
{
    self.menuViewContainer.transform = CGAffineTransformIdentity;
    if (self.scaleBackgroundImageView) {
        self.backgroundImageView.transform = CGAffineTransformIdentity;
        self.backgroundImageView.frame = self.view.bounds;
    }
    self.menuViewContainer.frame = self.view.bounds;
    self.menuViewContainer.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    self.menuViewContainer.alpha = 0;
    if (self.scaleBackgroundImageView)
        self.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
    
    if ([self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
        [self.delegate sideMenu:self willShowMenuViewController:self.menuViewController];
    }
    
    [self showMenuViewController];
}

- (void)showMenuViewController
{
    if (!self.menuViewController) {
        return;
    }
    self.menuViewController.view.hidden = NO;
    self.tempViewController.view.hidden = YES;
    [self.view.window endEditing:YES];
    [self addContentButton];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
        if (self.scaleContentView) {
            self.contentViewController.view.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        }
        self.contentViewController.view.center = CGPointMake((UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? self.contentViewInLandscapeOffsetCenterX : self.contentViewInPortraitOffsetCenterX), self.contentViewController.view.center.y);

        self.menuViewContainer.alpha = 1.0f;
        self.menuViewContainer.transform = CGAffineTransformIdentity;
        if (self.scaleBackgroundImageView)
            self.backgroundImageView.transform = CGAffineTransformIdentity;
            
    } completion:^(BOOL finished) {
        [self addContentViewControllerMotionEffects];
        
        if (!self.visible && [self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didShowMenuViewController:)]) {
            [self.delegate sideMenu:self didShowMenuViewController:self.menuViewController];
        }
        
        self.visible = YES;
        NSLog(@"VISIBLE = YES");
    }];
    
    [self updateStatusBar];
}

- (void)showRightMenuViewController
{
    if (!self.tempViewController) {
        return;
    }
    self.menuViewController.view.hidden = YES;
    self.tempViewController.view.hidden = NO;
    [self.view.window endEditing:YES];
    [self addContentButton];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:self.animationDuration animations:^{
        if (self.scaleContentView) {
            self.contentViewController.view.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        }
        self.contentViewController.view.center = CGPointMake((UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? self.contentViewInLandscapeOffsetCenterX - CGRectGetHeight(self.view.frame) - 60.0 : self.contentViewInPortraitOffsetCenterX) - CGRectGetWidth(self.view.frame) - 60.0, self.contentViewController.view.center.y);
        
        self.menuViewContainer.alpha = 1.0f;
        self.menuViewContainer.transform = CGAffineTransformIdentity;
        if (self.scaleBackgroundImageView)
            self.backgroundImageView.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        self.visible = !(self.contentViewController.view.frame.size.width == self.view.bounds.size.width && self.contentViewController.view.frame.size.height == self.view.bounds.size.height);
        NSLog(@"VISIBLE = %i, %f:%f = %f:%f", self.visible, self.contentViewController.view.frame.size.width, self.contentViewController.view.frame.size.height,
              self.view.bounds.size.width, self.view.bounds.size.height);
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [self addContentViewControllerMotionEffects];
        
        if (!self.visible && [self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didShowMenuViewController:)]) {
            [self.delegate sideMenu:self didShowMenuViewController:self.menuViewController];
        }
        
    }];
    
    [self updateStatusBar];
}

- (void)hideMenuViewController
{
    if ([self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willHideMenuViewController:)]) {
        [self.delegate sideMenu:self willHideMenuViewController:self.menuViewController];
    }
    
    self.visible = NO;
    NSLog(@"VISIBLE = NO");
    [self.contentButton removeFromSuperview];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [UIView animateWithDuration:self.animationDuration animations:^{
        self.contentViewController.view.transform = CGAffineTransformIdentity;
        self.contentViewController.view.frame = self.view.bounds;
        self.menuViewContainer.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        self.menuViewContainer.alpha = 0;
        if (self.scaleBackgroundImageView) {
            self.backgroundImageView.transform = CGAffineTransformMakeScale(1.7f, 1.7f);
        }
        if (self.parallaxEnabled) {
            IF_IOS7_OR_GREATER(
               for (UIMotionEffect *effect in self.contentViewController.view.motionEffects) {
                   [self.contentViewController.view removeMotionEffect:effect];
               }
            );
        }
    } completion:^(BOOL finished) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        
        if (!self.visible && [self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didHideMenuViewController:)]) {
            [self.delegate sideMenu:self didHideMenuViewController:self.menuViewController];
        }
    }];
    [self updateStatusBar];
}

- (void)addContentButton
{
    if (self.contentButton.superview)
        return;

    self.contentButton.autoresizingMask = UIViewAutoresizingNone;
    self.contentButton.frame = self.contentViewController.view.bounds;
    self.contentButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentViewController.view addSubview:self.contentButton];
}

#pragma mark -
#pragma mark Motion effects

- (void)addMenuViewControllerMotionEffects
{
    if (self.parallaxEnabled) {
        IF_IOS7_OR_GREATER(
           for (UIMotionEffect *effect in self.menuViewContainer.motionEffects) {
               [self.menuViewContainer removeMotionEffect:effect];
           }
           UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
           interpolationHorizontal.minimumRelativeValue = self.parallaxMenuMinimumRelativeValue;
           interpolationHorizontal.maximumRelativeValue = self.parallaxMenuMaximumRelativeValue;
           
           UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
           interpolationVertical.minimumRelativeValue = self.parallaxMenuMinimumRelativeValue;
           interpolationVertical.maximumRelativeValue = self.parallaxMenuMaximumRelativeValue;
           
           [self.menuViewContainer addMotionEffect:interpolationHorizontal];
           [self.menuViewContainer addMotionEffect:interpolationVertical];
        );
    }
}

- (void)addContentViewControllerMotionEffects
{
    if (self.parallaxEnabled) {
        IF_IOS7_OR_GREATER(
            for (UIMotionEffect *effect in self.contentViewController.view.motionEffects) {
               [self.contentViewController.view removeMotionEffect:effect];
            }
            [UIView animateWithDuration:0.2 animations:^{
                UIInterpolatingMotionEffect *interpolationHorizontal = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
                interpolationHorizontal.minimumRelativeValue = self.parallaxContentMinimumRelativeValue;
                interpolationHorizontal.maximumRelativeValue = self.parallaxContentMaximumRelativeValue;

                UIInterpolatingMotionEffect *interpolationVertical = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
                interpolationVertical.minimumRelativeValue = self.parallaxContentMinimumRelativeValue;
                interpolationVertical.maximumRelativeValue = self.parallaxContentMaximumRelativeValue;

                [self.contentViewController.view addMotionEffect:interpolationHorizontal];
                [self.contentViewController.view addMotionEffect:interpolationVertical];
            }];
        );
    }
}

#pragma mark -
#pragma mark Gesture recognizer

/*- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    IF_IOS7_OR_GREATER(
       if (self.interactivePopGestureRecognizerEnabled && [self.contentViewController isKindOfClass:[UINavigationController class]]) {
           UINavigationController *navigationController = (UINavigationController *)self.contentViewController;
           if (navigationController.viewControllers.count > 1 && navigationController.interactivePopGestureRecognizer.enabled) {
               return NO;
           }
       }
    );
  
    if (self.panFromEdge && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && !self.visible) {
        CGPoint point = [touch locationInView:gestureRecognizer.view];
        if (point.x < 30) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}*/

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer
{
    if ([self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didRecognizePanGesture:)])
        [self.delegate sideMenu:self didRecognizePanGesture:recognizer];
    
    if (!self.panGestureEnabled) {
        return;
    }
    
    CGPoint point = [recognizer translationInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
      //  self.visible = !CGRectEqualToRect(self.contentViewController.view.bounds, self.view.bounds);
        
        if (!self.visible && [self.delegate conformsToProtocol:@protocol(RESideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
            [self.delegate sideMenu:self willShowMenuViewController:self.menuViewController];
        }
        
        NSLog(@"SIZE: %f, %f", CGRectGetWidth(self.contentViewController.view.bounds), CGRectGetHeight(self.contentViewController.view.bounds));
        
        self.originalPoint = CGPointMake(self.contentViewController.view.center.x - CGRectGetWidth(self.contentViewController.view.bounds) / 2.0,
                                         self.contentViewController.view.center.y - CGRectGetHeight(self.contentViewController.view.bounds) / 2.0);
        NSLog(@"%f - %f", self.originalPoint.x, self.originalPoint.y);
        self.menuViewContainer.transform = CGAffineTransformIdentity;
        if (self.scaleBackgroundImageView) {
            self.backgroundImageView.transform = CGAffineTransformIdentity;
            self.backgroundImageView.frame = self.view.bounds;
        }
        self.menuViewContainer.frame = self.view.bounds;
        [self addContentButton];
        [self.view.window endEditing:YES];
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat delta = 0;
        if (self.visible) {
            delta = self.originalPoint.x != 0 ? (point.x + self.originalPoint.x) / self.originalPoint.x : 0;
            NSLog(@"VISIBLE AND %f", delta);
        } else {
            delta = point.x / self.view.frame.size.width;
        }
       // delta = point.x / self.view.frame.size.width;
        delta = fabs(delta);
       
        
        
        if (delta > DBL_MAX) {
            //delta = 0;
        }
        
        CGFloat contentViewScale = self.scaleContentView ? 1 - ((1 - self.contentViewScaleValue) * delta) : 1;
        
        CGFloat backgroundViewScale = 1.7f - (0.7f * delta);
        CGFloat menuViewScale = 1.5f - (0.5f * delta);

        if (!_bouncesHorizontally) {
            contentViewScale = MAX(contentViewScale, self.contentViewScaleValue);
            backgroundViewScale = MAX(backgroundViewScale, 1.0);
            menuViewScale = MAX(menuViewScale, 1.0);
        }
        
        self.menuViewContainer.alpha = delta;
        if (self.scaleBackgroundImageView) {
            self.backgroundImageView.transform = CGAffineTransformMakeScale(backgroundViewScale, backgroundViewScale);
        }
        self.menuViewContainer.transform = CGAffineTransformMakeScale(menuViewScale, menuViewScale);
        
        if (self.scaleBackgroundImageView) {
            if (backgroundViewScale < 1) {
                self.backgroundImageView.transform = CGAffineTransformIdentity;
            }
        }
        
        if (!_bouncesHorizontally && self.visible) {
            point.x = MIN(0.0, point.x);
            [recognizer setTranslation:point inView:self.view];
        }
        
        if (contentViewScale > 1) {
            CGFloat oppositeScale = (1 - (contentViewScale - 1));
            self.contentViewController.view.transform = CGAffineTransformMakeScale(oppositeScale, oppositeScale);
            self.contentViewController.view.transform = CGAffineTransformTranslate(self.contentViewController.view.transform, point.x, 0);
        } else {
            self.contentViewController.view.transform = CGAffineTransformMakeScale(contentViewScale, contentViewScale);
            self.contentViewController.view.transform = CGAffineTransformTranslate(self.contentViewController.view.transform, point.x, 0);
        }
        
       // if (!self.visible) {
        self.menuViewController.view.hidden = self.contentViewController.view.frame.origin.x < 0;
        self.tempViewController.view.hidden = self.contentViewController.view.frame.origin.x > 0;
        
        
        
        //}
        
        [self updateStatusBar];
        
        if (!self.menuViewController && self.contentViewController.view.frame.origin.x > 0) {
            self.contentViewController.view.transform = CGAffineTransformIdentity;
            self.contentViewController.view.frame = self.view.bounds;
            self.visible = NO;
            return;
        }
        
        if (!self.tempViewController && self.contentViewController.view.frame.origin.x < 0) {
            self.contentViewController.view.transform = CGAffineTransformIdentity;
            self.contentViewController.view.frame = self.view.bounds;
            self.visible = NO;
            return;
        }
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if ([recognizer velocityInView:self.view].x > 0) {
            if (self.contentViewController.view.frame.origin.x < 0) {
                [self hideMenuViewController];
            } else {
                if (self.menuViewController) {
                    [self showMenuViewController];
                }
            }
        } else {
            if (self.contentViewController.view.frame.origin.x < 0) {
                if (self.tempViewController) {
                    [self showRightMenuViewController];
                }
            } else {
                [self hideMenuViewController];
            }
        }
    }
}

#pragma mark -
#pragma mark Setters

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    if (self.backgroundImageView)
        self.backgroundImageView.image = backgroundImage;
}

- (void)setContentViewController:(UIViewController *)contentViewController
{
    if (!_contentViewController) {
        _contentViewController = contentViewController;
        return;
    }
    CGRect frame = _contentViewController.view.frame;
    CGAffineTransform transform = _contentViewController.view.transform;
    [self re_hideController:_contentViewController];
    _contentViewController = contentViewController;
    [self re_displayController:contentViewController frame:self.view.bounds];
    contentViewController.view.transform = transform;
    contentViewController.view.frame = frame;
    
    [self addContentViewControllerMotionEffects];
}

- (void)setContentViewController:(UIViewController *)contentViewController animated:(BOOL)animated
{
    if (!animated) {
        [self setContentViewController:contentViewController];
    } else {
        contentViewController.view.alpha = 0;
        contentViewController.view.frame = self.contentViewController.view.bounds;
        [self.contentViewController.view addSubview:contentViewController.view];
        [UIView animateWithDuration:self.animationDuration animations:^{
            contentViewController.view.alpha = 1;
        } completion:^(BOOL finished) {
            [contentViewController.view removeFromSuperview];
            [self setContentViewController:contentViewController];
        }];
    }
}

- (void)setMenuViewController:(UIViewController *)menuViewController
{
    if (!_menuViewController) {
        _menuViewController = menuViewController;
        return;
    }
    [self re_hideController:_menuViewController];
    _menuViewController = menuViewController;
    [self re_displayController:menuViewController frame:self.view.frame];
    
    [self addMenuViewControllerMotionEffects];
    [self.view bringSubviewToFront:self.contentViewController.view];
}

#pragma mark -
#pragma mark Rotation handler

- (BOOL)shouldAutorotate
{
    return self.contentViewController.shouldAutorotate;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.visible) {
        self.contentViewController.view.transform = CGAffineTransformIdentity;
        self.contentViewController.view.frame = self.view.bounds;
        self.contentViewController.view.transform = CGAffineTransformMakeScale(self.contentViewScaleValue, self.contentViewScaleValue);
        self.contentViewController.view.center = CGPointMake((UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? self.contentViewInLandscapeOffsetCenterX : self.contentViewInPortraitOffsetCenterX), self.contentViewController.view.center.y);
    }
}

#pragma mark -
#pragma mark Status bar appearance management

- (void)updateStatusBar
{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [UIView animateWithDuration:0.3f animations:^{
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIStatusBarStyle statusBarStyle = UIStatusBarStyleDefault;
    IF_IOS7_OR_GREATER(
       statusBarStyle = self.visible ? self.menuViewController.preferredStatusBarStyle : self.contentViewController.preferredStatusBarStyle;
       if (self.contentViewController.view.frame.origin.y > 10) {
           statusBarStyle = self.menuViewController.preferredStatusBarStyle;
       } else {
           statusBarStyle = self.contentViewController.preferredStatusBarStyle;
       }
    );
    return statusBarStyle;
}

- (BOOL)prefersStatusBarHidden
{
    BOOL statusBarHidden = NO;
    IF_IOS7_OR_GREATER(
        statusBarHidden = self.visible ? self.menuViewController.prefersStatusBarHidden : self.contentViewController.prefersStatusBarHidden;
        if (self.contentViewController.view.frame.origin.y > 10) {
            statusBarHidden = self.menuViewController.prefersStatusBarHidden;
        } else {
            statusBarHidden = self.contentViewController.prefersStatusBarHidden;
        }
    );
    return statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    UIStatusBarAnimation statusBarAnimation = UIStatusBarAnimationNone;
    IF_IOS7_OR_GREATER(
        statusBarAnimation = self.visible ? self.menuViewController.preferredStatusBarUpdateAnimation : self.contentViewController.preferredStatusBarUpdateAnimation;
        if (self.contentViewController.view.frame.origin.y > 10) {
            statusBarAnimation = self.menuViewController.preferredStatusBarUpdateAnimation;
        } else {
            statusBarAnimation = self.contentViewController.preferredStatusBarUpdateAnimation;
        }
    );
    return statusBarAnimation;
}

@end
