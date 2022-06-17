//
//  GridViewController.m
//  Flixter
//
//  Created by Jake Torres on 6/16/22.
//

#import "GridViewController.h"
#import "myCustomGridCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface GridViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet NSArray *movies;
@end

@implementation GridViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self fetchMovies];
}

- (void) fetchMovies {
    //get url
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=5f6121e6d04046de2b1f6f642e3f31b2"];
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
               UIAlertAction *tryAgain = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler: ^(UIAlertAction * action) {[self fetchMovies];}];
               [alert addAction:tryAgain];
               //present the alert
               [self presentViewController:alert animated:YES completion:nil];
           }
           else {
               //otherwise we are able to get the information and store it in our dictionaries
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               
               NSLog(@"%@", dataDictionary);
               // TODO: Get the array of movies
               self.movies = dataDictionary[@"results"];
               
               //reload teh data in the table in the table since the internet updates slower than the table
               [self.collectionView reloadData];
               //stop the loading indicators
           }
       }];
    [task resume];
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    myCustomGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CustomGridCell" forIndexPath:indexPath];
    
    NSDictionary *movie = self.movies[indexPath.item];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    
    NSURL *posterURl = [NSURL URLWithString:fullPosterURLString];
    
    cell.cellImage.image = nil;
    [cell.cellImage setImageWithURL:posterURl];
    
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.movies count];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
      //Get the new view controller using [segue destinationViewController].
      //Pass the selected object to the new view controller.
     NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
     NSDictionary *dataToPass = self.movies[indexPath.item];
     DetailsViewController *detailVC = [segue destinationViewController];
     detailVC.detailDic = dataToPass;
 }

@end
