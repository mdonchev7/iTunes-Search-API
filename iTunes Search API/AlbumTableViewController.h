//
//  AlbumsTableViewController.h
//  iTunes Search API
//
//  Created by Mincho Dzhagalov on 2/18/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumTableViewController : UITableViewController <NSURLSessionDelegate>

@property (nonatomic) NSString *albumId;

@end
