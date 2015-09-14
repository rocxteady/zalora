//
//  ProductDetailViewController.m
//  Zalora
//
//  Created by Ulaş Sancak on 12/09/15.
//  Copyright (c) 2015 Ulaş Sancak. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "WebServiceClient.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ProductImageCell.h"
#import "ProductInfoCell.h"
#import "ProductDescriptionCell.h"

@interface ProductDetailViewController ()

@property (strong, nonatomic) NSDictionary *productDetailedInfo;
@property (strong, nonatomic) NSMutableArray *productInfoArray;
@property (strong, nonatomic) NSArray *productImages;

@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation ProductDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _productDetailedInfo = [[NSUserDefaults standardUserDefaults] objectForKey:_productInfo[@"data"][@"url"]];
    if (_productDetailedInfo) {
        [self loadViews];
    }
    _productSpecsTableView.rowHeight = UITableViewAutomaticDimension;
    _productSpecsTableView.estimatedRowHeight = 44.0;
    _refreshControl = [[UIRefreshControl alloc] init];
    [_productSpecsTableView addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(getProductDetail) forControlEvents:UIControlEventValueChanged];
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicator.hidesWhenStopped = YES;
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_indicator];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.title = _productInfo[@"data"][@"name"];
    [self getProductDetail];
    // Do any additional setup after loading the view.
}

- (void)getProductDetail {
    [_indicator startAnimating];
    [[WebServiceClient client] getProductDetailWithURL:_productInfo[@"data"][@"url"] withCompletionBlock:^(NSDictionary *dictionary, NSError *error) {
        [_indicator stopAnimating];
        [_refreshControl endRefreshing];
        if (!error) {
            BOOL success = [dictionary[@"success"] boolValue];
            if (!success) {
                NSString *errorDescription = @"Unknown Error";
                NSArray *errorArray = dictionary[@"messages"][@"error"];
                if (errorArray.count > 0) {
                    errorDescription = errorArray[0];
                }
                error = [NSError errorWithDomain:@"com.zalora.ios" code:0 userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
            }
            else {
                _productDetailedInfo = dictionary[@"metadata"][@"data"];
                [[NSUserDefaults standardUserDefaults] setObject:_productDetailedInfo forKey:_productInfo[@"data"][@"url"]];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [self loadViews];
            }
        }
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
        }
    }];
}

- (void)loadViews {
    _productImages = _productDetailedInfo[@"image_list"];
    _productInfoArray = [[NSMutableArray alloc] init];
    NSDictionary *attributes = _productDetailedInfo[@"attributes"];
    NSString *description = _productDetailedInfo[@"description"];
    if (description.length > 0) {
        [_productInfoArray addObject:@{@"Description" : description}];
    }
    NSString *activatedAt = _productDetailedInfo[@"activated_at"];
    if (activatedAt.length > 0) {
        [_productInfoArray addObject:@{@"Activated At" : activatedAt}];
    }
    NSString *brand = _productDetailedInfo[@"brand"];
    if (brand.length > 0) {
        [_productInfoArray addObject:@{@"Brand" : brand}];
    }
    NSString *price = _productDetailedInfo[@"price"];
    if (price.length > 0) {
        [_productInfoArray addObject:@{@"Price" : price}];
    }
    NSString *supplierName = _productDetailedInfo[@"supplier_name"];
    if (supplierName.length > 0) {
        [_productInfoArray addObject:@{@"Supplier Name" : supplierName}];
    }
    NSString *color = attributes[@"Colour"];
    if (color.length > 0) {
        [_productInfoArray addObject:@{@"Colour" : color}];
    }
    NSString *careLabel = attributes[@"Care Label"];
    if (careLabel.length > 0) {
        [_productInfoArray addObject:@{@"Care Label" : careLabel}];
    }
    NSString *composition = attributes[@"Composition"];
    if (composition.length > 0) {
        [_productInfoArray addObject:@{@"Composition" : composition}];
    }
    NSString *measurements = attributes[@"Measurements"];
    if (measurements.length > 0) {
        [_productInfoArray addObject:@{@"Measurements" : measurements}];
    }
    [_productImagesCollectionView reloadData];
    [_productSpecsTableView reloadData];
}

#pragma mark - Collection View Delegates

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _productImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductImageCell" forIndexPath:indexPath];
    NSDictionary *imageInfo = _productImages[indexPath.row];
    [cell.indicator startAnimating];
    [cell.productImageView sd_setImageWithURL:[NSURL URLWithString:imageInfo[@"url"]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [cell.indicator stopAnimating];
    }];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 136.0);
}

#pragma mark - Table View Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _productInfoArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info = _productInfoArray[indexPath.row];
    if ([info.allKeys[0] isEqual:@"Description"]) {
        ProductDescriptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductDescriptionCell" forIndexPath:indexPath];
        cell.productDesctiptionLabel.text = info[info.allKeys[0]];
        return cell;
    }
    ProductInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductInfoCell" forIndexPath:indexPath];
    cell.productTitleLabel.text = info.allKeys[0];
    cell.productValueLabel.text = info[info.allKeys[0]];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
