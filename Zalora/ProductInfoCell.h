//
//  ProductInfoCell.h
//  Zalora
//
//  Created by Ulaş Sancak on 13/09/15.
//  Copyright (c) 2015 Ulaş Sancak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *productTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *productValueLabel;
@end
