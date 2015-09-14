//
//  ViewController.m
//  Zalora
//
//  Created by Ulaş Sancak on 11/09/15.
//  Copyright (c) 2015 Ulaş Sancak. All rights reserved.
//

#import "ProductsViewController.h"
#import "WebServiceClient.h"
#import "ProductCell.h"
#import "LastCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ProductDetailViewController.h"

NSString *DirectionAscending = @"asc";
NSString *DirectionDescending = @"desc";
NSString *SortingPopularity = @"popularity";
NSString *SortingName = @"name";
NSString *SortingPrice = @"price";
NSString *SortingBrand = @"brand";

typedef enum {
    ProductLoadingStatusLoaded,
    ProductLoadingStatusLoading,
    ProductLoadingStatusError,
    ProductLoadingStatusFinished
}ProductLoadingStatus;

@interface ProductsViewController ()

@property (strong, nonatomic) NSMutableArray *products;
@property (assign, nonatomic) ProductLoadingStatus status;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSArray *sortings;
@property (strong, nonatomic) NSArray *directions;
@property (strong, nonatomic) NSString *pickedSortType;
@property (strong, nonatomic) NSString *pickedDirectionType;
@property (assign, nonatomic) NSUInteger maxItemNumber;
@property (assign, nonatomic) NSUInteger pageNumber;

@end

@implementation ProductsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _products = [[NSUserDefaults standardUserDefaults] objectForKey:@"products"];
    NSString *savedSortType = [[NSUserDefaults standardUserDefaults] objectForKey:@"pickedSortType"];
    if (savedSortType) {
        self.pickedSortType = savedSortType;
    }
    else {
        self.pickedSortType = SortingPopularity;
    }
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    _sortings = @[SortingPopularity, SortingName, SortingPrice, SortingBrand];
    _directions = @[DirectionAscending, DirectionDescending];
    [self manualRefresh];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setPickedSortType:(NSString *)pickedSortType {
    if ([_pickedSortType isEqual:pickedSortType]) {
        return;
    }
    _pickedSortType = pickedSortType;
    if ([pickedSortType isEqual:SortingPopularity]) {
        _pickedDirectionType = DirectionDescending;
    }
    else {
        _pickedDirectionType = DirectionAscending;
    }
    [[NSUserDefaults standardUserDefaults] setObject:pickedSortType forKey:@"pickedSortType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)manualRefresh {
    [self refresh];
    if (_products) {
        [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
        [self.refreshControl beginRefreshing];
    }
}

- (void)refresh {
    _maxItemNumber = 24;
    _pageNumber = 1;
    [self getProducts];
}

- (void)getProducts {
    _status = ProductLoadingStatusLoading;
    [[WebServiceClient client] getProductsWithMaxItemNumber:_maxItemNumber withPageNumber:_pageNumber withSortType:_pickedSortType withDirection:_pickedDirectionType withCompletionBlock:^(NSDictionary *dictionary, NSError *error) {
        [self.refreshControl endRefreshing];
        if (!error) {
            BOOL success = [dictionary[@"success"] boolValue];
            if (!success) {
                NSString *errorDescription = @"Unknown Error";
                NSArray *errorArray = dictionary[@"messages"][@"error"];
                if (errorArray.count > 0) {
                    errorDescription = errorArray[0];
                }
                error = [NSError errorWithDomain:@"com.zalora.ios" code:0 userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
                _status = ProductLoadingStatusError;
                 [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_products.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                return ;
            }
            NSMutableArray *newProducts = dictionary[@"metadata"][@"results"];
            if (newProducts.count == 0) {
                _status = ProductLoadingStatusFinished;
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_products.count inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                return;
            }
            if (_pageNumber == 1) {
                _products = [[NSMutableArray alloc] init];
                [self.tableView reloadData];
            }
            _status = ProductLoadingStatusLoaded;
            
            NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
            for (NSUInteger i = _products.count; i<_products.count + newProducts.count; i++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [indexPaths addObject:indexPath];
            }
            [_products addObjectsFromArray:newProducts];
            [[NSUserDefaults standardUserDefaults] setObject:_products forKey:@"products"];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            ++_pageNumber;
        }
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            _status = ProductLoadingStatusError;
             [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_products.count inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _products.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _products.count) {
        LastCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LastCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        if (_status == ProductLoadingStatusFinished) {
            [cell.indicator stopAnimating];
            cell.tickImageView.hidden = NO;
            cell.errorLabel.hidden = YES;
        }
        else {
            if (_status == ProductLoadingStatusError) {
                cell.errorLabel.hidden = NO;
                [cell.indicator stopAnimating];
            }
            else {
                cell.errorLabel.hidden = YES;
                [cell.indicator startAnimating];
                if (_status != ProductLoadingStatusLoading) {
                    [self getProducts];
                }
                else {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
            }
            cell.tickImageView.hidden = YES;
            
        }
        return cell;
    }
    ProductCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductCell" forIndexPath:indexPath];
    NSDictionary *product = _products[indexPath.row];
    cell.productNameLabel.text = product[@"data"][@"name"];
    cell.productBrandLabel.text = product[@"data"][@"brand"];
    cell.productPriceLabel.text = product[@"data"][@"price"];
    if ([product[@"images"] count] > 0) {
        [cell.productImageView sd_setImageWithURL:[NSURL URLWithString:product[@"images"][0][@"path"]] placeholderImage:nil];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != _products.count) {
        [self performSegueWithIdentifier:@"detail" sender:nil];
        return;
    }
    if (_status == ProductLoadingStatusError && indexPath.row == _products.count) {
        [self getProducts];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Picker View Delegates

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _sortings.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [_sortings[row] capitalizedString];
}

- (void)displayPickerView {
    [_pickerView selectRow:[_sortings indexOfObject:_pickedSortType] inComponent:0 animated:NO];
    _pickerSuperView.tag = 1;
    [UIView animateWithDuration:0.25
                     animations:^{
                         _pickerTopConstraint.constant = -_pickerSuperView.frame.size.height;
                         [self.view layoutIfNeeded];
                     }];
}

- (void)dismissPickerView {
    _pickerSuperView.tag = 0;
    [UIView animateWithDuration:0.25
                     animations:^{
                         _pickerTopConstraint.constant = 0;
                         [self.view layoutIfNeeded];
                     }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual:@"detail"]) {
        NSDictionary *productInfo = _products[self.tableView.indexPathForSelectedRow.row];
        ProductDetailViewController *detailViewController = segue.destinationViewController;
        detailViewController.productInfo = productInfo;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sortingPicked:(id)sender {
    NSString *pickedSortType = _sortings[[_pickerView selectedRowInComponent:0]];
    if (![_pickedSortType isEqual:pickedSortType]) {
        self.pickedSortType = _sortings[[_pickerView selectedRowInComponent:0]];
        [self manualRefresh];
    }
    [self dismissPickerView];
}

- (IBAction)displayDismissPickerView:(id)sender {
    if (_pickerSuperView.tag == 0) {
        [self displayPickerView];
    }
    else {
        [self dismissPickerView];
    }
}

- (IBAction)sortingCancelled:(id)sender {
    [self dismissPickerView];
}
@end
