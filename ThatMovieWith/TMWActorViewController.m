//
//  TMWViewController.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/15/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import <UIImageView+AFNetworking.h>
#import <JLTMDbClient.h>

#import "TMWActorViewController.h"
#import "TMWMoviesViewController.h"
#import "TMWCustomCellTableViewCell.h"
#import "TMWCustomAnimations.h"
#import "TMWActorModel.h"

#import "UIColor+customColors.h"
#import "CALayer+circleLayer.h"

@interface TMWActorViewController ()

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchBarController;
@property (strong, nonatomic) IBOutlet UILabel *firstActorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *firstActorImage;
@property (strong, nonatomic) IBOutlet UILabel *secondActorLabel;
@property (strong, nonatomic) IBOutlet UIImageView *secondActorImage;
@property (strong, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutlet UIButton *firstActorButton;
@property (strong, nonatomic) IBOutlet UIButton *secondActorButton;
@property (strong, nonatomic) IBOutlet UIButton *backgroundButton;
@property (strong, nonatomic) IBOutlet UILabel *startLabel;
@property (strong, nonatomic) IBOutlet UILabel *startSecondaryLabel;
@property (strong, nonatomic) IBOutlet UIImageView *startArrow;

@property UIPanGestureRecognizer *firstPanGesture;
@property UIPanGestureRecognizer *secondtPanGesture;

// Animation stuff
@property (strong, nonatomic) UIDynamicAnimator *animator;
@property (strong, nonatomic) UIAttachmentBehavior *attachmentBehavior;
@property (strong, nonatomic) UIPushBehavior *pushBehavior;
@property (strong, nonatomic) UISnapBehavior *snapBehavior;
@property (strong, nonatomic) UICollisionBehavior *collisionBehavior;

@end

@implementation TMWActorViewController

NSInteger selectedActor;
NSArray *backdropSizes;
NSArray *responseArray;
BOOL firstFlipped;
BOOL secondFlipped;

#define TABLE_HEIGHT 66

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        navItem.title = @"Actors";


        NSString *APIKeyPath = [[NSBundle mainBundle] pathForResource:@"TMDB_API_KEY" ofType:@""];
        
        NSString *APIKeyValueDirty = [NSString stringWithContentsOfFile:APIKeyPath
                                                       encoding:NSUTF8StringEncoding
                                                          error:NULL];

        // Strip whitespace to clean the API key stdin
        NSString *APIKeyValue = [APIKeyValueDirty stringByTrimmingCharactersInSet:
                                   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [[JLTMDbClient sharedAPIInstance] setAPIKey:APIKeyValue];
        
        [self.firstActorLabel setHidden:YES];
        //self.firstActorImage.frame = CGRectMake(0,0,20,20);
        self.firstActorButton.enabled = NO;
        
        [self.secondActorLabel setHidden:YES];
        self.secondActorImage.frame = CGRectMake(0,0,20,20);
        self.secondActorButton.enabled = NO;
        
        self.continueButton.hidden = YES;
    }
    
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadImageConfiguration];
    
    // UILongPressGestureRecognizer *longPressOne = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOne:)];
    // longPressOne.minimumPressDuration = 1.0;
    // [self.firstActorButton addGestureRecognizer:longPressOne];
    // UILongPressGestureRecognizer *longPressTwo = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTwo:)];
    // longPressTwo.minimumPressDuration = 1.0;
    // [self.secondActorButton addGestureRecognizer:longPressTwo];
}



- (void)longPressOne:(UILongPressGestureRecognizer*)gesture
{
    NSLog(@"Long Press 1");
    
    int num = 1;
    [self removeActor:&num];
}

- (void)longPressTwo:(UILongPressGestureRecognizer*)gesture
{
    NSLog(@"Long Press 2");
    
    int num = 2;
    [self removeActor:&num];
}

