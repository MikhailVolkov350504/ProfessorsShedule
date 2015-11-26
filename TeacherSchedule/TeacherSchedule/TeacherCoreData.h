//
//  TeacherCoreData.h
//  TeacherSchedule
//
//  Created by Andrey Savich on 24/11/2015.
//  Copyright (c) 2015 Volkov Mikhail. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TeacherCoreData : NSManagedObject

@property (nonatomic, retain) NSString * teacherFirstName;
@property (nonatomic, retain) NSString * teacherLastName;
@property (nonatomic, retain) NSString * teacherID;

@end
