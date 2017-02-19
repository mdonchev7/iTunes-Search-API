//
//  SongInAlbumTableViewCell.h
//  iTunes Search API
//
//  Created by Mincho Dzhagalov on 2/18/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongInAlbumTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *songNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *songDurationLabel;
@property (weak, nonatomic) IBOutlet UIButton *songPrice;

@end
