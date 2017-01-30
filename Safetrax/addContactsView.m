//
//  addContactsView.m
//  Safetrax
//
//  Created by Kumaran on 09/01/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import "addContactsView.h"
#import "HelpContactsViewController.h"
#import "AddressBookUI/AddressBookUI.h"
ABPeoplePickerNavigationController *picker;
@interface addContactsView ()

@end

@implementation addContactsView
@synthesize segmentedType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil with:(HelpContactsViewController *)helpObject   {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        help =helpObject;
        segmentedType.selectedSegmentIndex =1;
    }
    return self;
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
}
- (IBAction)segmentedTypeChanged:(id)sender
{
    addNewContact = nil;
     addNewContact =[[newContactView alloc] initWithNibName:@"newContactView" bundle:nil withString:[segmentedType titleForSegmentAtIndex:[segmentedType selectedSegmentIndex]] withObject:self];
}
-(IBAction)newContacts:(id)sender
{
    ABNewPersonViewController *newPersonViewController = [[ABNewPersonViewController alloc] init];
    newPersonViewController.newPersonViewDelegate = self;
    UINavigationController *personNavController = [[UINavigationController alloc] initWithRootViewController:newPersonViewController];
    [self presentModalViewController:personNavController animated:YES];
}
-(IBAction)importContacts:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [help loadContacts:[segmentedType titleForSegmentAtIndex:[segmentedType selectedSegmentIndex]]];
    }];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    segmentedType.selectedSegmentIndex =0;
     addNewContact =[[newContactView alloc] initWithNibName:@"newContactView" bundle:nil withString:[segmentedType titleForSegmentAtIndex:[segmentedType selectedSegmentIndex]] withObject:self];
    // Do any additional setup after loading the view from its nib.
}
-(void)removeView:(NSString*)contactString
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [help removeView:contactString];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(IBAction)addPerson:(id)sender {
    ABNewPersonViewController *view = [[ABNewPersonViewController alloc] init];
    view.newPersonViewDelegate = self;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:view];
    [picker presentViewController:nc animated:YES completion:nil];
}
#pragma mark - UINavigationControllerDelegate
// Called when the navigation controller shows a new top view controller via a push, pop or setting of the view controller stack.
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    //set up the ABPeoplePicker controls here to get rid of he forced cacnel button on the right hand side but you also then have to
    // the other views it pcuhes on to ensure they have to correct buttons shown at the correct time.
    
    if([navigationController isKindOfClass:[ABPeoplePickerNavigationController class]]
       && [viewController isKindOfClass:[ABPersonViewController class]]){
        navigationController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPerson:)];
        
        navigationController.topViewController.navigationItem.leftBarButtonItem = nil;
    }
    else if([navigationController isKindOfClass:[ABPeoplePickerNavigationController class]]){
        navigationController.topViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPerson:)];
        
        navigationController.topViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    }
}
#pragma mark - ABPersonViewControllerDelegate
// Called when the user selects an individual value in the Person view, identifier will be kABMultiValueInvalidIdentifier if a single value property was selected.
// Return NO if you do not want anything to be done or if you are handling the actions yourself.
// Return YES if you want the ABPersonViewController to perform its default action.
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return YES;
}
#pragma mark - ABNewPersonViewControllerDelegate
// Called when the user selects Save or Cancel. If the new person was saved, person will be
// a valid person that was saved into the Address Book. Otherwise, person will be NULL.
// It is up to the delegate to dismiss the view controller.
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person{
   [newPersonView dismissViewControllerAnimated:YES completion:^{
         [self dismissViewControllerAnimated:YES completion:nil];
    }];
    if(person != NULL){
    NSString *contactName = CFBridgingRelease(ABRecordCopyCompositeName(person));
    NSString *name = [NSString stringWithFormat:@"%@", contactName ? contactName : @"No Name"];
    ABMultiValueRef phoneRecord = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFStringRef phoneNumber = ABMultiValueCopyValueAtIndex(phoneRecord, 0);
    NSString *phone  = (__bridge_transfer NSString *)phoneNumber;
        if (phoneRecord) {
            CFRelease(phoneRecord);
        }
    NSString *joinContact = [NSString stringWithFormat:@"%@\n%@",name,phone];
        NSMutableArray *mutableContactArray;
    NSArray *emgContactArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"emgcontact"];
        if ( [emgContactArray count] > 0 ){
            mutableContactArray = [emgContactArray mutableCopy];
        }
        else
        {
            NSLog(@"else");
            mutableContactArray = [[NSMutableArray alloc] init];
        }
      
          
    NSDictionary *addConntacts = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",phone,@"phone",[segmentedType titleForSegmentAtIndex:[segmentedType selectedSegmentIndex]],@"type",nil];
            [mutableContactArray addObject:addConntacts];
      //  NSLog(@"%@--%@---join %@",mutableContactArray,addConntacts,joinContact);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableContactArray options:0 error:NULL];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [[NSUserDefaults standardUserDefaults] setObject:mutableContactArray forKey:@"emgcontact"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self sendContacts:jsonString];
            [help removeView:joinContact];
        
    }
}
#pragma mark - ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
     // [picker dismissViewControllerAnimated:YES completion:nil];
}
// Called after a person has been selected by the user.
// Return YES if you want the person to be displayed.
// Return NO  to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person{
    return YES;
}
-(void)sendContacts:(NSString *)contacts
{
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    NSString *passwords = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
    NSString *userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"empid"];
    NSMutableDictionary *config_dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:userName, @"username", passwords, @"password", nil];
    NSString *findAttendance =[NSString stringWithFormat:@"{\"empid\":\"%@\"}",userid];
    NSString *setAttendance =[NSString stringWithFormat:@"{\"$set\":{\"emgcontact\":%@}}",contacts];
    NSError *error_config;
    NSData* config_json = [NSJSONSerialization dataWithJSONObject:config_dict options:kNilOptions error:&error_config];
    NSString *newStr2 = [[NSString alloc] initWithData:config_json encoding:NSUTF8StringEncoding];
    NSString *str= [NSString stringWithFormat:@"%@\n%@\n%@", newStr2,findAttendance,setAttendance];
    MongoRequest *requestWraper =[[MongoRequest alloc] initWithQuery:@"write" withMethod:@"POST" andColumnName:@"empinfo"];
    [requestWraper setPostParamFromString:str];
    [requestWraper print];
    RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
    [RestClient setDelegate:self];
    [RestClient execute];
}
-(IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark RESTCallBack Delegate Methods
-(void)onResponseReceived:(NSData *)data
{

}
-(void)onFailure
{
    NSLog(@"Failure callback");
}
-(void)onConnectionFailure
{
    NSLog(@"Connection Failure callback");
}
-(void)onFinishLoading
{
    NSLog(@"emg contact finished");
}
@end
