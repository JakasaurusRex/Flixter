//
//  DetailsViewController.h
//  Flixter
//
//  Created by Jake Torres on 6/15/22.
//

#import <UIKit/UIKit.h>
#import "YTPlayerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController
@property (strong, nonatomic) IBOutlet YTPlayerView *playerView;
@property (nonatomic, strong) NSDictionary *detailDic;
@end

NS_ASSUME_NONNULL_END
