//
//  ScheduleDetailViewController.h
//  TeacherSchedule
//
//  Created by Andrey Savich on 11/25/15.
//  Copyright © 2015 Volkov Mikhail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeacherCoreData.h"

@interface ScheduleDetailViewController : UITableViewController

@property (strong, nonatomic) TeacherCoreData *teacher;

@end
