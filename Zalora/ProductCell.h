//
//  ProductCell.h
//  Zalora
//
//  Created by Ulaş Sancak on 11/09/15.
//  Copyright (c) 2015 Ulaş Sancak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productBrandLabel;
@property (weak, nonatomic) IBOutlet UILabel *productPriceLabel;

@end
