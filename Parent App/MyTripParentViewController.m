//
//  MyTripParentViewController.m
//  Safetrax
//
//  Created by Kumaran on 10/12/15.
//  Copyright © 2015 Mtap. All rights reserved.
//

#import "MyTripParentViewController.h"
#import "MFSideMenu.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import <MapKit/MapKit.h>
#import "TripCollection.h"
#import "TripModel.h"
#import "GCMRequest.h"
#import "RestClientTask.h"
#import "MyTripHelpViewController.h"
#import <Smooch/Smooch.h>
#import "validateLogin.h"
BOOL refreshInProgressParent = FALSE;
BOOL no_tripsParent = FALSE;
int TripRequestCounter =0;
NSMutableArray *tripListParent;
NSMutableArray *ScheduleTimeArraySction1;
NSMutableArray *ScheduleTimeArraySction2;
NSMutableArray *TripEndtimeArraySection1;
NSMutableArray *TripEndtimeArraySection2;
TripCollection *tripcollection ;
int ActiveTrip = 0;
int CurrentDateType = 1;

@interface MyTripParentViewController ()

@end

@implementation MyTripParentViewController
@synthesize tripTable,TripsHelpButton;
- (void)viewDidLoad {
    [TripCollection initArray];
    CurrentDateType = 1;
    ActiveTrip = 0;
    no_tripsParent = FALSE;
    CompletedTrip = [[NSUserDefaults standardUserDefaults] objectForKey:@"LastTrip"];
    TripRequestCounter = 0;
    tripsSection1 =[[NSMutableArray alloc]init];
    tripsSection2 =[[NSMutableArray alloc]init];
     tripsSection3 =[[NSMutableArray alloc]init];
    [SKTUser currentUser].firstName = [[NSUserDefaults standardUserDefaults] stringForKey:@"name"];
    [SKTUser currentUser].email = [[NSUserDefaults standardUserDefaults] stringForKey:@"email"];
    self.view.frame = [[UIScreen mainScreen] bounds];
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.backgroundColor = [UIColor clearColor];
    refreshControl.tintColor = [UIColor colorWithRed:0.0/255.0 green:159.0/255.0 blue:134.0/255.0 alpha:1];
    [refreshControl addTarget:self
                       action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    [self.tripTable addSubview:refreshControl];
    self.tripTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tripTable.delegate = self;
    self.tripTable.dataSource =self;
    [super viewDidLoad];
    validateLogin *validate = [[validateLogin alloc] init];
    [validate setDelegate:self];
    self.menuContainerViewController.panMode = MFSideMenuPanModeNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuStateEventOccurred:)
                                                 name:MFSideMenuStateNotificationEvent
                                               object:nil];
    // Do any additional setup after loading the view from its nib.
   

}
-(void)didFinishvalidation
{
    ChildrenIDs =[[NSMutableArray alloc] init];
    NSArray *extras =  [[NSUserDefaults standardUserDefaults] arrayForKey:@"extras"];
    NSLog(@"extras %@",extras);
    [ChildrenIDs addObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"empid"]];
    for(NSDictionary *dictionary in extras)
    {
        [ChildrenIDs addObject:[dictionary objectForKey:@"empid"]];
    }
    NSLog(@"childre count %d",[ChildrenIDs count]);
    [self TripsRequest:1];

}
-(void)viewWillAppear:(BOOL)animated{
  
   
}
-(void)TripsRequest:(int)isCurrentDate
{
    _responseData = nil;
    NSString *schedule_date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    NSDate *yesterday;
    NSDate *currDate;
    currDate = [NSDate date];
    if(isCurrentDate)
    {
       
        schedule_date = [dateFormatter stringFromDate:currDate];
    }
    else
    {
        yesterday = [currDate dateByAddingTimeInterval: -86400.0];
        schedule_date = [dateFormatter stringFromDate:yesterday];
    }
    _responseData = [[NSMutableData alloc] init];
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *passwords = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    NSString *userid=[ChildrenIDs objectAtIndex:TripRequestCounter];
      NSLog(@"userids %@",userid);
    NSDictionary *newDatasetInfo = [NSDictionary dictionaryWithObjectsAndKeys:userName, @"username", passwords, @"password",userid,@"userid",schedule_date,@"schedule_date", nil];
    NSLog(@"dictionary %@",newDatasetInfo);
    MongoRequest *requestWraper =[[MongoRequest alloc]initWithTrips];
    [requestWraper setPostParams:newDatasetInfo];
    [requestWraper print];
    RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
    [RestClient setDelegate:self];
    [RestClient execute];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Menu Event
- (void)menuStateEventOccurred:(NSNotification *)notification {
    MFSideMenuStateEvent event = [[notification userInfo][@"eventType"] intValue];
    if(event == MFSideMenuStateEventMenuDidClose){
        blurView.dynamic = YES;
        [self dismiss];
    }
}
-(IBAction)openMenu:(id)sender
{
    if(self.menuContainerViewController.menuState == MFSideMenuStateLeftMenuOpen)
    {
        [self dismiss];
    }
    else
    {
        [self showOnVC];
    }
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{}];
    blurView.dynamic = NO;
}

