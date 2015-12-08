//
//  ViewController.m
//  TeacherSchedule
//
//  Created by Andrey Savich on 11/23/15.
//  Copyright © 2015 Volkov Mikhail. All rights reserved.
//

#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

#import "ViewController.h"
#import "DataManager.h"
//модели
#import "TeacherCoreData.h"
#import "Teacher.h"
//контороллер для детального просмотра препода
#import "ScheduleDetailViewController.h"

//либа для проверки включенного интернета
#import "Reachability.h"

@interface ViewController () <UISearchDisplayDelegate, NSXMLParserDelegate>

@property (strong, nonatomic) NSMutableArray *teachers;//tableView DataSource

@property (strong, nonatomic) NSMutableArray *filteredTeachers;//search dataSource

@property(nonatomic,strong) NSMutableString* currentFirstName;
@property(nonatomic,strong) NSMutableString* currentLastName;
@property (strong, nonatomic) NSMutableString *currentTeacherID;
@property(nonatomic,strong) NSMutableArray* currentDayArray;
@property(nonatomic,strong) NSMutableArray* myArray;
@property(nonatomic,strong) NSString* currentElement;

//PARSING
@property(nonatomic,strong) NSMutableData* scheduleData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Schedule";
    
    self.teachers = [NSMutableArray array];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    //[self setupPullToRefresh];
    [self testInternetConnection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Internet Connection

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

#pragma mark - pull to refresh

- (void)setupPullToRefresh {
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.backgroundColor = [UIColor lightGrayColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(loadData)
                  forControlEvents:UIControlEventValueChanged];
    
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@",
                           [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title
                                                                              attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
}

#pragma mark - Content Filtering

- (void)loadData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value = [defaults valueForKey:@"download"];
    if ([value isEqualToString:@"yes"]) {
        NSArray *teacherList = [[DataManager sharedInstance]getAllTeachers];
        [self.teachers removeAllObjects];
        self.teachers = [NSMutableArray arrayWithArray:teacherList];
        self.filteredTeachers = [NSMutableArray arrayWithCapacity:[self.teachers count]];
        
        [self.tableView reloadData];
    }
    else {
        [self loadShedule];
        
        NSArray *teacherList = [[DataManager sharedInstance]getAllTeachers];
        [self.teachers removeAllObjects];
        self.teachers = [NSMutableArray arrayWithArray:teacherList];
        self.filteredTeachers = [NSMutableArray arrayWithCapacity:[self.teachers count]];
        
        [self.tableView reloadData];
    }
    
}

- (void)filteredContentForSearchText:(NSString *)searchText {
    [self.filteredTeachers removeAllObjects];
    NSArray *searchResult = [[DataManager sharedInstance]findTeacherByName:searchText];
    self.filteredTeachers = [NSMutableArray arrayWithArray:searchResult];
}

#pragma mark - UISearchDisplayDelegate

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
                            shouldReloadTableForSearchString:(NSString *)searchString {
    [self filteredContentForSearchText:searchString];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
                        shouldReloadTableForSearchScope:(NSInteger)searchOption {
    return YES;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSLog(@"1111111COUNT %lu",(unsigned long)[self.filteredTeachers count]);
        return [self.filteredTeachers count];
    }
    else {
        NSLog(@"1111111COUNT %lu",(unsigned long)[self.teachers count]);
        return [self.teachers count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];

    TeacherCoreData *teacher = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        teacher = self.filteredTeachers[indexPath.row];
    }
    else {
        teacher = self.teachers[indexPath.row];
    }
    
    cell.textLabel.text = teacher.teacherFirstName;
    cell.detailTextLabel.text = teacher.teacherLastName;
    
    NSLog(@"TEACHER ID: %@",teacher.teacherID);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TeacherCoreData *teacher = self.teachers[indexPath.row];
    
    ScheduleDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"detail"];
    vc.teacher = teacher;
    [self.navigationController pushViewController:vc animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

#pragma mark - Request

- (void)loadShedule {
    NSMutableString* string = [NSMutableString stringWithString:@"http://www.bsuir.by/schedule/rest/employee"];
    
    NSString *filePathDocData = [DOCUMENTS stringByAppendingPathComponent:@"data.plist"];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:filePathDocData error:&error];
    if (error) {
        NSLog(@"ERRROR : %@",[error localizedDescription]);
    }
    
    //чтение файлов из документа
    _scheduleData = [NSMutableData dataWithContentsOfFile:filePathDocData];
    //_scheduleData=nil;
    if(_scheduleData == nil){
        NSString *filePathBundleData = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"];
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
    
    
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:filePathDocData];
    NSLog(@"FROM PLIST : %@",array);
}

#pragma mark - NSXMLParserDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_scheduleData appendData:data];
    
    //заносим данные в файл
    NSString *filePathDocData = [DOCUMENTS stringByAppendingPathComponent:@"data.plist"];
    
    [_scheduleData writeToFile:filePathDocData atomically:YES];
    //_scheduleData=nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    //чтение файлов из документов
    NSString *filePathDocData = [DOCUMENTS stringByAppendingPathComponent:@"data.plist"];
    _scheduleData = [NSMutableData dataWithContentsOfFile:filePathDocData];
    NSString *result = [[NSString alloc] initWithData:_scheduleData encoding:NSUTF8StringEncoding];
    NSLog(@" FROM FILE %@",result);
    
    self.currentDayArray = [NSMutableArray array];
    NSXMLParser *scheduleParser = [[NSXMLParser alloc] initWithData:_scheduleData];
    scheduleParser.delegate = self;
    [scheduleParser parse];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"ERROR %@", error);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
                                        namespaceURI:(NSString *)namespaceURI
                                        qualifiedName:(NSString *)qualifiedName
                                        attributes:(NSDictionary *)attributeDict  {
    
    //встретили эелемент
    
    self.currentElement = elementName;
    if ([elementName isEqualToString:@"employee"]) {
        
        _myArray = [NSMutableArray array];
    }
    if([elementName isEqualToString:@"firstName"])
    {
        self.currentFirstName = [NSMutableString string];
    }
    if ([elementName isEqualToString:@"lastName"]) {
        self.currentLastName = [NSMutableString string];
    }
    if ([elementName isEqualToString:@"id"]) {
        self.currentTeacherID = [NSMutableString string];
    
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    //вызывается в момент получения данных, которые находятся в каждом элементе
    //получаем значение элемента ххх
    
    if ([_currentElement isEqualToString:@"firstName"]) {
        [_currentFirstName appendString:string];
        
    }
    else if ([_currentElement isEqualToString:@"lastName"]) {
        [_currentLastName appendString:string];
    }
    else if ([_currentElement isEqualToString:@"id"]) {
        [_currentTeacherID appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
                                        namespaceURI:(NSString *)namespaceURI
                                            qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"employee"]) {
        Teacher *teacher = [[Teacher alloc]init];
        teacher.firstName = self.currentFirstName;
        teacher.lastName = self.currentLastName;
        teacher.teacherID = self.currentTeacherID;
        NSLog(@"§§§§§§§§§§§§§§§§§§§§§§§§§§TEACHER LAST NAME : %@",teacher.lastName);
        [self.teachers addObject:teacher];
        
        self.currentTeacherID = nil;
        self.currentLastName = nil;
        self.currentFirstName = nil;
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [[DataManager sharedInstance]scheduleLoad];
    [[DataManager sharedInstance]saveTeacherListFromArray:self.teachers];
    
    [self.refreshControl endRefreshing];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"%@", parseError);
}

@end