// Remove the actor
- (void)removeActor:(int *)actorNumber
{
    NSLog(@"%ld", (long)selectedActor);
    [self.continueButton setHidden: YES];
    [self.firstActorLabel.layer removeAllAnimations];
    [self.secondActorLabel.layer removeAllAnimations];
    [self.firstActorImage.layer removeAllAnimations];
    [self.secondActorImage.layer removeAllAnimations];
    
    if ([self.firstActorLabel.text isEqualToString:@""] && [self.secondActorLabel.text isEqualToString:@""])
    {
        [self.startLabel setHidden:NO];
        [self.startSecondaryLabel setHidden:NO];
        [self.startArrow setImage: [UIImage imageNamed:@"arrow.png"]];
    }
    
    switch (*actorNumber) {
        
        case 1:
        {
            NSArray *chosenCopy = [TMWActorModel actorModel].chosenActors;
            
            for (NSDictionary *dict in chosenCopy)
            {
                if ([dict[@"name"] isEqualToString: self.firstActorLabel.text])
                {
                    [[TMWActorModel actorModel] removeChosenActor:dict];
                    break;
                }
            }
            
            self.firstActorButton.enabled = NO;
            [self hideImage:self.firstActorImage];
            self.firstActorLabel.text = @"";
            
            break;
        }
        case 2:
        {
            NSArray *chosenCopy = [TMWActorModel actorModel].chosenActors;
            
            for (NSDictionary *dict in chosenCopy)
            {
                if ([dict[@"name"] isEqualToString: self.secondActorLabel.text])
                {
                    [[TMWActorModel actorModel] removeChosenActor:dict];
                    break;
                }
            }
            
            self.secondActorButton.enabled = NO;
            [self hideImage:self.secondActorImage];
            self.secondActorLabel.text = @"";
            
            break;
        }
            
        default:
        {
            //
        }
    }
}

-(IBAction)hideImage:(UIImageView*)image
{
    image.hidden = NO;
    image.alpha = 1.0f;
    // Then fades it away after 2 seconds (the cross-fade animation will take 0.5s)
    [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
        // Animate the alpha value of your imageView from 1.0 to 0.0 here
        image.alpha = 0.0f;
    } completion:^(BOOL finished) {
        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        image.hidden = YES;
    }];
}

-(IBAction)showImage:(UIImageView*)image
{
    image.hidden = YES;
    image.alpha = 0.0f;
    // Then fades it away after 2 seconds (the cross-fade animation will take 0.5s)
    [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
        // Animate the alpha value of your imageView from 1.0 to 0.0 here
        image.alpha = 1.0f;
    } completion:^(BOOL finished) {
        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        image.hidden = NO;
    }];
}

#pragma mark UISearchBar methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if([searchText length] != 0) {
        float delay = 0.6;
        
        if (searchText.length > 3) {
            delay = 0.3;
        }
        
        // Clear any previously queued text changes
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        [self performSelector:@selector(refreshActorResponseWithJLTMDBcall:)
                   withObject:@{@"JLTMDBCall":kJLTMDbSearchPerson, @"parameters":@{@"search_type":@"ngram",@"query":searchText}}
                   afterDelay:delay];
    }
}

