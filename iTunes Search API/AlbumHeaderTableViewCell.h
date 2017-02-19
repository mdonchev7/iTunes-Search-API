//
//  AlbumHeaderTableViewCell.h
//  iTunes Search API
//
//  Created by Mincho Dzhagalov on 2/18/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumHeaderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *albumArtworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumGenreLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSongsLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumReleaseDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
