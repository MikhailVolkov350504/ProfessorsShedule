//
//  DataManager.m
//  TeacherSchedule
//
//  Created by Andrey Savich on 11/23/15.
//  Copyright © 2015 Volkov Mikhail. All rights reserved.
//

#import "DataManager.h"
#import <MagicalRecord/MagicalRecord.h>
//Models
#import "Teacher.h"
#import "TeacherCoreData.h"

@implementation DataManager

#pragma mark - Singletone

+ (instancetype) sharedInstance {
    static id manager = nil;
    
    static dispatch_once_t onceTask;
    dispatch_once(&onceTask, ^{
        manager = [[[self class] alloc]init];
    });
    
    return manager;
}

#pragma mark - Save Teacher List

- (void)setupMagicalRecord {
    [MagicalRecord setupAutoMigratingCoreDataStack];
}

- (void)saveTeacherListFromArray:(NSArray *)array {
    for (Teacher *teacher in array) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            TeacherCoreData *teacherObject = [TeacherCoreData MR_createEntityInContext:localContext];
            teacherObject.teacherFirstName = teacher.firstName;
            teacherObject.teacherLastName = teacher.lastName;
            teacherObject.teacherID = teacher.teacherID;
            
        } completion:^(BOOL contextDidSave, NSError *error) {
            NSLog(@"Complete");
        }];
    }
}

- (NSArray *)findTeachersWithString:(NSString *)string {
    if ([string isEqualToString:@" "]) {
        return [self getAllTeachers];
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"teacherLastName == %@",string];
        NSArray *teacherList = [TeacherCoreData MR_findAllWithPredicate:predicate];
        return teacherList;
    }
}

- (NSArray *)getAllTeachers {
    NSArray *teachers = [TeacherCoreData MR_findAll];
    return teachers;
}

@end