#pragma mark UITableView methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.startLabel setHidden:YES];
    [self.startSecondaryLabel setHidden:YES];
    [self.startArrow setImage:nil];
    
    [self.searchDisplayController setActive:NO animated:YES];
    
    // Remove the actor if both of the actors have been chosen
    if (![self.firstActorLabel.text isEqualToString:@""] && ![self.secondActorLabel.text isEqualToString:@""])
    {
        NSLog(@"Removing actor");
        NSArray *chosenCopy = [TMWActorModel actorModel].chosenActors;
        for (NSDictionary *dict in chosenCopy)
        {
            if ((selectedActor == 1 && [dict[@"name"] isEqualToString: self.firstActorLabel.text]) || (selectedActor == 2 && [dict[@"name"] isEqualToString: self.secondActorLabel.text]))
            {
                [[TMWActorModel actorModel] removeChosenActor:dict];
                break;
            }
        }
    }

    // Add the chosen actor to the array of chosen actors
    [[TMWActorModel actorModel] addChosenActor:[[TMWActorModel actorModel].actorSearchResults objectAtIndex:indexPath.row]];
    
    if ([self.firstActorLabel.text isEqualToString:@""]||(selectedActor == 1))
    {
        self.firstActorLabel.text = [[TMWActorModel actorModel].actorSearchResultNames objectAtIndex:indexPath.row];

        // Make the image a circle
        [CALayer circleLayer:self.firstActorImage.layer];
        self.firstActorImage.contentMode = UIViewContentModeScaleAspectFill;
        
        // TODO: Make these their own methods
        // If NSString, fetch the image, else use the generated UIImage
        if ([[[TMWActorModel actorModel].actorSearchResultImages objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {

            NSString *urlstring = [[self.imagesBaseUrlString stringByReplacingOccurrencesOfString:backdropSizes[1] withString:backdropSizes[4]] stringByAppendingString:[[TMWActorModel actorModel].actorSearchResultImages objectAtIndex:indexPath.row]];
            
            [self.firstActorImage setImageWithURL:[NSURL URLWithString:urlstring] placeholderImage:nil];
        }
        else {
            // TODO: Fix issue with image font being blurry when actor without a picture is chosen
            [self.firstActorImage setImage:[[TMWActorModel actorModel].actorSearchResultImages objectAtIndex:indexPath.row]];
        }
        [self showImage:self.firstActorImage];
        
        // Enable tapping on the actor image
        self.firstActorButton.enabled = YES;
        
        // The second actor is the default selection for being replaced.
        selectedActor = 2;

        self.firstPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self.firstActorImage addGestureRecognizer:self.firstPanGesture];
        self.firstActorImage.userInteractionEnabled = YES;
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
        [self.view bringSubviewToFront:self.firstActorImage];
    }
    else
    {
        self.secondActorLabel.text = [[TMWActorModel actorModel].actorSearchResultNames objectAtIndex:indexPath.row];

        // Make the image a circle
        [CALayer circleLayer:self.secondActorImage.layer];
        self.secondActorImage.contentMode = UIViewContentModeScaleAspectFill;
        
        // If NSString, fetch the image, else use the generated UIImage
        if ([[[[TMWActorModel actorModel] actorSearchResultImages] objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
            
            NSString *urlstring = [[self.imagesBaseUrlString stringByReplacingOccurrencesOfString:backdropSizes[1] withString:backdropSizes[4]] stringByAppendingString:[[TMWActorModel actorModel].actorSearchResultImages objectAtIndex:indexPath.row]];
            
            [self.secondActorImage setImageWithURL:[NSURL URLWithString:urlstring] placeholderImage:[UIImage imageNamed:@"Clear.png"]];
        }
        else {
            [self.secondActorImage setImage:[[TMWActorModel actorModel].actorSearchResultImages objectAtIndex:indexPath.row]];
        }
        [self showImage:self.secondActorImage];
        
        // Enable tapping on the actor image
        self.secondActorButton.enabled = YES;
        
        // The second actor is the default selection for being replaced.
        selectedActor = 2;

        self.secondtPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self.secondActorImage addGestureRecognizer:self.secondtPanGesture];
        self.secondActorImage.userInteractionEnabled = YES;
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
        [self.view bringSubviewToFront:self.secondActorImage];

    }
    
    if (![self.firstActorLabel.text isEqualToString:@""] && ![self.secondActorLabel.text isEqualToString:@""])
    {
        self.firstActorButton.tag = 1;
        self.secondActorButton.tag = 2;
        self.continueButton.tag = 3;
        self.backgroundButton.tag = 4;
        [self.continueButton setHidden:NO];
                
        [self.continueButton.layer addAnimation:[TMWCustomAnimations buttonOpacityAnimation] forKey:@"opacity"];
        [self.firstActorImage.layer removeAllAnimations];
        [self.secondActorImage.layer removeAllAnimations];
        [self.view bringSubviewToFront:self.firstActorImage];
        
        [[TMWActorModel actorModel] removeAllActorMovies];
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[TMWActorModel actorModel].actorSearchResultNames count];
}

// Change the Height of the Cell [Default is 44]:
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return TABLE_HEIGHT;
}

// Todo: add fade in animation to searching
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    [[UITableViewCell appearance] setBackgroundColor:[UIColor clearColor]];
    
    TMWCustomCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[TMWCustomCellTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                                 reuseIdentifier:CellIdentifier];
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        tableView.showsVerticalScrollIndicator = YES;
        [cell layoutSubviews];
    }
    cell.imageView.layer.cornerRadius = cell.imageView.frame.size.height/2;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.borderWidth = 0;

    cell.textLabel.text = [[TMWActorModel actorModel].actorSearchResultNames objectAtIndex:indexPath.row];

    // If NSString, fetch the image, else use the generated UIImage
    if ([[[TMWActorModel actorModel].actorSearchResultImages objectAtIndex:indexPath.row] isKindOfClass:[NSString class]]) {
        
        NSString *urlstring = [self.imagesBaseUrlString stringByAppendingString:[[TMWActorModel actorModel].actorSearchResultImages objectAtIndex:indexPath.row]];
        
        // Show the network activity icon
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [cell.imageView setImageWithURL:[NSURL URLWithString:urlstring] placeholderImage:[UIImage imageNamed:@"Clear.png"]];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
    else {
        [cell.imageView setImage:[[TMWActorModel actorModel].actorSearchResultImages objectAtIndex:indexPath.row]];
    }
    return cell;
}

