//
//  Album.h
//  iTunes Search API
//
//  Created by Mincho Dzhagalov on 2/18/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Album : NSObject

@property (nonatomic) NSMutableArray *songs;
@property (nonatomic) NSString *albumName;
@property (nonatomic) NSString *artistName;
@property (nonatomic) NSString *albumGenre;
@property (nonatomic) NSInteger numberOfSongs;
@property (nonatomic) NSDate *albumReleaseDate;
@property (nonatomic) double albumPrice;
@property (nonatomic) NSString *currency;
@property (nonatomic) NSString *artworkUrl100;

@end
