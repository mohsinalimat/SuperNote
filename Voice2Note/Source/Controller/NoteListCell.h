//
//  NoteListCell.h
//  Voice2Note
//
//  Created by liaojinxing on 14-6-12.
//  Copyright (c) 2014年 jinxing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class VNNote;

@interface NoteListCell : UITableViewCell

- (void)updateWithNote:(VNNote *)note;

@end