#pragma mark UISearchDisplayController methods

// Added to fix UITableView bottom bounds in UISearchDisplayController
- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}


- (void) keyboardWillHide
{
    UITableView *tableView = [[self searchDisplayController] searchResultsTableView];
    [tableView setContentInset:UIEdgeInsetsZero];
    [tableView setScrollIndicatorInsets:UIEdgeInsetsZero];
}

#pragma mark UIButton methods

// For flipping over the actor images
-(IBAction)buttonPressed:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    switch ([button tag]) {
        case 1:
        {

//            [UIView transitionWithView:self.firstActorImage duration:1.5
//                               options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
//                                   self.firstActorImage.image = self.secondActorImage.image;
//                               } completion:nil];
            break;
        }
            
        case 2:
        {
//            if (firstFlipped == NO) {
//                [UIView transitionWithView:self.secondActorImage duration:1.5
//                                   options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
//                                       self.secondActorImage.image = self.firstActorImage.image;
//                                   } completion:nil];
//                firstFlipped = YES;
//            }
//            else {
//                [UIView transitionWithView:self.secondActorImage duration:1.5
//                                   options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
//                                       self.firstActorImage.image = self.secondActorImage.image;
//                                   } completion:nil];
//                firstFlipped = NO;
//            }
            break;
        }

        case 3: // Continue button
        case 4: // Background button
        {
            // Stop all animations when the continueButton is pressed
            [self.firstActorLabel.layer removeAllAnimations];
            [self.secondActorLabel.layer removeAllAnimations];
            [self.firstActorImage.layer removeAllAnimations];
            [self.secondActorImage.layer removeAllAnimations];
            
            // Show the Movies View if the continue button is pressed
            if ([button tag] == 3) {
                
                TMWMoviesViewController *moviesViewController = [[TMWMoviesViewController alloc] init];
                [self.navigationController pushViewController:moviesViewController animated:YES];
                [self.navigationController setNavigationBarHidden:NO animated:NO];
            }
            break;
        }
    }
}

-(IBAction)buttonDown:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    switch ([button tag]) {
        case 1:
        {
            selectedActor = 1;
            self.firstActorImage.layer.borderColor = [UIColor ringBlueColor].CGColor;
            
            // Animate the first actor image and name
            [self.firstActorLabel.layer addAnimation:[TMWCustomAnimations actorOpacityAnimation] 
                                              forKey:@"opacity"];
            [self.firstActorImage.layer addAnimation:[TMWCustomAnimations ringBorderWidthAnimation] 
                                              forKey:@"borderWidth"]; //
            [self.secondActorImage.layer removeAllAnimations];
            [self.continueButton.layer removeAllAnimations];
            
            break;
        }
            
        case 2:
        {
            selectedActor = 2;
            self.secondActorImage.layer.borderColor = [UIColor ringBlueColor].CGColor;             
            
            // Animate the second actor image and name
            [self.secondActorLabel.layer addAnimation:[TMWCustomAnimations actorOpacityAnimation] 
                                               forKey:@"opacity"];
            [self.secondActorImage.layer addAnimation:[TMWCustomAnimations ringBorderWidthAnimation] 
                                               forKey:@"borderWidth"]; //
            [self.firstActorImage.layer removeAllAnimations];
            [self.continueButton.layer removeAllAnimations];
            
            break;
        }
        case 3: // Continue button
        case 4: // Background button
        {
            break;
        }
            
        default:
        {
            NSLog(@"No tag");
        }
    }
}


#pragma mark Private Methods

