//
//  ScheduleDetailModel.h
//  TeacherSchedule
//
//  Created by Andrey Savich on 12/5/15.
//  Copyright © 2015 Volkov Mikhail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScheduleDetailModel : NSObject

@property(nonatomic,strong) NSString* currentWeekDay;
@property(nonatomic,strong) NSString* currentSubject;
@property(nonatomic,strong) NSString* currentLessonTime;
@property(nonatomic,strong) NSString* currentWeekNumber;
@property(nonatomic,strong) NSString* currentCabinet;
@property(nonatomic,strong) NSString* currentSubjectType;
@property(nonatomic,strong) NSString* currentNumSubgroup;
@property(nonatomic,strong) NSString* currentStudentGroup;
@property(nonatomic,strong) NSString* currentGroupType;


@end
