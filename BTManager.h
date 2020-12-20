#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NSString;

@class NSMutableArray;

@interface SBBluetoothController : NSObject {

	NSMutableArray* _devices;
	BOOL _tetheringConnected;

}
+(id)sharedInstance;
-(void)startWatchingForDevices;
-(BOOL)tetheringConnected;
-(void)stopWatchingForDevices;
-(id)firstBTDeviceToReportBatteryLevel;
-(void)iapDeviceChanged:(id)arg1 ;
-(void)connectionChanged:(id)arg1 ;
-(void)addDeviceNotification:(id)arg1 ;
-(void)removeDeviceNotification:(id)arg1 ;
-(void)batteryChanged:(id)arg1 ;
-(void)bluetoothDeviceInitiatedVoiceControl:(id)arg1 ;
-(void)bluetoothDeviceEndedVoiceControl:(id)arg1 ;
-(void)noteDevicesChanged;
-(void)updateTetheringConnected;
-(void)updateBattery;
-(BOOL)canReportBatteryLevel;
-(id)deviceForAudioRoute:(id)arg1 ;
-(void)dealloc;
-(int)batteryLevel;
@end

@interface BluetoothDevice : NSObject
-(id)name;
-(id)address;
@end

@interface BTSDevice : NSObject
-(id)name;
-(id)identifier;
@end

@interface BTSDeviceClassic : BTSDevice
@end

@interface SBApplication: NSObject
@property (nonatomic,readonly) NSString * bundleIdentifier; 
@property (nonatomic,readonly) NSString * displayName;
@end

@interface MPAVRoute : NSObject
@property (nonatomic,readonly) NSString * routeUID;
-(id)routeName;
-(BOOL)isPickedOnPairedDevice;
-(BOOL)isSplitterCapable;
-(BOOL)isShareableRoute;
-(BOOL)isAirpodsRoute;
-(BOOL)isSplitRoute;
@end

@interface MPAVRoutingController : NSObject
@property (nonatomic, readonly, copy) NSArray *availableRoutes;
@property (nonatomic, readonly) MPAVRoute* pickedRoute;
-(bool)pickRoute:(id)arg1;
-(id)availableRoutes;
@end

@interface SBMediaController : NSObject {
    MPAVRoutingController* _routingController;
}
@property (nonatomic,assign,readonly) SBApplication * nowPlayingApplication;
+(id)sharedInstance;
-(void)routingControllerAvailableRoutesDidChange:(id)arg1;
-(void)_mediaRemoteNowPlayingApplicationDidChange:(id)arg1;
-(BOOL)isPaused;
-(BOOL)isPlaying;
-(BOOL)togglePlayPauseForEventSource:(NSInteger)arg1;
@end

@interface MRAVConcreteOutputDevice : NSObject
-(id)name;
@end

@interface MPAVOutputDeviceRoute : MPAVRoute
-(bool)isAppleTVRoute;
-(id)routeUID;
// -(id)routeName;
// -(BOOL)isPickedOnPairedDevice;
@end

@interface MPAVRoutingViewControllerDelegate
-(void)routingViewController:(id)arg1 didPickRoute:(id)arg2;
@end

@interface MPAVClippingTableView: UIView
@end