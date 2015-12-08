//
//  ScheduleDetailViewController.h
//  TeacherSchedule
//
//  Created by Andrey Savich on 11/25/15.
//  Copyright © 2015 Volkov Mikhail. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeacherCoreData.h"

@interface ScheduleDetailViewController : UITableViewController <NSXMLParserDelegate>

@property (strong, nonatomic) TeacherCoreData *teacher;

@property(nonatomic,strong) NSMutableArray* dayCount;

@property(nonatomic,strong) NSMutableArray* elementsCount;//количество строчек в табличке
@property(nonatomic,strong) NSString* currentElement;
@property(nonatomic,strong) NSMutableString* currentWeekDay;
@property(nonatomic,strong) NSMutableString* currentSubject;
@property(nonatomic,strong) NSMutableString* currentLessonTime;
@property(nonatomic,strong) NSMutableString* currentWeekNumber;
@property(nonatomic,strong) NSMutableString* currentCabinet;
@property(nonatomic,strong) NSMutableString* currentSubjectType;
@property(nonatomic,strong) NSMutableString* currentNumSubgroup;


@property(nonatomic,strong) NSMutableString* currentStudentGroup;
@property(nonatomic,strong) NSMutableString* currentGroupType;
@property(nonatomic,strong) NSMutableString* currentWeek;


@end
