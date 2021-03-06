//
//  TMWMoviesCollectionViewController.m
//  ThatMovieWith
//
//  Created by johnrhickey on 4/24/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import "TMWMoviesCollectionViewController.h"
#import "TMWActorViewController.h"
#import "ParallaxFlowLayout.h"
#import "ParallaxPhotoCell.h"
#import "TMWSoundEffects.h"
#import <CWStatusBarNotification.h>
#import "DDLog.h"

#import <UIImageView+AFNetworking.h>
#import <JLTMDbClient.h>
#import "SVWebViewController.h"
#import "TMWActorContainer.h"
#import "UIImage+ImageEffects.h"
#import "UIColor+customColors.h"

@interface TMWMoviesCollectionViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, copy) NSArray *photos;
@property (nonatomic, copy) UIImageView *backgroundView;
@property (nonatomic, strong) UILabel *noResultsLabel;

@end


@implementation TMWMoviesCollectionViewController

// 2 movies: 252    3 movies: 168    4 movies: 126
NSUInteger TABLE_HEIGHT_FOUR;
NSUInteger TABLE_HEIGHT_THREE;
NSUInteger TABLE_HEIGHT_TWO;
NSUInteger TABLE_HEIGHT_ONE;
NSUInteger TITLE_FONT_SIZE;

bool selectedMovie;

NSInteger tableViewRows;
CGFloat cellWidth;


- (id)init
{
    ParallaxFlowLayout *layout = [[ParallaxFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    //layout.sectionInset = UIEdgeInsetsMake(16, 16, 16, 16);
    
    self = [super initWithCollectionViewLayout:layout];
    
    if (self == nil) {
        return nil;
    }
    
    self.title = @"Movies";
    NSDictionary *fontDict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.0], NSFontAttributeName,nil];
    [[UINavigationBar appearance] setTitleTextAttributes: fontDict];
    
    return self;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _noResultsLabel = [UILabel new];
    _noResultsLabel.textAlignment = NSTextAlignmentCenter;
    _noResultsLabel.textColor = [UIColor whiteColor];
    _noResultsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:24];
    _noResultsLabel.numberOfLines = 0;
    
    _noResultsLabel.alpha = 0.0;
    
    // Prepare the label in case there are no results
    _noResultsLabel.text = [NSString stringWithFormat:@"No movies with %@", [TMWActorContainer actorContainer].actorNames[0]];
    if ([[TMWActorContainer actorContainer].actorNames count] > 1) {
        _noResultsLabel.text = [NSString stringWithFormat:@"No movies with %@ and %@", [TMWActorContainer actorContainer].actorNames[0], [TMWActorContainer actorContainer].actorNames[1]];
    }
    
    [self.view addSubview:_noResultsLabel];
    
    // Calls perferredStatusBarStyle
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:[ParallaxPhotoCell class] forCellWithReuseIdentifier:@"PhotoCell"];
    
    // Special attribute set for title text color
    self.navigationController.navigationBar.tintColor = [UIColor goldColor];
    self.navigationController.navigationBar.backItem.title = @"Actors";
    
    UIImage *productImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"background-blur" ofType:@"jpg"]];
    
    _backgroundView = [[UIImageView alloc] initWithImage:productImage];
    
    self.collectionView.backgroundView = _backgroundView;
    
    tableViewRows = 0;
    
    // Refresh the table view
    [self refresh];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIView beginAnimations:@"hideStatusBar" context:nil];
    [UIView setAnimationDuration:0.0];
    if([[UIApplication sharedApplication] respondsToSelector:@selector(setStatusBarHidden:)]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    [UIView commitAnimations];
    
    _noResultsLabel.frame = CGRectMake(self.view.frame.origin.x + 20, self.view.frame.origin.y, self.view.frame.size.width - 40, self.view.frame.size.height);
    
    TABLE_HEIGHT_ONE = (self.view.frame.size.height) - 64;
    TABLE_HEIGHT_TWO = TABLE_HEIGHT_ONE/2;
    TABLE_HEIGHT_THREE = TABLE_HEIGHT_ONE/3;
    TABLE_HEIGHT_FOUR = TABLE_HEIGHT_ONE/4;
    
    TITLE_FONT_SIZE = 36;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    selectedMovie = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (!selectedMovie) {
        
        // Play sound
        [[TMWSoundEffects soundEffects] playSound:@"When pressing the back button to go back from the movies to the actors screen"];
    }
}

#pragma mark - PrivateMethods

