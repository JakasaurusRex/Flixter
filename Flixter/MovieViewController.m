//
//  MovieViewController.m
//  Flixter
//
//  Created by Jake Torres on 6/15/22.
//

#import "MovieViewController.h"
#import "myCustomCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MovieViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) NSArray *filteredMovies;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //setting the datasource and delegate as this controller
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.searchBarView.delegate = self;
    // Do any additional setup after loading the view.
    
    //requests the data that will be put in the tableview
    [self fetchMovies];
    
    
    //refresh indicator
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
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
           [self.activityIndicator startAnimating];
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
               self.filteredMovies = self.movies;
               //reload teh data in the table in the table since the internet updates slower than the table
               [self.tableView reloadData];
               //stop the loading indicators
               [self.refreshControl endRefreshing];
               [self.activityIndicator stopAnimating];
               // TODO: Store the movies in a property to use elsewhere
               // TODO: Reload your table view data
           }
       }];
    [task resume];
}

//assigns the amount of movies to the amount of rows in the tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredMovies.count;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (searchText.length != 0) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"title"] containsString:searchText];
        }];
        self.filteredMovies = [self.movies filteredArrayUsingPredicate:predicate];
        
        NSLog(@"%@", self.filteredMovies);
        
    }
    else {
        self.filteredMovies = self.movies;
    }
    
    [self.tableView reloadData];
 
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBarView {
    self.searchBarView.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBarView.text = @"";
    [self.searchBarView resignFirstResponder];
}

//custom cells and overriding the text in it
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    myCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
    NSDictionary *movie = self.filteredMovies[indexPath.row];
    
    cell.titleLabel.text = movie[@"title"];
    cell.descriptionLabel.text = movie[@"overview"];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    
    NSURL *posterURl = [NSURL URLWithString:fullPosterURLString];
    
    cell.posterImage.image = nil;
    [cell.posterImage setImageWithURL:posterURl];
    
    return cell;
}

//todo: will deselect the cell after releasing click on it
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Navigation

//this is to send the information to the second screen
//In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     //Get the new view controller using [segue destinationViewController].
     //Pass the selected object to the new view controller.
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSDictionary *dataToPass = self.movies[indexPath.row];
    DetailsViewController *detailVC = [segue destinationViewController];
    detailVC.detailDic = dataToPass;
    
}


@end
