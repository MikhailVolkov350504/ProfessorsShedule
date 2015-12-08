//
//  ScheduleDetailViewController.m
//  TeacherSchedule
//
//  Created by Andrey Savich on 11/25/15.
//  Copyright © 2015 Volkov Mikhail. All rights reserved.
//
#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

#import "ScheduleDetailViewController.h"
#import "CellTableViewCell.h"
//либа для проверки включенного интернета
#import "Reachability.h"

#import "ScheduleDetailModel.h"

@interface ScheduleDetailViewController () 

@property (strong, nonatomic) NSMutableData *scheduleData;//tableView DataSource
@property (strong,nonatomic) NSMutableString* currentTeacherLink;

@end

@implementation ScheduleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dayCount = [NSMutableArray array];
//    NSString *teacherFullName = [NSString stringWithFormat:@"%@ %@",self.teacher.teacherFirstName, self.teacher.teacherLastName];
//    self.title = teacherFullName;
    _currentTeacherLink = [NSMutableString stringWithString:@"http://www.bsuir.by/schedule/rest/employee/"];
    [_currentTeacherLink appendString: self.teacher.teacherID];
    //[self testInternetConnection];
    
    
    
    NSDate *currentDate = [NSDate date];
    NSLog(@"CURRENT DATE %@", currentDate);
    
    
    NSString* pointDate = @"2015-06-08";
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate* startDate = [formatter dateFromString:pointDate];
    NSString* curDate = [formatter stringFromDate:currentDate];
    NSDate* endDate = [formatter dateFromString:curDate];
    
    NSCalendar* gregorianCalendar = [[NSCalendar alloc]
                                     initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components = [gregorianCalendar components:NSCalendarUnitDay fromDate:startDate toDate:endDate options:0];
    NSLog(@"разница между днями: %ld",[components day]);
    NSUInteger weekCount = [components day]/7;
    _currentWeek = [NSMutableString stringWithFormat:@"%lu",(unsigned long)weekCount];
    NSLog(@"current week %@",_currentWeek);
    
    NSMutableString *teacherFullName = [NSMutableString stringWithFormat:@"%@ %@",self.teacher.teacherFirstName, self.teacher.teacherLastName];
    
    if([_currentWeek intValue] %4 == 0)
                {
                    [teacherFullName appendString:@"   1"];
                }
                if([_currentWeek intValue] %4 == 1)
                {
                    [teacherFullName appendString:@"   2"];                }
                if([_currentWeek intValue] %4 == 2)
                {
                    [teacherFullName appendString:@"   3"];
                }
                if([_currentWeek intValue] %4 == 3)
                {
                    [teacherFullName appendString:@"   4"];
                }

        
        
        
    
//    NSMutableString* header = @"    ";
//    [header appendString:_currentWeek];
//        [teacherFullName appendString:header];
    self.title = teacherFullName;

    
    [self loadData];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)testInternetConnection {
    Reachability *internetReachable = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    internetReachable.reachableBlock = ^(Reachability*reach) {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadData];
        });
    };
    
    internetReachable.unreachableBlock = ^(Reachability*reach) {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showNoInternetConnectionAlert];
        });
    };
    
    [internetReachable startNotifier];
}

#pragma mark - Alert

