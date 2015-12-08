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
#import "TeacherCoreData+CoreDataProperties.h"
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

#pragma mark - Service

- (void)scheduleLoad {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:@"yes" forKey:@"download"];
}

#pragma mark - Teacher List

- (void)setupMagicalRecord {
    [MagicalRecord setupAutoMigratingCoreDataStack];
}

- (void)saveTeacherListFromArray:(NSArray *)array {
    [self clearScheduleStorage];
    
    for (Teacher *teacher in array) {
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *  localContext) {
            TeacherCoreData *teacherObject = [TeacherCoreData MR_createEntityInContext:localContext];
            teacherObject.teacherFirstName = teacher.firstName;
            teacherObject.teacherLastName = teacher.lastName;
            teacherObject.teacherID = teacher.teacherID;
            
        } completion:^(BOOL contextDidSave, NSError *  error) {
            NSLog(@"Complete");
        }];
    }
}

- (NSArray *)getAllTeachers {
    NSArray *teachers = [TeacherCoreData MR_findAll];
    return teachers;
}

- (NSArray *)findTeacherByName:(NSString *)name {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.teacherLastName contains[c] %@",name];
    NSArray *teacherList = [TeacherCoreData MR_findAllWithPredicate:predicate];
    return teacherList;
}

- (void)clearScheduleStorage {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    [TeacherCoreData MR_truncateAllInContext:context];
    [context MR_saveToPersistentStoreAndWait];
}

@end