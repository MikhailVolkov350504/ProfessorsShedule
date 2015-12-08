//
//  CellTableViewCell.h
//  TeacherSchedule
//
//  Created by Andrey Savich on 05/12/2015.
//  Copyright (c) 2015 Volkov Mikhail. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeStart;
//@property (weak, nonatomic) IBOutlet UILabel *timeStart;
@property (weak, nonatomic) IBOutlet UILabel *timeEnd;
@property (weak, nonatomic) IBOutlet UILabel *timeSlash;

@property (weak, nonatomic) IBOutlet UILabel *subject;

@property (weak, nonatomic) IBOutlet UILabel *cabinet;
@property (weak, nonatomic) IBOutlet UILabel *weekNumber;

@property (weak, nonatomic) IBOutlet UILabel *type;
@property (weak, nonatomic) IBOutlet UILabel *group;
@property (weak, nonatomic) IBOutlet UILabel *numSubgroup;

@end

