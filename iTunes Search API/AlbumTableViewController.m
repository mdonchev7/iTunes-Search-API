//
//  AlbumsTableViewController.m
//  iTunes Search API
//
//  Created by Mincho Dzhagalov on 2/18/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//

#import "AlbumTableViewController.h"
#import "AlbumHeaderTableViewCell.h"
#import "SongInAlbumTableViewCell.h"
#import "Song.h"
#import "Album.h"
#import "NSString+FontAwesome.h"

#import <AVFoundation/AVFoundation.h>

@interface AlbumTableViewController () <AVAudioPlayerDelegate>

@property (nonatomic) Album *album;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic) NSInteger numberOfSongCurrentlyPlaying;

@end

@implementation AlbumTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    NSString *urlString = [@"https://itunes.apple.com/lookup?entity=song" stringByAppendingString:[NSString stringWithFormat:@"&id=%@", self.albumId]];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error:nil];
            
            [self parseJsonResponse:[jsonResponse valueForKey:@"results"]];
        }
    }];
    
    [dataTask resume];
}

- (void)parseJsonResponse:(NSArray *)response {
    self.album.albumName = [response[0] valueForKey:@"collectionName"];
    self.album.artistName = [response[0] valueForKey:@"artistName"];
    self.album.albumGenre = [response[0] valueForKey:@"primaryGenreName"];
    self.album.albumPrice = [[response[0] valueForKey:@"collectionPrice"] doubleValue];
    self.album.currency = [response[0] valueForKey:@"currency"];
    NSLog(@"%@", [response[0] valueForKey:@"releaseDate"]);
    self.album.artworkUrl100 = [response[0] valueForKey:@"artworkUrl100"];
    
    for (int i = 1; i < [response count]; i++) {
        Song *song = [[Song alloc] init];
        
        NSDictionary *entity = response[i];
        
        song.trackId = [entity valueForKey:@"trackId"];
        song.trackName = [entity valueForKey:@"trackName"];
        song.artistName = [entity valueForKey:@"artistName"];
        song.trackPrice = [[entity valueForKey:@"trackPrice"] doubleValue];
        song.currency = [entity valueForKey:@"currency"];
        song.trackTimeMillis = [[entity valueForKey:@"trackTimeMillis"] doubleValue];
        song.albumId = [entity valueForKey:@"collectionId"];
        song.artistUrl = [entity valueForKey:@"artistUrl"];
        song.artworkUrl30 = [entity valueForKey:@"artworkUrl30"];
        song.artworkUrl60 = [entity valueForKey:@"artworkUrl60"];
        song.artworkUrl100 = [entity valueForKey:@"artworkUrl100"];
        song.previewUrl = [entity valueForKey:@"previewUrl"];
        
        [self.album.songs addObject:song];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.album.songs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SongInAlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reusable cell" forIndexPath:indexPath];
    
    Song *song = self.album.songs[indexPath.row];
    
    cell.songNumberLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row + 1];
    cell.artistNameLabel.text = song.artistName;
    cell.songNameLabel.text = song.trackName;
    
    NSInteger seconds = song.trackTimeMillis / 1000;
    NSInteger minutes = seconds / 60;
    seconds = seconds % 60;
    
    NSString *duration = [NSString stringWithFormat:@"%.2ld:%.2ld", (long)minutes, (long)seconds];
    
    cell.songDurationLabel.text = [NSString stringWithFormat:@"%@", duration];
    
    [cell.songPrice setTitle:[NSString stringWithFormat:@"%.2f %@", song.trackPrice, song.currency] forState:UIControlStateNormal];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 120.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    AlbumHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"album header cell"];
    
    cell.backgroundView = [UIView new];
    cell.backgroundView.backgroundColor = [UIColor whiteColor];
    
    [cell.activityIndicator startAnimating];
    
    [cell.albumNameLabel setText:self.album.albumName];
    [cell.artistNameLabel setText:self.album.artistName];
    [cell.albumGenreLabel setText:self.album.albumGenre];
    [cell.numberOfSongsLabel setText:[NSString stringWithFormat:@"%ld Songs", (long)self.album.numberOfSongs]];
    [cell.actionButton setTitle:[NSString stringWithFormat:@"%.2f %@", self.album.albumPrice, self.album.currency] forState:UIControlStateNormal];
    [cell.albumReleaseDateLabel setText:[NSString stringWithFormat:@"%@", self.album.albumReleaseDate]];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    NSURL *url = [NSURL URLWithString:self.album.artworkUrl100];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *artwork = [UIImage imageWithData:data];
                cell.albumArtworkImageView.image = artwork;
                [cell.activityIndicator setHidesWhenStopped:YES];
                [cell.activityIndicator stopAnimating];
            });
        }
    }];
    
    [dataTask resume];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.audioPlayer.isPlaying && self.numberOfSongCurrentlyPlaying == indexPath.row) {
        [self.audioPlayer pause];
        SongInAlbumTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        CATransition *animation = [CATransition animation];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = kCATransitionFade;
        animation.duration = 0.50f;
        [cell.songNumberLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
        
        cell.songNumberLabel.font = [UIFont fontWithName:@"FontAwesome" size:17.0f];
        [cell.songNumberLabel setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-play"]];
    } else if (self.numberOfSongCurrentlyPlaying == indexPath.row) {
        [self.audioPlayer play];
        
        SongInAlbumTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        CATransition *animation = [CATransition animation];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = kCATransitionFade;
        animation.duration = 0.50f;
        [cell.songNumberLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
        
        cell.songNumberLabel.font = [UIFont fontWithName:@"FontAwesome" size:17.0f];
        [cell.songNumberLabel setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-pause"]];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
            NSIndexPath *previouslyPlayingIndexPath = [NSIndexPath indexPathForRow:self.numberOfSongCurrentlyPlaying - 1 inSection:0];
            SongInAlbumTableViewCell *cell = [self.tableView cellForRowAtIndexPath:previouslyPlayingIndexPath];
            
            CATransition *animation = [CATransition animation];
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.type = kCATransitionFade;
            animation.duration = 0.50f;
            [cell.songNumberLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
            
            [cell.songNumberLabel setFont:[UIFont systemFontOfSize:15.0f]];
            [cell.songNumberLabel setText:[NSString stringWithFormat:@"%ld", (long)self.numberOfSongCurrentlyPlaying]];
        });
        
        self.numberOfSongCurrentlyPlaying = indexPath.row;
        
        Song *song = self.album.songs[indexPath.row];
        NSString *previewUrlString = song.previewUrl;
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        NSURL *url = [NSURL URLWithString:previewUrlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error == nil) {
                if (error == nil) {
                    NSError *err;
                    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&err];
                    
                    if (err == nil) {
                        [self.audioPlayer prepareToPlay];
                        self.audioPlayer.delegate = self;
                        [self.audioPlayer play];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            SongInAlbumTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                            
                            CATransition *animation = [CATransition animation];
                            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                            animation.type = kCATransitionFade;
                            animation.duration = 0.50;
                            [cell.songNumberLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
                            
                            cell.songNumberLabel.font = [UIFont fontWithName:@"FontAwesome" size:17.0f];
                            [cell.songNumberLabel setText:[NSString fontAwesomeIconStringForIconIdentifier:@"fa-pause"]];
                        });
                    } else {
                        NSLog(@"err!");
                    }
                } else {
                    NSLog(@"error!");
                }
            }
        }];
        
        [dataTask resume];
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag) {
        NSIndexPath *previouslyPlayingIndexPath = [NSIndexPath indexPathForRow:self.numberOfSongCurrentlyPlaying inSection:0];
        SongInAlbumTableViewCell *cell = [self.tableView cellForRowAtIndexPath:previouslyPlayingIndexPath];
        
        CATransition *animation = [CATransition animation];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = kCATransitionFade;
        animation.duration = 0.50f;
        [cell.songNumberLabel.layer addAnimation:animation forKey:@"kCATransitionFade"];
        
        [cell.songNumberLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [cell.songNumberLabel setText:[NSString stringWithFormat:@"%ld", (long)self.numberOfSongCurrentlyPlaying]];
    }
}

- (IBAction)handleAlbumPurchaseRequest:(UIButton *)sender {
    [self presentAlertController];
}
- (IBAction)handleSongPurchaseRequest:(UIButton *)sender {
    [self presentAlertController];
}

- (void)presentAlertController {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Album Purschase"
                                 message:@"If you wish to purchase any music, please go to the iTunes app."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"Ok"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Lazy Instantiation

- (Album *)album {
    if (!_album) {
        _album = [[Album alloc] init];
    }
    
    return _album;
}

#pragma mark - Delegate Methods

- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