- (void)setLabel:(UILabel *)textView
      withString:(NSString *)string
  inBoundsOfView:(UIView *)view
{
    UIFont *textFont = [UIFont new];
    textFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:TITLE_FONT_SIZE];
    
    textView.font = textFont;
    
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName:textFont, NSParagraphStyleAttributeName: textStyle};
    CGRect bound = [string boundingRectWithSize:CGSizeMake(view.bounds.size.width-30, view.bounds.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    
    textView.numberOfLines = 2;
    textView.bounds = bound;
    textView.text = string;
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return tableViewRows;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"PhotoCell";
    __weak ParallaxPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // grab bound for contentView
    CGRect contentViewBound = cell.imageView.bounds;
    
    // Protection against empty arrays in actor container
    NSString *movieNameString = @"";
    if ([TMWActorContainer actorContainer].sameMoviesNames.count) {
             movieNameString = [[TMWActorContainer actorContainer].sameMoviesNames objectAtIndex:indexPath.row];
    }
    
    NSString *movieYearString = @"TBA";
    if ([TMWActorContainer actorContainer].sameMoviesReleaseYears.count) {
            movieYearString = [[TMWActorContainer actorContainer].sameMoviesReleaseYears objectAtIndex:indexPath.row];
    }
    
    // If an image exists, fetch it. Else use the generated UIImage
    if ([[TMWActorContainer actorContainer].sameMoviesPosterUrlEndings objectAtIndex:indexPath.row] != (id)[NSNull null]) {
        NSString *urlstring = [[[TMWActorContainer actorContainer].imagesBaseURLString stringByReplacingOccurrencesOfString:[TMWActorContainer actorContainer].backdropSizes[1] withString:[TMWActorContainer actorContainer].backdropSizes[5]] stringByAppendingString:[[TMWActorContainer actorContainer].sameMoviesPosterUrlEndings objectAtIndex:indexPath.row]];
        
        
        // Show the network activity icon
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        cell.label.text = nil;
        cell.secondLabel.text = nil;
        
        CWStatusBarNotification *notification = [CWStatusBarNotification new];
        notification.notificationLabelBackgroundColor = [UIColor flatRedColor];
        notification.notificationLabelTextColor = [UIColor whiteColor];
        notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
        notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
        
        [cell.activityIndicator startAnimating];
        
        // Get the image from the URL and set it
        [cell.imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlstring]] placeholderImage:[UIImage imageNamed:@"black"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            
            [cell.activityIndicator stopAnimating];
            
            
            // Darken the image
            UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.imageView.frame.size.width, cell.imageView.frame.size.height*2)];
            [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
            NSArray *viewsToRemove = [cell.imageView subviews];
            for (UIView *v in viewsToRemove) [v removeFromSuperview];
            [cell.imageView addSubview:overlay];
            
            // Hide the network activity icon
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            if (request) {
                
                // Hide the network activity icon
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                
                [UIView transitionWithView:cell.imageView
                                  duration:0.5f
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{[cell.imageView setImage:image];}
                                completion:NULL];
                
                [UIView transitionWithView:cell.label
                                  duration:0.5f
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{// Set the image label properties to center it in the cell
                                    [self setLabel:cell.label withString:movieNameString inBoundsOfView:cell.imageView];}
                                completion:NULL];
                
                [UIView transitionWithView:cell.secondLabel
                                  duration:0.5f
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{[cell.secondLabel setText:movieYearString];}
                                completion:NULL];
            }
            else {
                // Set the image label properties to center it in the cell
                [self setLabel:cell.label withString:movieNameString inBoundsOfView:cell.imageView];
                cell.imageView.image = image;
                cell.secondLabel.text = movieYearString;
            }
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
            [cell.activityIndicator stopAnimating];
            
            // Hide the network activity icon
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            // Don't show the error for NSURLErrorDomain -999 because that's just a cancelled image request due to scrolling
            if ([error.localizedDescription rangeOfString:@"NSURLErrorDomain error -999"].location == NSNotFound) {
                [notification displayNotificationWithMessage:@"Network Error. Check your network connection." forDuration:3.0f];
            }
        }];
        
        CGRect imageViewFrame = cell.imageView.frame;
        // change x position
        imageViewFrame.origin.y = contentViewBound.size.height - imageViewFrame.size.height;
        // assign the new frame
        cell.imageView.frame = imageViewFrame;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    else {
        UIImage *defaultImage = [UIImage imageNamed:@"InitialsBackgroundHiRes"];
        
        cell.secondLabel.text = movieYearString;
        
        // Darken the image
        UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.imageView.frame.size.width, cell.imageView.frame.size.height*2)];
        [overlay setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        NSArray *viewsToRemove = [cell.imageView subviews];
        for (UIView *v in viewsToRemove) [v removeFromSuperview];
        [cell.imageView addSubview:overlay];
        
        cell.imageView.image = defaultImage;
        
        // Set the image label properties to center it in the cell
        [self setLabel:cell.label withString:movieNameString inBoundsOfView:cell.imageView];
    }
    
    
    // Pass the maximum parallax offset to the cell.
    // The cell needs this information to configure the constraints for its image view.
    ParallaxFlowLayout *layout = (ParallaxFlowLayout *)self.collectionViewLayout;
    cell.maxParallaxOffset = layout.maxParallaxOffset;
    
    
    return cell;
}

