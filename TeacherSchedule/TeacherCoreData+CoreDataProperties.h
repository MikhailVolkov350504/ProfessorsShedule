//
//  TeacherCoreData+CoreDataProperties.h
//  TeacherSchedule
//
//  Created by Andrey Savich on 11/25/15.
//  Copyright © 2015 Volkov Mikhail. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TeacherCoreData.h"

@interface TeacherCoreData (CoreDataProperties)

@property (nonatomic, retain) NSString *teacherFirstName;
@property (nonatomic, retain) NSString *teacherLastName;
@property (nonatomic, retain) NSString *teacherID;

@end
