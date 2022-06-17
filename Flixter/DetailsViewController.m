//
//  DetailsViewController.m
//  Flixter
//
//  Created by Jake Torres on 6/15/22.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "YTPlayerView.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *widePoster;
@property (weak, nonatomic) IBOutlet UIImageView *miniPoster;
@property (weak, nonatomic) IBOutlet UILabel *movieTitle;
@property (weak, nonatomic) IBOutlet UILabel *movieDesc;
@property (weak, nonatomic) IBOutlet UIProgressView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (strong, nonatomic) NSArray *videos;
@property (strong, nonatomic) NSDictionary *video;
@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.movieTitle.text = self.detailDic[@"title"];
    NSString *details1 = self.detailDic[@"release_date"];
    NSString *details2 = self.detailDic[@"overview"];
    NSString *details3 = [@"Released: " stringByAppendingString:details1];
    NSString *details4 = [details3 stringByAppendingString:@"\n\n"];
    self.movieDesc.text = [details4 stringByAppendingString:details2];
    
    NSString *rating = @"Rating: ";
    NSNumber *voteAvg = self.detailDic[@"vote_average"];
    NSString *voteAvgString = [voteAvg stringValue];
    NSString *ratingTextP1 = [rating stringByAppendingString:voteAvgString];
    NSString *ratingTextP2 = [ratingTextP1 stringByAppendingString:@"/10"];
    self.ratingLabel.text = ratingTextP2;
    self.ratingView.progress = [voteAvg doubleValue]/10;
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *miniPosterURLString = self.detailDic[@"poster_path"];
    NSString *fullMiniPosterURLString = [baseURLString stringByAppendingString:miniPosterURLString];
    NSURL *miniPosterURl = [NSURL URLWithString:fullMiniPosterURLString];
    self.miniPoster.image = nil;
    [self.miniPoster setImageWithURL:miniPosterURl];
    
    NSURL *urlSmall = [NSURL URLWithString:[@"https://image.tmdb.org/t/p/w45" stringByAppendingString:self.detailDic[@"backdrop_path"]]];
    NSURL *urlLarge = [NSURL URLWithString:[@"https://image.tmdb.org/t/p/original" stringByAppendingString:self.detailDic[@"backdrop_path"]]];
    
    NSURLRequest *requestSmall = [NSURLRequest requestWithURL:urlSmall];
    NSURLRequest *requestLarge = [NSURLRequest requestWithURL:urlLarge];
    
    DetailsViewController *weakSelf = self;
    self.widePoster.image = nil;
    
    [self.widePoster setImageWithURLRequest:requestSmall
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *smallImage) {
                                       
                                       // smallImageResponse will be nil if the smallImage is already available
                                       // in cache (might want to do something smarter in that case).
                                       weakSelf.widePoster.alpha = 0.0;
                                       weakSelf.widePoster.image = smallImage;
                                       
                                       [UIView animateWithDuration:0.3
                                                        animations:^{
                                                            
                                                            weakSelf.widePoster.alpha = 1.0;
                                                            
                                                        } completion:^(BOOL finished) {
                                                            // The AFNetworking ImageView Category only allows one request to be sent at a time
                                                            // per ImageView. This code must be in the completion block.
                                                            [weakSelf.widePoster setImageWithURLRequest:requestLarge
                                                                                  placeholderImage:smallImage
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage * largeImage) {
                                                                                                weakSelf.widePoster.image = largeImage;
                                                                                  }
                                                                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                               // do something for the failure condition of the large image request
                                                                                               // possibly setting the ImageView's image to a default image
                                                                                           }];
                                                        }];
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                       // do something for the failure condition
                                       // possibly try to get the large image
                                        weakSelf.widePoster.alpha = 0.0;
                                        weakSelf.widePoster.image = [UIImage imageNamed:@"LuffySad"];
                                        
                                        //Animate UIImageView back to alpha 1 over 0.3sec
                                        [UIView animateWithDuration:0.3 animations:^{
                                            weakSelf.widePoster.alpha = 1.0;
                                        }];
                                   }];
    
    [self fetchVids];
}

- (void) fetchVids{
    NSNumber *movieID = self.detailDic[@"id"];
    NSString *firstHalf = [@"https://api.themoviedb.org/3/movie/" stringByAppendingString:[movieID stringValue]];
    NSURL *url = [NSURL URLWithString:[firstHalf stringByAppendingString:@"/videos?api_key=5f6121e6d04046de2b1f6f642e3f31b2"]];
    //make data request
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    //get session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    //what we will do with the data (session task)
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           //start animating the loading indicator
           if (error != nil) {
               //if there is an error loading the info
               NSLog(@"%@", [error localizedDescription]);
               //create an alert popup
               UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cannot Get Movies" message:@"The Internet connection seems to be offline." preferredStyle:UIAlertControllerStyleAlert];
               //add the action try again
               UIAlertAction *tryAgain = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler: ^(UIAlertAction * action) {[self fetchVids];}];
               [alert addAction:tryAgain];
               //present the alert
               [self presentViewController:alert animated:YES completion:nil];
           }
           else {
               //otherwise we are able to get the information and store it in our dictionaries
               NSDictionary *vidDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               NSLog(@"%@", vidDictionary);
               
               self.videos = vidDictionary[@"results"];
               
               for(NSDictionary *temp in self.videos) {
                   if([temp[@"type"] isEqualToString:@"Trailer"] || [temp[@"type"] isEqualToString:@"Teaser"]) {
                       self.video = temp;
                       break;
                   }
               }
               
               if(self.video == nil) {
                   self.video = self.videos[0];
               }
               
               [self.playerView loadWithVideoId:self.video[@"key"]];
               // TODO: Get the array of movies
               
           }
       }];
    [task resume];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
