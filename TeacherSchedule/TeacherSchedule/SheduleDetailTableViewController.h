//
//  SheduleDetailTableViewController.h
//  TeacherSchedule
//
//  Created by Andrey Savich on 25/11/2015.
//  Copyright (c) 2015 Volkov Mikhail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeacherCoreData.h"

@interface SheduleDetailTableViewController : UITableViewController

@property (strong, nonatomic) TeacherCoreData *teacher;

@end
