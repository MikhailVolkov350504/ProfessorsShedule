//
//  DataManager.h
//  TeacherSchedule
//
//  Created by Andrey Savich on 11/23/15.
//  Copyright © 2015 Volkov Mikhail. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject

#pragma mark - Singletone

+ (instancetype) sharedInstance;

#pragma mark - Service

- (void)setupMagicalRecord;
- (void)scheduleLoad;

#pragma mark - Save Teacher List

- (void)saveTeacherListFromArray:(NSArray *)array;
- (NSArray *)getAllTeachers;
- (NSArray *)findTeacherByName:(NSString *)name;

@end
