//
//  Song.h
//  iTunes Search API
//
//  Created by Mincho Dzhagalov on 2/18/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Song : NSObject

@property (nonatomic) NSString *trackId;
@property (nonatomic) NSString *trackName;
@property (nonatomic) NSString *artistName;
@property (nonatomic) double trackPrice;
@property (nonatomic) NSString *currency;
@property (nonatomic) NSInteger trackTimeMillis;
@property (nonatomic) NSString *albumId;
@property (nonatomic) NSDate *releaseDate;
@property (nonatomic) NSString *artistUrl;
@property (nonatomic) NSString *artworkUrl30;
@property (nonatomic) NSString *artworkUrl60;
@property (nonatomic) NSString *artworkUrl100;
@property (nonatomic) NSString *previewUrl;

@end