- (void)showNoInternetConnectionAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Internet Connection"
                                                                   message:@"Please, turn on internet"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cacelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                          style:UIAlertActionStyleCancel
                                                        handler:^(UIAlertAction *  action) {
                                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                                        }];
    [alert addAction:cacelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loadData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [defaults valueForKey:@"download"];
    if ([value isEqualToString:@"no"]) {
        NSString *result = [[NSString alloc] initWithData:_scheduleData encoding:NSASCIIStringEncoding];//NSUTF8StringEncoding];
        NSLog(@"RESULT abc %@",result);

        [self.tableView reloadData];
    }
    else {
        [self loadShedule];
        
//        NSString *result = [[NSString alloc] initWithData:_scheduleData encoding:NSASCIIStringEncoding];//NSUTF8StringEncoding];
//        NSLog(@"RESULT %@",result);

        
        [self.tableView reloadData];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict  {
    
    //встретили эелемент
    
    self.currentElement = elementName;
    if ([elementName isEqualToString:@"scheduleModel"]) {
        
        _elementsCount = [NSMutableArray array];
    }

    if([elementName isEqualToString:@"schedule"])//если нашли элемент schedule, то создаем строки
    {
        self.currentSubject = [NSMutableString string];
        self.currentLessonTime = [NSMutableString string];
        self.currentWeekNumber = [NSMutableString string];
        self.currentSubjectType = [NSMutableString string];
        self.currentStudentGroup = [NSMutableString string];
        self.currentNumSubgroup = [NSMutableString string];
    }
//    if([elementName isEqualToString:@"subject"])
//    {
//        self.currentSubject = [NSMutableString string];
//    }
//
//    if([elementName isEqualToString:@"lessonTime"])
//    {
//        self.currentLessonTime = [NSMutableString string];
//    }
//    
//    if([elementName isEqualToString:@"weekNumber"])
//    {
//        self.currentWeekNumber = [NSMutableString string];
//    }
//    
//    if([elementName isEqualToString:@"lessonType"])
//    {
//        self.currentSubjectType = [NSMutableString string];
//    }
//    if([elementName isEqualToString:@"numSubgroup"])
//    {
//        self.currentNumSubgroup = [NSMutableString string];
//    }
//    
//    if([elementName isEqualToString:@"studentGroup"])
//    {
//        self.currentStudentGroup = [NSMutableString string];
//    }
    if([elementName isEqualToString:@"auditory"])
    {
        self.currentCabinet = [NSMutableString string];
    }
    if([elementName isEqualToString:@"zaoch"])
    {
        self.currentGroupType = [NSMutableString string];
    }
    if([elementName isEqualToString:@"weekDay"])
    {
        self.currentWeekDay = [NSMutableString string];
    }

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    //вызывается в момент получения данных, которые находятся в каждом элементе
    //получаем значение элемента ххх
    
    if ([_currentElement isEqualToString:@"subject"]) {
        [_currentSubject appendString:string];
        
    } else if ([_currentElement isEqualToString:@"lessonTime"]) {
        [_currentLessonTime appendString:string];
    }
    
    else if([_currentElement isEqualToString:@"numSubgroup"]) {
        [_currentNumSubgroup appendString:string];
        NSLog(@"currentnumsubgroup == %@",_currentNumSubgroup);
    }
    else if ([_currentElement isEqualToString:@"weekDay"]) {
        
        [_currentWeekDay appendString:string];
    }
    else if([_currentElement isEqualToString:@"weekNumber"]){
        [_currentWeekNumber appendString:string];
        [_currentWeekNumber appendString:@","];
        NSLog(@"current weekNumber:%@",_currentWeekNumber);
    }
    else if([_currentElement isEqualToString:@"studentGroup"]){
        [_currentStudentGroup appendString:string];
        //            NSLog(@"current weekNumber:%@",_currentWeekNumber);
    }
    else if([_currentElement isEqualToString:@"auditory"]){
        [_currentCabinet appendString:string];
        //            NSLog(@"current weekNumber:%@",_currentWeekNumber);
    }
    else if([_currentElement isEqualToString:@"zaoch"]){
        [_currentGroupType appendString:string];
        //            NSLog(@"current weekNumber:%@",_currentWeekNumber);
    }
    else if([_currentElement isEqualToString:@"lessonType"]){
        [_currentSubjectType appendString:string];
        //            NSLog(@"current weekNumber:%@",_currentWeekNumber);
    }
    
}


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    //данные с этого элемента прочитаны
    //элемент закончился
    
    
    
    //закрываем предмет
    if ([elementName isEqualToString:@"schedule"]) {
        
        NSString *currentSubject = [NSString stringWithString:self.currentSubject];
        NSString *currentLessonTime = [NSString stringWithString:self.currentLessonTime];
        NSString *currentCabinet = [NSString stringWithString:self.currentCabinet];
        NSString *currentWeekNumber = [NSString stringWithString:self.currentWeekNumber];
        NSString *currentGroupType = [NSString stringWithString:self.currentGroupType];
        NSString *currentStudentGroup = [NSString stringWithString:self.currentStudentGroup];
        NSString *currentNumSubgroup = [NSString stringWithString:self.currentNumSubgroup];
        NSString *currentSubjectType = [NSString stringWithString:self.currentSubjectType];
        
        /*NSDictionary *scheduleItem = [NSDictionary dictionaryWithObjectsAndKeys:
         self.currentSubject, @"subject",
         self.currentLessonTime, @"lessonTime",
         self.currentCabinet,@"auditory",
         self.currentWeekNumber,@"weekNumber",
         self.currentGroupType,"@zaoch",
         self.currentStudentGroup,"@studentGroup",
         self.currentNumSubgroup,@"numSubgroup",
         self.currentSubjectType,@"lessonType", nil];*/
        /*NSMutableDictionary *scheduleItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                      currentSubject, @"subject",
                                      currentLessonTime, @"lessonTime",
                                      currentCabinet,@"auditory",
                                      currentWeekNumber,@"weekNumber",
                                      currentGroupType,"@zaoch",
                                      currentStudentGroup,"@studentGroup",
                                      currentNumSubgroup,@"numSubgroup",
                                      currentSubjectType,@"lessonType", nil];*/
        
        ScheduleDetailModel *model = [[ScheduleDetailModel alloc]init];
        model.currentSubject = currentSubject;
        model.currentLessonTime = currentLessonTime;
        model.currentCabinet = currentCabinet;
        model.currentWeekNumber = currentWeekNumber;
        model.currentGroupType = currentGroupType;
        model.currentStudentGroup = currentStudentGroup;
        model.currentNumSubgroup = currentNumSubgroup;
        model.currentSubjectType = currentSubjectType;
        
        
        [_elementsCount addObject:model];
        
        NSLog(@"_elementsCount  %lu",(unsigned long)[self.elementsCount count]);
        
        self.currentSubject = nil;
        self.currentNumSubgroup =nil;
        self.currentLessonTime = nil;
        self.currentElement = nil;
        self.currentWeekNumber =nil;
        self.currentCabinet = nil;
        self.currentSubjectType = nil;
        self.currentGroupType = nil;
        self.currentStudentGroup = nil;
    }
    
    //NULL HERE
    //NSLog(@"MY ARRAY %@",_elementsCount);
    
    //закрываем день недели
    if ([elementName isEqualToString:@"weekDay"]) {
        ScheduleDetailModel *model = [[ScheduleDetailModel alloc]init];
        model.currentWeekDay = _currentWeekDay;
        NSLog(@"current week day %@",_currentWeekDay);
        [_elementsCount addObject:model];
        self.currentWeekDay = nil;
        self.currentElement = nil;
        NSLog(@"%@",_elementsCount);
    }
    
    //заносим массив в массив дней
    if([elementName isEqualToString:@"scheduleModel"])
    {
        //NSLog(@"elements_count %@",_elementsCount);
        [_dayCount addObject:_elementsCount];
        _elementsCount = nil;
        NSLog(@"количество дней: %lu",[_dayCount count]);
    }
//    if([elementName isEqualToString:@"studentGroup"])
//    {
//        _currentGroup = _currentStudentGroup;
//        self.navigationItem.hidesBackButton = YES;
//        NSMutableString* group = _currentGroup;
//        if([_currentWeek intValue] %4 == 0)
//        {
//            [group appendString:@"                                            4"];
//            NSLog(@"12341234 %@",group);
//            //nsl
//        }
//        if([_currentWeek intValue] %4 == 1)
//        {
//            [group appendString:@"                                            1"];
//            NSLog(@"12341234 %@",group);
//            //nsl
//        }
//        if([_currentWeek intValue] %4 == 2)
//        {
//            [group appendString:@"                                            2"];
//            NSLog(@"12341234 %@",group);
//            //nsl
//        }
//        if([_currentWeek intValue] %4 == 3)
//        {
//            [group appendString:@"                                            3"];
//            NSLog(@"12341234 %@",group);
//            //nsl
//        }
//        
//        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 360, 60)];
//        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 360, 40)];
//        headerLabel.text = group;
//        headerLabel.textColor = [UIColor blackColor];
//        headerLabel.font = [UIFont systemFontOfSize:22];
//        headerLabel.backgroundColor = [UIColor clearColor];
//        [containerView addSubview:headerLabel];
//        self.tableView.tableHeaderView = containerView;
//    }
    
}




#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    //NSLog(@"количество дней абабаб: %i",[_dayCount count]);
    //NSLog(@"dayCount = %lu",(unsigned long)[_dayCount count]);
    NSLog(@"количество секций в таблице : %lu",(unsigned long)[_dayCount count]);
    return [_dayCount count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return [[_dayCount objectAtIndex:0] count] - 1;
    else if(section == 1)
        return [[_dayCount objectAtIndex:1] count] - 1;
    else if(section == 2)
        return [[_dayCount objectAtIndex:2] count] - 1;
    else if(section == 3)
        return [[_dayCount objectAtIndex:3] count] - 1;
    else if(section == 4)
        return [[_dayCount objectAtIndex:4] count] - 1;
    else if(section == 5)
        return [[_dayCount objectAtIndex:5] count] - 1;
    
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    
    //поиск ячейки
    CellTableViewCell *cell = (CellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        //если ячейка не найдена - создаем новую
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CellTableViewCell"owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    
    
    NSLog(@"curreny day count %lu",[_dayCount count]);
    
    //NSDictionary *scheduleItem = [[_dayCount objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    //ScheduleDetailModel *model = [[ScheduleDetailModel alloc]init];
    ScheduleDetailModel *model = [[_dayCount objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
    
    NSString* start = [@"" stringByPaddingToLength:5 withString:model.currentLessonTime startingAtIndex:0];
    NSString* end = [@"" stringByPaddingToLength:5 withString:model.currentLessonTime startingAtIndex:6];
    NSString* weekNumber = model.currentWeekNumber;
    NSLog(@"weekNumber112211 = %@",weekNumber);
    NSRange range = [weekNumber rangeOfString:@"0"];
    if(range.length == 1)
    {
        weekNumber = @"";
        //        NSLog(@"week:%@",weekNumber);
    }
    else if(weekNumber != nil)
    {
        weekNumber = [@"" stringByPaddingToLength:([weekNumber length] -1) withString:weekNumber startingAtIndex:0];
    }
    
//    NSLog(@"length %lu",(unsigned long)[model.currentStudentGroup length]);
//    if ([studentGroup length] > 6)
//    {
////        NSLog(@"length %lu",(unsigned long)[studentGroup length]);
//        [studentGroup deleteCharactersInRange:NSMakeRange(6, 30)];
//        [studentGroup appendString:@"X"];
//    }
    NSMutableString* studentGroup;
    if ([model.currentStudentGroup length] > 6)
    {
        studentGroup = [[NSMutableString alloc]initWithString: [model.currentStudentGroup substringToIndex:5]];
        [studentGroup appendString:@"X"];
    }
    else
    {
        studentGroup = [[NSMutableString alloc]initWithString:model.currentStudentGroup];
    }
    NSLog(@"subgroup ===== %@",model.currentNumSubgroup);
    NSString* numSubgroup = model.currentNumSubgroup;
    NSRange subgroupRange = [numSubgroup rangeOfString:@"0"];
    if(subgroupRange.length == 1)
    {
        numSubgroup = @"";
    }
    
    
    cell.subject.text = model.currentSubject;
    cell.timeStart.text = start;
    cell.timeEnd.text = end;
    cell.timeSlash.text = @"-";
    cell.cabinet.text = model.currentCabinet;
    cell.weekNumber.text = weekNumber;
    cell.group.text = studentGroup;
    cell.numSubgroup.text = numSubgroup;
    
    if([model.currentSubjectType isEqualToString:@"ЛК"])
    {
        cell.type.backgroundColor = [UIColor greenColor];
    }
    if([model.currentSubjectType isEqualToString:@"ЛР"])
    {
        cell.type.backgroundColor = [UIColor redColor];
    }
    if([model.currentSubjectType isEqualToString:@"ПЗ"])
    {
        cell.type.backgroundColor = [UIColor yellowColor];
    }
    if(model.currentSubjectType == nil)
    {
        cell.type.backgroundColor = [UIColor lightGrayColor];
    }
    
    return cell;
    model = nil;
}

- (void)loadShedule {
    NSMutableString* string = [NSMutableString stringWithString:_currentTeacherLink];
    
    NSString *filePathDocData = [DOCUMENTS stringByAppendingPathComponent:@"schedule.plist"];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filePathDocData error:&error];
    if (error) {
        NSLog(@"ERRROR : %@",[error localizedDescription]);
    }
    
    //чтение файлов из документа
    _scheduleData = [NSMutableData dataWithContentsOfFile:filePathDocData];
    //_scheduleData=nil;
    if(_scheduleData == nil){
        NSLog(@"scheduledata empty");
        NSString *filePathBundleData = [[NSBundle mainBundle] pathForResource:@"schedule" ofType:@"plist"];
        [[NSFileManager defaultManager] copyItemAtPath:filePathBundleData
                                                toPath:filePathDocData
                                                 error:nil];
        
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
        NSURL* url = [NSURL URLWithString:string];
        NSURLRequest* theRequest = [NSURLRequest requestWithURL:url
                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:60.0];
        NSURLConnection* theConnection = [[NSURLConnection alloc]initWithRequest:theRequest
                                                                        delegate:self];
        if(theConnection)
        {
            self.scheduleData = [NSMutableData data];
            NSLog(@"aNJKDSNJCSNCKXJNSCJNDKLJNXJSND");
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];


        }
        else
        {
            NSLog(@"Connection FAILED!");
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        }
        
    }
    else
    {
        
        NSString *result = [[NSString alloc] initWithData:_scheduleData encoding:NSASCIIStringEncoding];//NSUTF8StringEncoding];
        NSLog(@"RESULTTTTTT %@",result);
        self.dayCount = [NSMutableArray array];
        NSXMLParser *scheduleParser = [[NSXMLParser alloc] initWithData:_scheduleData];
        scheduleParser.delegate = self;
        [scheduleParser parse];
        
    }
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    //NSDictionary *scheduleItem = [[_dayCount objectAtIndex:section]objectAtIndex:[[_dayCount objectAtIndex:section] count] - 1];
    ScheduleDetailModel *model = [[_dayCount objectAtIndex:section]objectAtIndex:[[_dayCount objectAtIndex:section]count]-1 ];
    return model.currentWeekDay;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_scheduleData appendData:data];
    
    //заносим данные в файл
    NSString *filePathDocData = [DOCUMENTS stringByAppendingPathComponent:@"schedule.plist"];
    
    [_scheduleData writeToFile:filePathDocData atomically:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    //чтение файлов из документов
    NSString *filePathDocData = [DOCUMENTS stringByAppendingPathComponent:@"schedule.plist"];
    _scheduleData = [NSMutableData dataWithContentsOfFile:filePathDocData];
    NSString *result = [[NSString alloc] initWithData:_scheduleData encoding:NSUTF8StringEncoding];
    NSLog(@" FROM FILE %@",result);
    
    //self.dayCount = [NSMutableArray array];
    NSXMLParser *scheduleParser = [[NSXMLParser alloc] initWithData:_scheduleData];
    scheduleParser.delegate = self;
    [scheduleParser parse];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableView reloadData];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"%@", parseError);
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"ERROR %@", error);
}



@end