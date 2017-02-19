//
//  SongTableViewCell.h
//  iTunes Search API
//
//  Created by Mincho Dzhagalov on 2/18/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *artworkImageView;
@property (weak, nonatomic) IBOutlet UILabel *trackNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@end