- (void)showOnVC {
    blurView = [[FXBlurView alloc] initWithFrame:self.view.bounds];
    CGRect frameRect = blurView.frame;
    frameRect.origin.y = 60;
    blurView.frame = frameRect;
    blurView.underlyingView = self.view;
    blurView.tintColor = [UIColor clearColor];
    blurView.updateInterval = 1;
    blurView.blurRadius = 30.f;
    blurView.alpha = 0.f;
    [self.view addSubview:blurView];
    [UIView animateWithDuration:0.3 animations:^{
        blurView.alpha = 1.f;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha = 1.0f;
        }];
    }];
}
- (void)dismiss {
    [UIView animateWithDuration:0.3
                     animations:^{
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3 animations:^{
                             blurView.alpha = 0.f;
                         } completion:^(BOOL finished) {
                             [blurView removeFromSuperview];
                         }];
                     }];
}

#pragma mark Clear Screen
-(void)cleanInfoView {
    for (UIView *view in self.view.subviews) {
        if(!([view isKindOfClass:[UINavigationBar class]]||[view isKindOfClass:[MKMapView class]]||[view isKindOfClass:[FXBlurView class]])){
            [view removeFromSuperview];
        }
    }
}
-(void)refresh
{
    NSLog(@"refresh");
    if(!refreshInProgressParent){
        ActiveTrip = 0;
        CurrentDateType = 1;
        [TripCollection initArray];
        TripRequestCounter = 0;
        tripsSection1 = nil;
        tripsSection2 =nil;
        tripsSection3 =nil;
        tripsSection1 =[[NSMutableArray alloc]init];
        tripsSection3 =[[NSMutableArray alloc]init];
        tripsSection2 =[[NSMutableArray alloc]init];
        refreshInProgressParent = TRUE;
        [self TripsRequest:CurrentDateType];
        
    }
   [refreshControl endRefreshing];
}
#pragma mark RESTCallBack Delegate Methods
-(void)onResponseReceived:(NSData *)data
{
    [_responseData appendData:data];
    NSError *error;
    NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSLog(@"%@",dataDictionary);
}
-(void)onFailure
{
    refreshInProgressParent = FALSE;
    
    NSLog(@"Failure callback");
}
-(void)onConnectionFailure
{
    refreshInProgressParent = FALSE;
    NSLog(@"Connection Failure callback");
}
-(void)onFinishLoading
{
    NSLog(@"finish load");
    NSString* newStr = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
   NSLog(@"trip %@",newStr);
    int isError = 0;
    id obj = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
    if([obj isKindOfClass:[NSDictionary class]]){
        if([obj objectForKey:@"error"]){
            NSLog(@"error at finding trips");
            no_tripsParent = TRUE;
            isError = 1;
            //[self.tripTable reloadData];
            //if(CompletedTrip != nil)
              //  tripcollection  = [TripCollection buildFromdata:CompletedTrip];
        }
    }
    else
    {
        
        [self addTrip];
    }
    TripRequestCounter++;
    if(TripRequestCounter < [ChildrenIDs count])
    {
       no_tripsParent = FALSE;
        [self TripsRequest:CurrentDateType];
    }
    else
    {
    [self displayTrips];
    NSLog(@"display");
       
    }
    refreshInProgressParent = FALSE;
}
-(void)addTrip
{
   NSLog(@"add trip");
   tripcollection  = [TripCollection buildFromdata:_responseData];
   //if(CompletedTrip != nil)
     //tripcollection  = [TripCollection buildFromdata:CompletedTrip];
}
-(void)displayTrips
{
    static int setOldTrips = 0;
    tripDrop =[tripcollection getDrop];
    tripPickup =[tripcollection getPickup];
    [tripcollection sortTrip];
    tripListParent =[[tripcollection getTripList] mutableCopy];
    NSLog(@"triplist %@",tripListParent);
    NSMutableArray * values = [[NSMutableArray alloc]initWithArray:[tripPickup allKeys]];
    [values addObjectsFromArray:[tripDrop allKeys]];
    unique = [NSMutableArray array];
    for (id obj in values) {
        if (![unique containsObject:obj]) {
            [unique addObject:obj];
        }
    }
    unique = [unique sortedArrayUsingSelector: @selector(compare:)];
    NSLog(@"unique value %@",unique);
    NSString *pickupValue;
    NSString *dropValue ;
    NSString *key;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *dateFromString = [[NSDate alloc] init];
    NSDate *lastDate = [[NSDate alloc] init];
    NSString *lastDateString = [unique lastObject];;
    lastDate = [dateFormatter dateFromString:lastDateString];
    NSLog(@"unique obj %@",unique);
    if([unique count] >1){
        BOOL shouldRemoveOldTrips =   [self getTripValidated:[dateFormatter stringFromDate:lastDate]];
        if(shouldRemoveOldTrips)
        {
            unique = [NSMutableArray arrayWithArray:unique];
            [unique removeObjectsInRange:NSMakeRange(0, unique.count-1)];
            [tripListParent removeObjectsInRange:NSMakeRange(0, tripListParent.count-1)];
            NSLog(@"should remove");
        }
    }
    if([unique count] >0){
        key =[unique objectAtIndex:0];
        NSString *tripTime = key;
        dateFromString = [dateFormatter dateFromString:tripTime];
        pickupValue =[tripPickup objectForKey:key];
        dropValue =[tripDrop objectForKey:key];
        if(pickupValue)
            [tripsSection1 addObject:pickupValue];
        if(dropValue)
            [tripsSection1 addObject:dropValue];
    }
    NSLog(@"Tripsection 1 %@\n %@",tripsSection1,tripsSection2);
    if([unique count] >1){
        key =[unique objectAtIndex:1];
        NSString *tripTime = key;
        dateFromString = [dateFormatter dateFromString:tripTime];
        NSString *date = [key substringWithRange:NSMakeRange(0, 10)];
        pickupValue =[tripPickup objectForKey:key];
        dropValue =[tripDrop objectForKey:key];
        if([date isEqualToString:[[unique objectAtIndex:0] substringWithRange:NSMakeRange(0, 10)]])
        {
            if(pickupValue)
                [tripsSection1 addObject:pickupValue];
            if(dropValue)
                [tripsSection1 addObject:dropValue];
        }
        else
        {
            if(pickupValue)
                [tripsSection2 addObject:pickupValue];
            if(dropValue)
                [tripsSection2 addObject:dropValue];
        }
    }
    if([unique count] >2){
        key =[unique objectAtIndex:2];
        NSString *tripTime = key;
        dateFromString = [dateFormatter dateFromString:tripTime];
        NSString *date = [key substringWithRange:NSMakeRange(0, 10)];
        pickupValue =[tripPickup objectForKey:key];
        dropValue =[tripDrop objectForKey:key];
        if([date isEqualToString:[[unique objectAtIndex:1] substringWithRange:NSMakeRange(0, 10)]])
        {
            if(pickupValue)
                [tripsSection2 addObject:pickupValue];
            if(dropValue)
                [tripsSection2 addObject:dropValue];
        }
        else
        {
            if(pickupValue)
                [tripsSection3 addObject:pickupValue];
            if(dropValue)
                [tripsSection3 addObject:dropValue];
        }
    }

    NSLog(@"Tripsection 2 %@\n %@",tripsSection1,tripsSection2);
    [[NSUserDefaults standardUserDefaults] synchronize];
   //
    if([unique count] > 0){
        NSString *tripTime =[unique objectAtIndex:0];
        [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        dateFromString = [dateFormatter dateFromString:tripTime];
        [self dateDifference:[dateFormatter stringFromDate:dateFromString]];
    }
    NSLog(@"active trips %d -- %d",ActiveTrip,setOldTrips);
    if([unique count]>1)
    {
        //[self setOldTripObject];
        NSLog(@"call old tripobject");
        setOldTrips = 1;
    }
   [self.tripTable reloadData];
}
-(void)setOldTripObject
{
    id obj = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
    if([obj isKindOfClass:[NSDictionary class]]){
        if([obj objectForKey:@"error"]){
            NSLog(@"error at finding trips; Don't add");
        }
    }
    else
    {
        NSLog(@"added trip");
        [[NSUserDefaults standardUserDefaults] setObject:_responseData forKey:@"LastTrip"];
        
    }

    
}
-(IBAction)MyTripHelp:(id)sender
{
    MyTripHelpViewController *MyTripHelp = [[MyTripHelpViewController alloc] initWithNibName:@"MyTripHelpViewController" bundle:nil];
    [self presentViewController:MyTripHelp animated:YES completion:nil];
    
}
-(BOOL)getTripValidated:(NSString *)scheduleDate
{
    NSLog(@"last date-->%@",scheduleDate);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY/MM/dd--HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *tripDate=[dateFormatter dateFromString:scheduleDate];
    NSDate *date = [[NSDate date] dateByAddingTimeInterval:30*60];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:zone];
    [formatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:[formatter stringFromDate:date]];
    NSTimeInterval secondsBetween = [tripDate timeIntervalSinceDate:dateFromString];
    NSLog(@"datefrom %@",dateFromString);
    if(secondsBetween > 0)
    {
        NSLog(@"greater");
        return NO;
    }
    else
    {
        NSLog(@"lesser");
        return YES;
        
    }
  //  [tripTable reloadData];
    
}
-(void)dateDifference:(NSString *)scheduleDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *tripDate=[dateFormatter dateFromString:scheduleDate];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:zone];
    [formatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:[formatter stringFromDate:date]];
    NSLog(@"seconds %@--%@--%@",tripDate,date,dateFromString);
    NSTimeInterval secondsBetween = [tripDate timeIntervalSinceDate:dateFromString];
    float difference = secondsBetween - 1200;
    if(difference > 0)
    {
        UILocalNotification* n1 = [[UILocalNotification alloc] init];
        n1.fireDate = [NSDate dateWithTimeIntervalSinceNow: difference];
        n1.alertBody = [NSString stringWithFormat: @"Trip At %@",scheduleDate];
        n1.soundName = @"default";
        //[[UIApplication sharedApplication] scheduleLocalNotification: n1];
    }
}

