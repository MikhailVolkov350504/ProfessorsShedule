//
//  ScheduleDetailViewController.m
//  TeacherSchedule
//
//  Created by Andrey Savich on 11/25/15.
//  Copyright © 2015 Volkov Mikhail. All rights reserved.
//

#import "ScheduleDetailViewController.h"

@interface ScheduleDetailViewController ()

@end

@implementation ScheduleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *teacherFullName = [NSString stringWithFormat:@"%@ %@",self.teacher.teacherFirstName, self.teacher.teacherLastName];
    self.title = teacherFullName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = @"cell";
    
    return cell;
}


@end