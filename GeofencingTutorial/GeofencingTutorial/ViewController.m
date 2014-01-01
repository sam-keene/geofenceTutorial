//
//  ViewController.m
//  GeofencingTutorial
//
//  Created by Sam  keene on 31/12/13.
//  Copyright (c) 2013 Sam  keene. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // I've put all of this code in the VC, but should probably movve it into its own LocationManager class
    [self initializeLocationManager];
}

- (void)initializeLocationManager
{
    // Check to ensure location services are enabled
    if(![CLLocationManager locationServicesEnabled]) {
        // handle loc services disabled
        return;
    }
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self initializeRegionMonitoring:[self buildGeofenceData]];
}

- (NSArray*)buildGeofenceData
{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"regions" ofType:@"plist"];
    NSArray *regionArray = [NSArray arrayWithContentsOfFile:plistPath];
    
    NSMutableArray *geofences = [NSMutableArray array];
    for(NSDictionary *regionDict in regionArray) {
        CLRegion *region = [self mapDictionaryToRegion:regionDict];
        [geofences addObject:region];
    }
    
    return [NSArray arrayWithArray:geofences];
}

- (void) initializeRegionMonitoring:(NSArray*)geofences
{
    // Check to ensure location services are enabled
    if(![CLLocationManager locationServicesEnabled]) {
        // handle this
        return;
    }
    
    if (self.locationManager == nil) {
        [NSException raise:@"Location Manager Not Initialized" format:@"You must initialize location manager first."];
    }
    
    if(![CLLocationManager regionMonitoringAvailable]) {
        // handle
        return;
    }
    
    //start monitiring regions
    for(CLRegion *geofence in geofences) {
        [_locationManager startMonitoringForRegion:geofence];
    }
}

- (CLRegion*)mapDictionaryToRegion:(NSDictionary*)dictionary
{
    NSString *title = [dictionary valueForKey:@"description"];
    
    CLLocationDegrees latitude = [[dictionary valueForKey:@"latitude"] doubleValue];
    CLLocationDegrees longitude =[[dictionary valueForKey:@"longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    
    CLLocationDistance regionRadius = [[dictionary valueForKey:@"radius"] doubleValue];
    
    return  [[CLRegion alloc] initCircularRegionWithCenter:centerCoordinate
                                                               radius:regionRadius
                                                           identifier:title];
  
}

// fired when user enters geofence
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self postGeofenceNotifWithMessage:@"Entered:" andRegionID:region.identifier];
}

// fired when user exits geo fence
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    // handle
}

-(void)postGeofenceNotifWithMessage:(NSString*)aMessage andRegionID:(NSString*)aRegionID
{
    UIApplication *app                = [UIApplication sharedApplication];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    if (notification == nil){return;}
    
    notification.alertBody = @"You've entered a geofence";
    notification.alertAction = @"Open Webview";
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:aRegionID forKey:aRegionID];
    notification.userInfo = infoDict;
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.applicationIconBadgeNumber = 1;
    
   [app presentLocalNotificationNow:notification];
}

@end
