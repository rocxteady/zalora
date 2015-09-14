//
//  LastCell.h
//  Zalora
//
//  Created by Ulaş Sancak on 11/09/15.
//  Copyright (c) 2015 Ulaş Sancak. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LastCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *tickImageView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UILabel *errorLabel;
@end
