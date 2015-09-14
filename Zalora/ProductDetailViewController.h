//
//  ProductDetailViewController.h
//  Zalora
//
//  Created by Ulaş Sancak on 12/09/15.
//  Copyright (c) 2015 Ulaş Sancak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSDictionary *productInfo;

@property (weak, nonatomic) IBOutlet UICollectionView *productImagesCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *productSpecsTableView;
@end
