//
//  HomeViewController.h
//  Safetrax
//
//
//  Copyright (c) 2014 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#include "FXBlurView.h"
//#import "FloatingLabel.h"
#import "RestClientTask.h"
#import "tripSummaryViewController.h"
@interface HomeViewController : UIViewController <MKMapViewDelegate, NSURLConnectionDelegate, UIAlertViewDelegate,RestCallBackDelegate,UITableViewDelegate,UITableViewDataSource>{
    FXBlurView *infoView;
    UIImageView *profilePic;
    UIButton *attending;
    UILabel *attendingLabel;
    UILabel *notAttendingLabel;
    UILabel *attendanceConfirmed;
    UIButton *notAttending;
    UIButton *reachedDestination;
    UIButton *call;
    UILabel *topLabel;
    UIImageView *cabTransport;
    UIImageView *ownTransport;
    MKMapView *map;
    UIAlertView *attendingAlert;
    UIAlertView *notAttendingAlert;
    NSMutableArray *tripDetails;
    tripSummaryViewController *tripSummary;
    NSDictionary *tripDrop;
    NSMutableArray *timesArrayForNotification;
    NSDictionary *tripPickup;
    NSMutableArray *unique ;
    NSMutableArray *tripsSection1;
    NSMutableArray *tripsSection2;
    NSMutableData *_responseData;
    UIRefreshControl *refreshControl;
    UILabel *label;
    IBOutlet UIButton *sosbutton;
}
@property (nonatomic , strong) NSArray *ratingSubmittedTripsArray;
@property (weak, nonatomic) IBOutlet UILabel *logoutLabel;
@property (weak, nonatomic) IBOutlet UILabel *loginLable;
@property (weak, nonatomic) IBOutlet UIView *noScheduleView;
@property (weak, nonatomic) IBOutlet UILabel *loginTime;
@property (weak, nonatomic) IBOutlet UILabel *logoutTime;
@property (weak, nonatomic) IBOutlet UIImageView *scheduleImage;
@property (weak, nonatomic) IBOutlet UILabel *currentDate;
@property (nonatomic, retain) IBOutlet UITableView *tripTable;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mainSegment;

@property (weak , nonatomic) IBOutlet UIButton *sosMainButton;

- (IBAction)mainSegmentedTypeChanged:(id)sender;
-(IBAction)openMenu:(id)sender;
-(IBAction)attending:(id)sender;
-(IBAction)notAttending:(id)sender;
-(IBAction)call:(id)sender;
-(IBAction)sos:(id)sender;
-(void)attendance;
-(void)driverInfo;
-(void)reachedDestination;
-(void)cleanInfoView;
-(void)loadingScreen;
-(void)errorScreen;
-(void)refresh;
-(void)noTrip;
-(void)endTrip;
-(void)initialMap;
-(void)notAttendingOptions;
-(void)notAttending;
-(void)empAttendance;
-(void)didFinishvalidation;
-(void)ShowFeedback;
@end