- (void) loadImageConfiguration
{
    
    __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    
    [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbConfiguration withParameters:nil andResponseBlock:^(id response, NSError *error) {

        if (!error) {
            backdropSizes = response[@"images"][@"logo_sizes"];
            self.imagesBaseUrlString = [response[@"images"][@"base_url"] stringByAppendingString:backdropSizes[1]];
        }
        else {
            [errorAlertView show];
        }
    }];
}

- (void) refreshActorResponseWithJLTMDBcall:(NSDictionary *)call
{
    NSString *JLTMDBCall = call[@"JLTMDBCall"];
    NSDictionary *parameters = call[@"parameters"];
    __block UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"") message:NSLocalizedString(@"Please try again later", @"") delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[JLTMDbClient sharedAPIInstance] GET:JLTMDBCall withParameters:parameters andResponseBlock:^(id response, NSError *error) {
        
        if (!error) {
            [TMWActorModel actorModel].actorSearchResults = response[@"results"];
            
            dispatch_async(dispatch_get_main_queue(),^{
                [[self.searchBarController searchResultsTableView] reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            });
        }
        else {
            [errorAlertView show];
        }
    }];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    NSLog(@"Dragging....");
    static UIAttachmentBehavior *attachment;
    static CGPoint               startCenter;

    // variables for calculating angular velocity

    static CFAbsoluteTime        lastTime;
    static CGFloat               lastAngle;
    static CGFloat               angularVelocity;

    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        [self.animator removeAllBehaviors];

        startCenter = gesture.view.center;

        // calculate the center offset and anchor point

        CGPoint pointWithinAnimatedView = [gesture locationInView:gesture.view];

        UIOffset offset = UIOffsetMake(pointWithinAnimatedView.x - gesture.view.bounds.size.width / 2.0,
                                       pointWithinAnimatedView.y - gesture.view.bounds.size.height / 2.0);

        CGPoint anchor = [gesture locationInView:gesture.view.superview];

        // create attachment behavior

        attachment = [[UIAttachmentBehavior alloc] initWithItem:gesture.view
                                               offsetFromCenter:offset
                                               attachedToAnchor:anchor];

        // code to calculate angular velocity (seems curious that I have to calculate this myself, but I can if I have to)

        lastTime = CFAbsoluteTimeGetCurrent();
        lastAngle = [self angleOfView:gesture.view];

        attachment.action = ^{
            CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
            CGFloat angle = [self angleOfView:gesture.view];
            if (time > lastTime) {
                angularVelocity = (angle - lastAngle) / (time - lastTime);
                lastTime = time;
                lastAngle = angle;
            }
        };

        // add attachment behavior

        [self.animator addBehavior:attachment];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged)
    {
        // as user makes gesture, update attachment behavior's anchor point, achieving drag 'n' rotate

        CGPoint anchor = [gesture locationInView:gesture.view.superview];
        attachment.anchorPoint = anchor;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [self.animator removeAllBehaviors];

        CGPoint velocity = [gesture velocityInView:gesture.view.superview];

        // if we aren't dragging it down, just snap it back and quit

        if (fabs(atan2(velocity.y, velocity.x) - M_PI_2) > M_PI_4) {
            UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:gesture.view snapToPoint:startCenter];
            [self.animator addBehavior:snap];

            return;
        }

        // otherwise, create UIDynamicItemBehavior that carries on animation from where the gesture left off (notably linear and angular velocity)

        UIDynamicItemBehavior *dynamic = [[UIDynamicItemBehavior alloc] initWithItems:@[gesture.view]];
        [dynamic addLinearVelocity:velocity forItem:gesture.view];
        [dynamic addAngularVelocity:angularVelocity forItem:gesture.view];
        [dynamic setAngularResistance:2];

        // when the view no longer intersects with its superview, go ahead and remove it

        dynamic.action = ^{
            if (!CGRectIntersectsRect(gesture.view.superview.bounds, gesture.view.frame)) {
                [self.animator removeAllBehaviors];
                [gesture.view removeFromSuperview];

                [[[UIAlertView alloc] initWithTitle:nil message:@"View is gone!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        };
        [self.animator addBehavior:dynamic];

        // add a little gravity so it accelerates off the screen (in case user gesture was slow)

        UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[gesture.view]];
        gravity.magnitude = 0.7;
        [self.animator addBehavior:gravity];
    }
}

- (CGFloat)angleOfView:(UIView *)view
{
    return atan2(view.transform.b, view.transform.a);
}

@end
