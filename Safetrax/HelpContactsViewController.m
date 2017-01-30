//
//  HelpContactsViewController.m
//  Safetrax
//
//  Created by Kumaran on 09/01/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import "HelpContactsViewController.h"
#import "AddressBookUI/AddressBookUI.h"
#import "getEmgContacts.h"
NSString *selectedContactType;
extern NSArray *tripList;
@interface HelpContactsViewController ()

@end
ABPeoplePickerNavigationController *Peoplepicker;
@implementation HelpContactsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil   {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        getEmgContacts *emgContacts = [[getEmgContacts alloc] init];
        contactList = [[NSMutableArray alloc]init];
        NSArray *emgContactArray = [[NSUserDefaults standardUserDefaults]
                                    arrayForKey:@"emgcontact"];
        for(NSDictionary *dictionary in emgContactArray)
        {
            NSString *contactStr = [NSString stringWithFormat:@"%@\n%@",[dictionary objectForKey:@"name"],[dictionary objectForKey:@"phone"]];
            [contactList addObject:contactStr];
        }
        addContacts = [[addContactsView alloc] initWithNibName:@"addContactsView" bundle:nil with:self];
    }
    return self;
}
-(void)removeView:(NSString*)contactString
{
    if(![contactList containsObject:contactString]){
        [contactList addObject:contactString];
        [contactTable reloadData];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Help Contacts"
                                                        message:@"Phone Number Already Exists!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    if([contactList count] > 0){
        contactTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        contactTable.delegate = self;
        contactTable.dataSource = self;
        [contactTable reloadData];
        [self.view addSubview:contactTable];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
     contactTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Do any additional setup after loading the view from its nib.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)moreButtonClicked
{
    UIActionSheet *actionSheet;
    if([contactTable isEditing] == YES)
    {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                       @"Add New",
                       @"Done",
                       nil];
    }
    else
    {
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Add New",
                            @"Edit",
                            nil];
    }
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Add New"]) {
        NSLog(@"add new");
        [contactTable setEditing:NO animated:YES];
        [self presentViewController:addContacts animated:YES completion:nil];
    }
    
    if ([buttonTitle isEqualToString:@"Edit"]) {
        NSLog(@"edit");
        [contactTable setEditing:YES animated:YES];
    }
    if ([buttonTitle isEqualToString:@"Done"]) {
        NSLog(@"clear");
        [contactTable setEditing:NO animated:YES];
    }
}
-(IBAction)addContacts:(id)sender
{
    addContacts.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:addContacts animated:YES completion:nil];
}
-(void)loadContacts:(NSString *)selectedType
{
    NSLog(@"loadcontacts");
    selectedContactType = selectedType;
    Peoplepicker  = [[ABPeoplePickerNavigationController alloc] init];
    Peoplepicker.peoplePickerDelegate = self;
  [self presentViewController:Peoplepicker animated:YES completion:nil];
   
}

-(IBAction)sos:(id)sender {
    sosController = nil;
    if (!tripList || !tripList.count){
        sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:nil];
    }
    else{
        sosController = [[SOSMainViewController alloc] initWithNibName:@"SOSMainViewController" bundle:nil model:[tripList objectAtIndex:0]];
    }    [self presentViewController:sosController animated:YES completion:nil];
}
-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
     shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property
                             identifier:(ABMultiValueIdentifier)identifier
{
    NSString *contactName = CFBridgingRelease(ABRecordCopyCompositeName(person));
    NSString *name = [NSString stringWithFormat:@"%@", contactName ? contactName : @"No Name"];
    ABMultiValueRef phoneRecord = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFStringRef phoneNumber = ABMultiValueCopyValueAtIndex(phoneRecord, identifier);
    NSString *phone  = (__bridge_transfer NSString *)phoneNumber;
    if (phoneRecord) {
        CFRelease(phoneRecord);
    }
    NSString *joinContact = [NSString stringWithFormat:@"%@\n%@",name,phone];
    NSMutableArray *mutableContactArray ;
    NSArray *emgContactArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"emgcontact"];
  
    if ( [emgContactArray count] > 0 ){
        
        mutableContactArray = [emgContactArray mutableCopy];
    }
    else
    {
        NSLog(@"else");
        mutableContactArray = [[NSMutableArray alloc] init];
        
    }
     if(![contactList containsObject:joinContact]){
    NSLog(@"phonerecordss %@ %@",name,emgContactArray);
    NSDictionary *addConntacts = [NSDictionary dictionaryWithObjectsAndKeys:name,@"name",phone,@"phone",selectedContactType,@"type",nil];
    [mutableContactArray addObject:addConntacts];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableContactArray options:0 error:NULL];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [[NSUserDefaults standardUserDefaults] setObject:mutableContactArray forKey:@"emgcontact"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self sendContacts:jsonString];
         [contactList addObject:joinContact];
     }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Help Contacts"
                                                        message:@"Phone Number Already Exists!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
     NSLog(@"contact list %@",contactList);
    [contactTable reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    NSLog(@"selectperson");
    [self peoplePickerNavigationController:peoplePicker shouldContinueAfterSelectingPerson:person property:property identifier:identifier];
    NSString *contactName = CFBridgingRelease(ABRecordCopyCompositeName(person));
    NSString *name = [NSString stringWithFormat:@"%@", contactName ? contactName : @"No Name"];
    ABMultiValueRef phoneRecord = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFStringRef phoneNumber = ABMultiValueCopyValueAtIndex(phoneRecord, 0);
    NSString *phone  = (__bridge_transfer NSString *)phoneNumber;
    CFRelease(phoneRecord);
    NSString *joinContact = [NSString stringWithFormat:@"%@\n%@",name,phone];
}
-(IBAction)Back:(id)sender
{
    [contactTable setEditing:NO animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma - markup TableView Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    return [contactList count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    UIImageView* callImage = [[UIImageView alloc] initWithFrame:CGRectMake(220.0f, 10.0f, 30, 30)];

   // callImage.image = [UIImage imageNamed: @"_0021_call.png"];
    //[cell addSubview:callImage];
    cell.textLabel.text = [contactList objectAtIndex:indexPath.row];
    cell.textLabel.numberOfLines =0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    return cell;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [contactList removeObjectAtIndex:indexPath.row];
    NSMutableArray *mutableContactArray ;
    NSArray *emgContactArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"emgcontact"];
    if ( [emgContactArray count] > 0 ){
        mutableContactArray = [emgContactArray mutableCopy];
        [mutableContactArray removeObjectAtIndex:indexPath.row];
    }
    [[NSUserDefaults standardUserDefaults] setObject:mutableContactArray forKey:@"emgcontact"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableContactArray options:0 error:NULL];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self sendContacts:jsonString];
    [contactTable reloadData];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   /* UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellText = selectedCell.textLabel.text;
    NSArray *empDetails = [cellText componentsSeparatedByString:@"\n"];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",[empDetails objectAtIndex:1]]];
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView *calert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [calert show];
    }*/
}
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [Peoplepicker dismissViewControllerAnimated:YES completion:nil];
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
     NSLog(@"emg %@",str);
    MongoRequest *requestWraper =[[MongoRequest alloc] initWithQuery:@"write" withMethod:@"POST" andColumnName:@"empinfo"];
    [requestWraper setPostParamFromString:str];
    [requestWraper print];
    RestClientTask *RestClient =[[RestClientTask alloc]initWithMongo:requestWraper];
    [RestClient setDelegate:self];
    [RestClient execute];
}
#pragma mark RESTCallBack Delegate Methods
-(void)onResponseReceived:(NSData *)data
{
    NSString *newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"received----%@",newStr);
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
