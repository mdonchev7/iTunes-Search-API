//
//  Album.m
//  iTunes Search API
//
//  Created by Mincho Dzhagalov on 2/18/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//

#import "Album.h"

@implementation Album

- (NSMutableArray *)songs {
    if (!_songs) {
        _songs = [[NSMutableArray alloc] init];
    }
    
    return _songs;
}

- (NSInteger)numberOfSongs {
    return [self.songs count];
}

@end
