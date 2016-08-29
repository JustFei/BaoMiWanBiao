//
//  LocalAlbumTableViewController.m
//  AlbumTest
//
//  Created by ejiang on 14-7-28.
//  Copyright (c) 2014年 daijier. All rights reserved.
//

#import "LocalAlbumTableViewController.h"

@interface LocalAlbumTableViewController ()
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *albums;
@end

@implementation LocalAlbumTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        UIBarButtonItem *cancle=[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancleAction)];
        self.navigationItem.rightBarButtonItem=cancle;
        self.title=@"选择相册";
        // self.navigationController=[[UINavigationController alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //    if(([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0)) {
    //        self.edgesForExtendedLayout = UIRectEdgeNone;
    //        self.extendedLayoutIncludesOpaqueBars = NO;
    //        self.modalPresentationCapturesStatusBarAppearance = NO;
    //    }
    
    //    if (self.assetsLibrary == nil) {
    //        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    //    }
    if (self.albums == nil) {
        _albums = [[NSMutableArray alloc] init];
    } else {
        [self.albums removeAllObjects];
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LocalAlbumCell" bundle:nil] forCellReuseIdentifier:@"AlbumCell"];
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        
    };
    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
            [self.albums addObject:group];
        }
        else
        {
            [self.tableView reloadData];
            //[self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    };
    
    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
    [[AssetHelper defaultAssetsLibrary] enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)cancleAction{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num=[_albums count];
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier=@"AlbumCell";
    LocalAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    ALAssetsGroup *group=[_albums objectAtIndex:indexPath.row];
    CGImageRef posterImageRef=[group posterImage];
    UIImage *posterImage=[UIImage imageWithCGImage:posterImageRef];
    [cell.imgCover setImage:posterImage];
    cell.lbName.text=[group valueForProperty:ALAssetsGroupPropertyName];
    cell.lbCount.text=[@(group.numberOfAssets) stringValue];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    if(self.delegate!=nil)
    {
        [self.delegate selectAlbum:self.albums[indexPath.row]];
    }
    
}


@end
