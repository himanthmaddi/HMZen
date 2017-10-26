//
//  MapViewController.h
//  Safetrax
//
//  Created by Kumaran on 08/01/15.
//  Copyright (c) 2015 iOpex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "TripModel.h"
#import "RestClientTask.h"
@class HomeViewController;
@interface MapViewController : UIViewController<RestCallBackDelegate,GMSMapViewDelegate,UIAlertViewDelegate , UIActionSheetDelegate>
{
    GMSMapView *mapView_;
    TripModel *tripModel;
    NSTimer *timer;
    __weak IBOutlet UIView *mapView;
    //    GMSMarker *marker_current;
    NSMutableData *_responseData;
    NSMutableArray *markers;
    GMSMarker *marker_driver;
    GMSMarker *marker_start;
    HomeViewController *home;
}
@property (nonatomic , strong) IBOutlet UIButton *sosMainButton;
@property (weak, nonatomic) IBOutlet UIButton *reachedButton;
@property (weak, nonatomic) IBOutlet UIButton *waitingButton;
@property (weak, nonatomic) IBOutlet UIButton *boardedButton;
@property (weak, nonatomic) IBOutlet UIButton *callButton;
@property (weak, nonatomic) IBOutlet UIButton *tripConfirmationsButton;

@property (weak, nonatomic) IBOutlet UIView *buttonsView;

@property (strong , nonatomic) NSString *etaString;

@property (nonatomic, retain) IBOutlet UILabel *DriverName;
@property (nonatomic, retain) IBOutlet UIButton *MapHelpText;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil model:(TripModel*)model withHome:(HomeViewController*)homeobject;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil model:(TripModel*)model;
-(IBAction)Back:(id)sender;
@end