-(int)CheckActiveTrips:(NSString *)scheduleDate:(int)type
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate *tripDate=[dateFormatter dateFromString:scheduleDate];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSTimeZone *zone = [NSTimeZone localTimeZone];
    [formatter setTimeZone:zone];
    [formatter setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:[formatter stringFromDate:date]];
    NSLog(@"time %@----%@",tripDate,dateFromString);
    NSTimeInterval secondsBetween = [tripDate timeIntervalSinceDate:dateFromString];
    NSLog(@"difference %f",secondsBetween);
    if(type == 1 ){
      if((secondsBetween < 3600))
        {
          NSLog(@"difference less than 1 hour %f",secondsBetween);
          return 1;
        }
      else
          return 0;
      }
    if(type  == 2 ){
     if((secondsBetween < -3600))
       {
        return 2;
       }
      else
        return 0;
     }
    return 0;
}

#pragma mark Tableview delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"number of sections %@",tripsSection1);
     if(no_tripsParent == TRUE)
    {
        NSLog(@"no trips");
        if([self.view viewWithTag:238])
        {
            [[self.view viewWithTag:238] removeFromSuperview];
        }
        UIImageView *no_trips = [[UIImageView alloc] initWithFrame:CGRectMake(100, 200, 100, 107)];
        no_trips.image = [UIImage imageNamed:@"_0008_no-trip-illustration.png"];
        no_trips.tag = 238;
        [self.view addSubview:no_trips];
        TripsHelpButton.hidden = NO;
        if(([tripsSection1 count] == 0) && ([tripsSection2 count] == 0) && ([tripsSection3 count] == 0))
        {
            NSLog(@"triprequest");
            TripRequestCounter = 0;
            if(ActiveTrip == 0)
            {
                NSLog(@"no active trip");
                ActiveTrip = 1;
               // CurrentDateType = 0;
                [TripCollection initArray];
                tripsSection1 = nil;
                tripsSection2 =nil;
                tripsSection3=nil;
                tripsSection1 =[[NSMutableArray alloc]init];
                tripsSection2 =[[NSMutableArray alloc]init];
                tripsSection3 =[[NSMutableArray alloc]init];
                [self TripsRequest:0];
                //[self.tripTable reloadData];
            }
        }

    }
    else if(no_tripsParent == FALSE)
    {
        [[self.view viewWithTag:238] removeFromSuperview];
        TripsHelpButton.hidden = YES;

    }
    if([tripsSection3 count] >0)
    {
        NSLog(@"tripsection2 count");
        [[self.view viewWithTag:238] removeFromSuperview];
        TripsHelpButton.hidden = YES;
        return 3;
        
    }
    if([tripsSection2 count] >0)
    {
        NSLog(@"tripsection2 count");
        [[self.view viewWithTag:238] removeFromSuperview];
        TripsHelpButton.hidden = YES;
        return 2;
        
    }
    else if([tripsSection1 count] >0)
    {
         NSLog(@"tripsection1 count ");
        [[self.view viewWithTag:238] removeFromSuperview];
        TripsHelpButton.hidden = YES;
        return 1;
    }
    else
    {
        
        NSLog(@"no section");
           if([self.view viewWithTag:238])
            {
                [[self.view viewWithTag:238] removeFromSuperview];
            }
            UIImageView *no_trips = [[UIImageView alloc] initWithFrame:CGRectMake(100, 200, 100, 107)];
            no_trips.image = [UIImage imageNamed:@"_0008_no-trip-illustration.png"];
            no_trips.tag = 238;
            [self.view addSubview:no_trips];
            TripsHelpButton.hidden = NO;
            return 0;
        
        }
  
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"rows %@",tripsSection2);
    if(section == 0)
        return [tripsSection1 count];
    else if(section == 1)
        return [tripsSection2 count];
    else if(section == 2)
        return [tripsSection3 count];
    else
        return 0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *dateString;
    NSDateFormatter *dateFormatters = [[NSDateFormatter alloc] init];
    if([unique count] > 0)
      dateString = [unique objectAtIndex:section];
    [dateFormatters setDateFormat:@"yyyy/MM/dd--HH:mm:ss"];
    NSDate *dateFromString = [[NSDate alloc] init];
    dateFromString = [dateFormatters dateFromString:dateString];
    NSString * deviceLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    dateFormatters = [NSDateFormatter new];
    NSLocale * locale = [[NSLocale alloc] initWithLocaleIdentifier:deviceLanguage];
    [dateFormatters setDateFormat:@"EEEE, dd MMM, yyyy"];
    [dateFormatters setLocale:locale];
    dateString = [dateFormatters stringFromDate:dateFromString];
    return dateString;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"section 1 %@",tripsSection1);
    NSLog(@"section 2 %@",tripsSection2);
    UITableViewCell *Cell = [self.tripTable dequeueReusableCellWithIdentifier:nil];
    NSString *dateString ;
    NSString *endTime;
    if(Cell == nil)
    {
        Cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSArray *StringArray =[[NSArray alloc] init];
    if (indexPath.section==0) {
           NSLog(@"active trip value %ld-%@",(long)indexPath.row,tripsSection1);
        StringArray = [[tripsSection1 objectAtIndex:indexPath.row]  componentsSeparatedByString:@"&&"];
        Cell.textLabel.text = StringArray[0];
        dateString = StringArray[2];
        endTime = StringArray[1];
    }
    else if(indexPath.section==1)
    {
        if([tripsSection2 count] >0)
        {  NSLog(@"active trip value %ld-%@",(long)indexPath.row,tripsSection2);
        StringArray = [[tripsSection2 objectAtIndex:indexPath.row]  componentsSeparatedByString:@"&&"];
        Cell.textLabel.text = StringArray[0];
        dateString = StringArray[2];
            endTime = StringArray[1];
        }
    }
    else if(indexPath.section ==2)
    {
        if([tripsSection3 count] >0) {
        NSLog(@"active trip value %ld-%@",(long)indexPath.row,tripsSection3);
        StringArray = [[tripsSection3 objectAtIndex:indexPath.row]  componentsSeparatedByString:@"&&"];
        Cell.textLabel.text = StringArray[0];
        dateString = StringArray[2];
        endTime = StringArray[1];
        }
    }
    int i = [self CheckActiveTrips:dateString:1];
    UILabel *label = [[UILabel alloc] init];
    UIFont *myFont = [ UIFont fontWithName: @"Arial" size: 12.0 ];
    label.font = myFont;
    Cell.accessoryView = nil;
    if(i == 1)
    {
        NSLog(@"set active");
        ActiveTrip = 1;
        label.text = @"  Active";
        label.layer.borderColor = [UIColor colorWithRed:0/255.0f green:159/255.0f blue:134/255.0f alpha:1.0f].CGColor;
        label.layer.borderWidth = 3.0;
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = 8.0;
        label.backgroundColor = [UIColor colorWithRed:0/255.0f green:159/255.0f blue:134/255.0f alpha:1.0f];
        Cell.accessoryView = label;
    }
    i = [self CheckActiveTrips:endTime:2];
    if(i == 2)
    {
        //ActiveTrip = 0;
        NSLog(@"set completed");
        label.text = @"  Completed";
        label.layer.borderColor = [UIColor grayColor].CGColor;
        label.layer.borderWidth = 3.0;
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = 8.0;
        label.backgroundColor = [UIColor grayColor];
        Cell.accessoryView = label;
    }
    [Cell.accessoryView setFrame:CGRectMake(0, 0, 75, 30)];
    Cell.textLabel.numberOfLines = 0;
    return Cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rowNumber = 0;
    for (NSInteger i = 0; i < indexPath.section; i++) {
        rowNumber += [self tableView:tableView numberOfRowsInSection:i];
    }
    rowNumber += indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"reached"];
    tripSummary = [[TripSummaryParentViewController alloc] initWithNibName:@"TripSummaryParent"  bundle:Nil tripArray:tripListParent selectedIndex:(int)rowNumber withHome:self];
    tripSummary.modalPresentationStyle = UIModalPresentationFormSheet;
    tripSummary.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:tripSummary animated:YES completion:nil];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tripString;
    
    if (indexPath.section==0) {
        tripString = [[tripsSection1 objectAtIndex:indexPath.row] substringToIndex:[[tripsSection1 objectAtIndex:indexPath.row] length]-2];
    }
    else if(indexPath.section == 1)
    {
        if([tripsSection3 count] >0) {
        
        tripString = [[tripsSection2 objectAtIndex:indexPath.row] substringToIndex:[[tripsSection2 objectAtIndex:indexPath.row] length]-2];
        }
        
    }
    else if (indexPath.section == 2)
    {
        if([tripsSection3 count] >0) {
         tripString = [[tripsSection3 objectAtIndex:indexPath.row] substringToIndex:[[tripsSection3 objectAtIndex:indexPath.row] length]-2];
    }
    }
    CGRect textRect = [tripString boundingRectWithSize:CGSizeMake(300.f, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:[ UIFont fontWithName: @"Arial" size: 18.0 ]}
                                               context:nil];
    CGSize size = textRect.size;
    NSLog(@"size %f",size.height);
    
    return 130;
}
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        TripRequestCounter = 0;
        NSLog(@"active trip value %d",ActiveTrip);
        if(ActiveTrip == 0)
        {
            NSLog(@"no active trip");
            ActiveTrip = 1;
          //  CurrentDateType = 0;
            [TripCollection initArrayWithOldTrips];
            tripsSection1 = nil;
            tripsSection2 =nil;
            tripsSection3 =nil;
            tripsSection1 =[[NSMutableArray alloc]init];
            tripsSection2 =[[NSMutableArray alloc]init];
            tripsSection3 =[[NSMutableArray alloc]init];
            [self TripsRequest:0];
        }
        
    }
    
}

-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"table ended");
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    // Perform some final layout updates
    NSLog(@"table ended");
   
    if (section == ([tableView numberOfSections] - 1)) {
        [self tableViewWillFinishLoading:tableView];
    }
    
    // Return nil, or whatever view you were going to return for the footer
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    // Return 0, or the height for your footer view
    return 0.0;
}

- (void)tableViewWillFinishLoading:(UITableView *)tableView
{
    NSLog(@"triprequest will display");
      [self.tripTable reloadData];
  
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
