//
//  ScheduleDetailViewController.m
//  TeacherSchedule
//
//  Created by Andrey Savich on 11/25/15.
//  Copyright © 2015 Volkov Mikhail. All rights reserved.
//
#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

#import "ScheduleDetailViewController.h"
//либа для проверки включенного интернета
#import "Reachability.h"

@interface ScheduleDetailViewController ()

@property (strong, nonatomic) NSMutableData *scheduleData;//tableView DataSource
@property (strong,nonatomic) NSMutableString* currentTeacherLink;

@end

@implementation ScheduleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *teacherFullName = [NSString stringWithFormat:@"%@ %@",self.teacher.teacherFirstName, self.teacher.teacherLastName];
    self.title = teacherFullName;
    _currentTeacherLink = [NSMutableString stringWithString:@"http://www.bsuir.by/schedule/rest/employee/"];
    [_currentTeacherLink appendString: self.teacher.teacherID];
    [self testInternetConnection];

    
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
        
        NSString *result = [[NSString alloc] initWithData:_scheduleData encoding:NSASCIIStringEncoding];//NSUTF8StringEncoding];
        NSLog(@"RESULT %@",result);

        
        [self.tableView reloadData];
    }
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
            NSLog(@"SAVE TO");
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];


        }
        else
        {
            NSLog(@"Connection FAILED!");
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        }
        
    }
    
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
    
//    self.currentDayArray = [NSMutableArray array];
//    NSXMLParser *scheduleParser = [[NSXMLParser alloc] initWithData:_scheduleData];
//    scheduleParser.delegate = self;
//    [scheduleParser parse];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"ERROR %@", error);
}



@end