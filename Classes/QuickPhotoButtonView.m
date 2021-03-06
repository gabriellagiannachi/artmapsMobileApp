//
//  QuickPhotoButtonView.m
//  WordPress
//
//  Created by Eric Johnson on 6/19/12.
//

#import "QuickPhotoButtonView.h"

@interface QuickPhotoButtonView () {
    UILabel *label;
    UIActivityIndicatorView *spinner;
    UIButton *button;
}

@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;
@property (nonatomic, retain) UIButton *button;

- (void)setup;
- (void)handleButtonTapped:(id)sender;
- (void)showProgress:(BOOL)show animated:(BOOL)animated delayed:(BOOL)delayed;

@end

@implementation QuickPhotoButtonView

@synthesize label, spinner, button, delegate;

#pragma mark -
#pragma mark LifeCycle Methods

- (void)dealloc {
    [label release];
    [spinner release];
    [button release];
    
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = self.bounds;
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.shadowColor = [UIColor darkGrayColor];
    button.titleLabel.shadowOffset = CGSizeMake(0, -1.0f);
    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
    [button setBackgroundImage:[[UIImage imageNamed:@"SidebarToolbarButton"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0] forState:UIControlStateNormal];
    [button setBackgroundImage:[[UIImage imageNamed:@"SidebarToolbarButtonHighlighted"] stretchableImageWithLeftCapWidth:5.0 topCapHeight:0.0] forState:UIControlStateHighlighted];
    [button setTitle:NSLocalizedString(@"Photo", @"") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(handleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setImage:[UIImage imageNamed:@"sidebar_camera"] forState:UIControlStateNormal];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(3.0f, 5.0f, 0.0f, 0.0f)];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [button setAdjustsImageWhenHighlighted:NO];
    
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self addSubview:button];
    
    CGRect rect;
    self.spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
    spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    spinner.hidesWhenStopped = YES;
    rect = spinner.frame;
    
    rect.origin.x = self.frame.size.width - rect.size.width;
    rect.origin.y = (self.frame.size.height - rect.size.height) / 2.0f;
    spinner.frame = rect;
    [self addSubview:spinner];
    
    self.label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;

    label.frame = CGRectMake(0.0, 0.0, (spinner.frame.origin.x - 10.0f), self.frame.size.height);
    label.text = NSLocalizedString(@"Uploading...", @"");
//    label.text = NSLocalizedString(@"Uploading Quick Photo...", @"");
    [self addSubview:label];
    
    [self showProgress:NO animated:NO delayed:NO];
}


#pragma mark -
#pragma mark Instance Methods

- (void)handleButtonTapped:(id)sender {
    if (delegate) {
        [delegate quickPhotoButtonViewTapped:self];
    }
}

- (void)showSuccess {
    if (!spinner.isAnimating) return; // check the spinner to ensure we're showing progress.
    
    [UIView animateWithDuration:0.6f animations:^{
        spinner.alpha = 0.0f;
        label.text = NSLocalizedString(@"Published!", @"");
//        label.textColor = [[UIColor alloc] initWithRed:0.0f green:128.0f/255.0f blue:0.0f alpha:1.0f];
    } completion:^(BOOL finished) {
        [self showProgress:NO animated:YES delayed:YES];
    }];
}

- (void)showProgress:(BOOL)show animated:(BOOL)animated {
    [self showProgress:show animated:animated delayed:NO];
}

- (void)showProgress:(BOOL)show animated:(BOOL)animated delayed:(BOOL)delayed {
    CGFloat duration = 0.0f;
    CGFloat delay = 0.0f;
    if (animated) {
        duration = 0.6f;
    }
    if (delayed) {
        delay = 1.2f;
    }
    
    if (show) {
        spinner.alpha = 1.0f;
        [spinner startAnimating];
        label.hidden = NO;
        
        [UIView animateWithDuration:duration delay:delay options:0 animations:^{
            CGRect frame = button.frame;
            frame.origin.y = self.frame.size.height;
            button.frame = frame;
            
            frame = spinner.frame;
            frame.origin.y = (self.frame.size.height - frame.size.height) / 2.0f;
            spinner.frame = frame;
            
            frame = label.frame;
            frame.origin.y = 0.0f;
            label.frame = frame;
            
        } completion:^(BOOL finished) {
            // reposition above so we're always sliding down.
            button.hidden = YES;
            CGRect frame = button.frame;
            frame.origin.y = -frame.size.height;
            button.frame = frame;
        }];

    } else {
        button.hidden = NO;
        
        [UIView animateWithDuration:duration delay:delay options:0 animations:^{
            CGRect frame = button.frame;
            frame.origin.y = 0.0f;
            button.frame = frame;
            
            frame = spinner.frame;
            frame.origin.y = self.frame.size.height;
            spinner.frame = frame;
            
            frame = label.frame;
            frame.origin.y = self.frame.size.height;
            label.frame = frame;
            
        } completion:^(BOOL finished) {
            CGRect frame = spinner.frame;
            frame.origin.y = -frame.size.height;
            spinner.frame = frame;
            [spinner stopAnimating];
            
            frame = label.frame;
            frame.origin.y = -frame.size.height;
            label.frame = frame;

            label.hidden = YES;
//            label.textColor = [[[UIColor alloc] initWithRed:70.0f/255.0f green:70.0f/255.0f blue:70.0f/255.0f alpha:1.0f] autorelease];
            label.text = NSLocalizedString(@"Uploading...", @"");
        }];
    }
}

@end
