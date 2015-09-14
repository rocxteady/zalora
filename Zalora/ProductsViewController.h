//
//  ViewController.h
//  Zalora
//
//  Created by Ulaş Sancak on 11/09/15.
//  Copyright (c) 2015 Ulaş Sancak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *pickerSuperView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortingBarButtonItem;
- (IBAction)sortingPicked:(id)sender;
- (IBAction)displayDismissPickerView:(id)sender;
- (IBAction)sortingCancelled:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pickerTopConstraint;
@end

