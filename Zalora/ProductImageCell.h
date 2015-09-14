//
//  ProductImageCell.h
//  Zalora
//
//  Created by Ulaş Sancak on 13/09/15.
//  Copyright (c) 2015 Ulaş Sancak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductImageCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@end