- (void)refresh
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Fetch the movie data for all actors in the container
    __block NSUInteger i = 1;
    for (TMWActor *actor in [TMWActorContainer actorContainer].allActorObjects) {
        
        __block CWStatusBarNotification *notification = [CWStatusBarNotification new];
        notification.notificationLabelBackgroundColor = [UIColor flatRedColor];
        notification.notificationLabelTextColor = [UIColor whiteColor];
        notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
        notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
        
        [[JLTMDbClient sharedAPIInstance] GET:kJLTMDbPersonCredits withParameters:@{@"id":actor.IDNumber} andResponseBlock:^(id response, NSError *error) {
            if (!error) {
                actor.movies = [[NSArray alloc] initWithArray:response[@"cast"]];
                if (i == [[TMWActorContainer actorContainer].allActorObjects count]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                        tableViewRows = [[TMWActorContainer actorContainer].sameMovies count];
                        if([[TMWActorContainer actorContainer].sameMovies count] == 0 ){
                            
                            // Animate in the no results label
                            [UIView animateWithDuration:0.5
                                                  delay:0
                                                options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                                             animations:^(void) {
                                                 self.noResultsLabel.alpha = 1.0;
                                             }
                                             completion:nil];
                        }
                        else {
                            [UIView animateWithDuration:0.5
                                                  delay:0
                                                options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                                             animations:^(void) {
                                                 self.noResultsLabel.alpha = 0.0;
                                             }
                                             completion:nil];
                        }
                        [self.collectionView reloadData];
                    });
                }
                i++;
            }
            else {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                if ([error.localizedDescription rangeOfString:@"NSURLErrorDomain error -999"].location == NSNotFound) {
                    [notification displayNotificationWithMessage:@"Network Error. Check your network connection." forDuration:3.0f];
                }
            }
        }];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Play sound
    [[TMWSoundEffects soundEffects] playSound:@"When a movie is selected"];
    
    selectedMovie = YES;
    
    //DDLogInfo(@"Selected Movie: %@ (IMDB ID %@)", [[TMWActorContainer actorContainer].sameMoviesNames objectAtIndex:indexPath.row], [[TMWActorContainer actorContainer].sameMoviesIDs objectAtIndex:indexPath.row]);
    
    // Get the information about the selected movie
    [self refreshMovieResponseWithJLTMDBcall:kJLTMDbMovie
                              withParameters:@{@"id":[[TMWActorContainer actorContainer].sameMoviesIDs objectAtIndex:indexPath.row]}];
    
}

// Gets the movies each actor has been in, along with the urls
- (void) refreshMovieResponseWithJLTMDBcall:(NSString *)JLTMDBCall withParameters:(NSDictionary *)parameters
{
    
    __block CWStatusBarNotification *IMDBnotification = [CWStatusBarNotification new];
    __block CWStatusBarNotification *notification = [CWStatusBarNotification new];
    IMDBnotification.notificationLabelBackgroundColor = [UIColor goldColor];
    IMDBnotification.notificationLabelTextColor = [UIColor blackColor];
    IMDBnotification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    IMDBnotification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    notification.notificationLabelBackgroundColor = [UIColor redColor];
    notification.notificationLabelTextColor = [UIColor whiteColor];
    notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[JLTMDbClient sharedAPIInstance] GET:JLTMDBCall withParameters:parameters andResponseBlock:^(id response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        });
        
        
        if (!error) {
            NSDictionary *movieInfo = [[NSDictionary alloc] initWithDictionary:response];
            
            if (![movieInfo[@"imdb_id"]isEqualToString:@""]) {
                NSString *webURL = [@"http://imdb.com/title/" stringByAppendingString:movieInfo[@"imdb_id"]];
                SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:webURL];
                webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
                webViewController.barsTintColor = [UIColor goldColor];
                [self presentViewController:webViewController animated:YES completion:NULL];
            }
            else {
                [IMDBnotification displayNotificationWithMessage:@"No IMDb page exists for this movie." forDuration:3.0f];
            }
        }
        else {
            if ([error.localizedDescription rangeOfString:@"NSURLErrorDomain error -999"].location == NSNotFound) {
                [notification displayNotificationWithMessage:@"Network Error. Check your network connection." forDuration:3.0f];
            }
        }
    }];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Compute cell size according to image aspect ratio.
    // Cell height must take maximum possible parallax offset into account.
    ParallaxFlowLayout *layout = (ParallaxFlowLayout *)self.collectionViewLayout;
    cellWidth = CGRectGetWidth(self.collectionView.bounds) - layout.sectionInset.left - layout.sectionInset.right;
    switch ([TMWActorContainer actorContainer].sameMovies.count) {
        case 0:
        case 1:
            return CGSizeMake(cellWidth, TABLE_HEIGHT_ONE);
            break;
        case 2:
            return CGSizeMake(cellWidth, TABLE_HEIGHT_TWO);
            break;
        case 3:
            return CGSizeMake(cellWidth, TABLE_HEIGHT_THREE);
            break;
        default:
            return CGSizeMake(cellWidth, TABLE_HEIGHT_FOUR);
            break;
    }
}

@end
