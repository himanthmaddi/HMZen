//
//  TripSummaryParentViewController.m
//  Safetrax
//
//  Created by Kumaran on 17/12/15.
//  Copyright © 2015 Mtap. All rights reserved.
//

#import "TripSummaryParentViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/QuartzCore.h>

NSMutableArray *ChildrenListParent;

@interface TripSummaryParentViewController ()

@end

@implementation TripSummaryParentViewController
@synthesize DriverName,VehicleName,startPoint,startTime,endPoint,endTime,summaryTable,boardedCab,timeTaken,phNumber,scrollview,waitingButton,boardedButton,tripLabel,reachedButton;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tripArray:(NSArray*)trips selectedIndex:(int)Index withHome:(HomeViewController*)homeobject {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        selectedIndex =Index;
        home =homeobject;
        tripArray =trips;
        model = [tripArray objectAtIndex:selectedIndex];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   self.summaryTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.summaryTable setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [super viewDidLoad];
    scrollview.contentSize =CGSizeMake(320, 1050);
    self.summaryTable.delegate = self;
    self.summaryTable.dataSource =self;
    
    DriverName.text = model.driverName;
    VehicleName.text = model.driverLicence;
    startTime.text=[model.scheduledTime substringWithRange:NSMakeRange(12, 5)];
    endTime.text=[model.tripEndTime substringWithRange:NSMakeRange(12, 5)];
    CGRect textRect = [model.pickup boundingRectWithSize:CGSizeMake(300.f, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:[ UIFont fontWithName: @"Arial" size: 18.0 ]}
                                                 context:nil];
    
    textRect.size.height =textRect.size.height+10;
    CGRect newFrame = startPoint.frame;
    newFrame.size.height = textRect.size.height;
    
    startPoint.frame = newFrame;
    [startPoint addConstraint:[NSLayoutConstraint constraintWithItem:startPoint
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute: NSLayoutAttributeNotAnAttribute
                                                          multiplier:1
                                                            constant:startPoint.frame.size.height]];
    NSLog(@"hi-->%f",startPoint.frame.size.height);
    startPoint.text=model.pickup;
    
    textRect = [model.drop boundingRectWithSize:CGSizeMake(300.f, CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[ UIFont fontWithName: @"Arial" size: 18.0 ]}
                                        context:nil];
    
    textRect.size.height =textRect.size.height+10;
    newFrame = endPoint.frame;
    newFrame.size.height = textRect.size.height;
    NSLog(@"hie-->%f",endPoint.frame.size.height);
    endPoint.frame = newFrame;
    [endPoint addConstraint:[NSLayoutConstraint constraintWithItem:endPoint
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute: NSLayoutAttributeNotAnAttribute
                                                        multiplier:1
                                                          constant:endPoint.frame.size.height]];
    endPoint.text=model.drop;
    phNumber.text =model.driverPhone;
    wayPoints =model.cabWaypoints;
    tripLabel.text = [NSString stringWithFormat:@"Scheduled %@ Trip at",model.tripType];
    if([model.tripType isEqualToString:@"Drop"])
       timeTaken.text =[model.tripEndTime substringWithRange:NSMakeRange(12, 5)];
    else
      timeTaken.text =[model.scheduledTime substringWithRange:NSMakeRange(12, 5)];

    // Do any additional setup after loading the view.
    NSDictionary* waypointdict;
    NSMutableDictionary* ScheduleDictionary;
    ScheduleDictionary = [[NSMutableDictionary alloc] init];
    NSString *EmployeeDetails;
    EmployeeTripDetails = [[NSMutableArray alloc] init];
    TableValues = [[NSMutableArray alloc] init];
    EmpStatus = [[NSMutableArray alloc] init];
    NameDictionary = [[NSMutableDictionary alloc] init];
    NSString *scheduleTime;
    NSArray *colleague;
    NSMutableArray *allEmployees = [[NSMutableArray alloc] init];
    DataDictionary = [[NSMutableDictionary alloc] init];
    NSString *Child =@"";
    NSArray *extras =  [[NSUserDefaults standardUserDefaults] arrayForKey:@"extras"];

    [NameDictionary setObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"name"] forKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"empid"]];
    for(NSDictionary *dictionary in extras)
    {
        [NameDictionary setObject:[dictionary objectForKey:@"name"] forKey: [dictionary objectForKey:@"empid"]];
        NSLog(@"%@",NameDictionary);
        
    }
    for(int i=0;i<[wayPoints count];i++)
    {
        waypointdict =[model.cabWaypoints objectAtIndex:i];
        if([model.tripType isEqualToString:@"Drop"])
            EmpStatus = waypointdict[@"employeesReached"];
        else
            EmpStatus = waypointdict[@"employeesInCab"];
       
        scheduleTime = waypointdict[@"scheduledTime"];
        colleague =waypointdict[@"employeesAssigned"];
        [allEmployees addObject:waypointdict[@"employeesAssigned"]];
        ChildrenListParent =[[NSMutableArray alloc] init];
        [ChildrenListParent addObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"empid"]];
        for(NSDictionary *dictionary in extras)
        {
            [ChildrenListParent addObject:[dictionary objectForKey:@"empid"]];
            [NameDictionary setObject:[dictionary objectForKey:@"name"] forKey:[dictionary objectForKey:@"empid"]];
        }
        NSMutableSet* set1 = [NSMutableSet setWithArray:ChildrenListParent];
        NSMutableSet* set2 = [NSMutableSet setWithArray:colleague];
        [set1 intersectSet:set2]; //this will give you only the obejcts that are in both sets
        NSArray* result = [set1 allObjects];
        NSLog(@"result %@",result);
        set1 = [NSMutableSet setWithArray:colleague];
        set2 = [NSMutableSet setWithArray:EmpStatus];
        [set1 intersectSet:set2];
        NSArray* StatusResult = [set1 allObjects];
        EmployeeDetails = [NSString stringWithFormat:@"%@\nExpected at %@",waypointdict[@"waypointName"],[scheduleTime substringWithRange:NSMakeRange(12, 5)]];
        NSString *childrenInfo = @"";
        for(NSString *empid in result)
        {
            if([StatusResult containsObject:empid])
            {
            childrenInfo =[NSString stringWithFormat:@"%@\n%@\n%@1",[NameDictionary objectForKey:empid],empid,EmployeeDetails];
            }
            else
            {
                childrenInfo =[NSString stringWithFormat:@"%@\n%@\n%@0",[NameDictionary objectForKey:empid],empid,EmployeeDetails];
            }
            [TableValues addObject:childrenInfo];
        }
        NSLog(@"Status %@",StatusResult);
    }
    if([TableValues count] ==1 )
    {
        self.tableHeightConstraint.constant = 200;
        [self.summaryTable needsUpdateConstraints];
    }
    else if([TableValues count] == 2 )
    {
        self.tableHeightConstraint.constant = 260;
        [self.summaryTable needsUpdateConstraints];
    }
    else if([TableValues count] == 3 )
    {
        self.tableHeightConstraint.constant = 320;
        [self.summaryTable needsUpdateConstraints];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [TableValues count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSString *cellLabel =[TableValues objectAtIndex:indexPath.row];
    NSLog(@"celllabel %@",cellLabel);
    cell.textLabel.text = [cellLabel substringToIndex:[cellLabel length] - 1];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cellLabel = [cellLabel substringFromIndex: [cellLabel length] - 1];
    NSLog(@"cell %@",cellLabel);
    cell.textLabel.numberOfLines =0;
    UIFont *myFont = [ UIFont fontWithName: @"Arial" size: 12.0 ];
    cell.textLabel.font  = myFont;
    UILabel *label = [[UILabel alloc] init];
    myFont = [ UIFont fontWithName: @"Arial" size: 12.0 ];
    label.font = myFont;
    if([cellLabel isEqualToString:@"1"])
    {
      label.text = @"  Confirmed";
         label.layer.borderColor = [UIColor colorWithRed:0/255.0f green:159/255.0f blue:134/255.0f alpha:1.0f].CGColor;
        label.layer.borderWidth = 3.0;
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = 8.0;
      label.backgroundColor = [UIColor colorWithRed:0/255.0f green:159/255.0f blue:134/255.0f alpha:1.0f];
    cell.accessoryView = label;
    }
    else
    {
    label.text = @"  PENDING";
        label.layer.borderColor = [UIColor grayColor].CGColor;
        label.layer.borderWidth = 3.0;
        
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = 8.0;

    label.backgroundColor = [UIColor grayColor];
    cell.accessoryView = label;
    }
    [cell.accessoryView setFrame:CGRectMake(0, 0, 75, 30)];

    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *tripString;
    /* if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
     return 100.0;
     else
     return UITableViewAutomaticDimension;*/
    
        tripString = [TableValues objectAtIndex:indexPath.row];

    CGRect textRect = [tripString boundingRectWithSize:CGSizeMake(300.f, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:[ UIFont fontWithName: @"Arial" size: 15.0 ]}
                                               context:nil];
    CGSize size = textRect.size;
    return size.height+5;
}
-(IBAction)Back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)call:(id)sender
{
    NSString *phNo = phNumber.text;
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",phNo]];
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call Facility Is Not Available!!!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [calert show];
    }
}
-(IBAction)showMap:(id)sender
{
#if Parent
    mapView = [[MapViewController alloc] initWithNibName:@"MapViewParent"  bundle:Nil model:model];
#else
    
    mapView = [[MapViewController alloc] initWithNibName:@"MapViewController"  bundle:Nil model:model withHome:home];
#endif
    mapView.modalPresentationStyle = UIModalPresentationFormSheet;
    mapView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:mapView animated:YES completion:nil];
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
