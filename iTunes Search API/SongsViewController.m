//
//  SongsTableViewController.m
//  iTunes Search API
//
//  Created by Mincho Dzhagalov on 2/18/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//

#import "SongsViewController.h"
#import "Song.h"
#import "SongTableViewCell.h"
#import "AlbumTableViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface SongsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UISearchController *searchController;
@property (nonatomic) NSMutableArray *songs;
@property (strong, nonatomic) NSMutableDictionary *artworkByTrackId;
@property (weak, nonatomic) IBOutlet UITextField *songNameTextField;

@end

const NSString *BASE_URL = @"https://itunes.apple.com/search?media=music&entity=song&limit=25";

@implementation SongsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)parseJsonResponse:(NSArray *)response {
    [self.songs removeAllObjects];
    
    for (id entity in response) {
        Song *song = [[Song alloc] init];
        
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
        
        [self.songs addObject:song];
        
        [self.tableView reloadData];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        NSURL *url = [NSURL URLWithString:song.artworkUrl100];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error == nil) {
                UIImage *artwork = [UIImage imageWithData:data];
                [self.artworkByTrackId setObject:artwork forKey:song.trackId];
                [self.tableView reloadData];
            }
        }];
        
        [dataTask resume];
    }
}

- (IBAction)search:(UIButton *)sender {
    [self.songNameTextField endEditing:YES];
    
    NSString *songName = self.songNameTextField.text;
    
    if (songName && songName.length > 0) {
        NSString *urlString = [BASE_URL stringByAppendingString:[NSString stringWithFormat:@"&term=%@", songName]];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                               cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                           timeoutInterval:60.0];
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error == nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error:nil];
                    
                    [self parseJsonResponse:[jsonResponse valueForKey:@"results"]];
                });
            }
        }];
        
        [dataTask resume];
    }
}

- (IBAction)handleSongPurchaseRequest:(UIButton *)sender {
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.songs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reusable cell" forIndexPath:indexPath];
    
    [cell.artworkImageView setImage:nil];
    
    Song *song = self.songs[indexPath.row];
    [cell.trackNameLabel setText:song.trackName];
    [cell.artistNameLabel setText:song.artistName];
    
    NSString *formattedPrice = [NSString stringWithFormat:@"%.2f %@", song.trackPrice, song.currency];
    [cell.actionButton setTitle:formattedPrice forState:UIControlStateNormal];
    
    if ([self.artworkByTrackId objectForKey:song.trackId]) {
        [cell.artworkImageView setImage:[self.artworkByTrackId objectForKey:song.trackId]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchController.searchBar setHidden:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Song *song = self.songs[indexPath.row];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    AlbumTableViewController *atvc = [sb instantiateViewControllerWithIdentifier:@"Album Table View Controller"];
    atvc.albumId = song.albumId;
    
    [self.navigationController pushViewController:atvc animated:YES];
}

#pragma mark - Lazy Instantiation

- (NSMutableArray *)songs {
    if (!_songs) {
        _songs = [[NSMutableArray alloc] init];
    }
    
    return _songs;
}

- (NSMutableDictionary *)artworkByTrackId {
    if (!_artworkByTrackId) {
        _artworkByTrackId = [[NSMutableDictionary alloc] init];
    }
    
    return _artworkByTrackId;
}

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
