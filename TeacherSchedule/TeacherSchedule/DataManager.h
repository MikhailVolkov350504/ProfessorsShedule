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

#pragma mark - Database

- (void)setupMagicalRecord;
- (NSArray *)findTeachersWithString:(NSString *)string;

#pragma mark - Save Teacher List

- (void)saveTeacherListFromArray:(NSArray *)array;
- (NSArray *)getAllTeachers;

@end
