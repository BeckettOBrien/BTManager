#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <SparkAppItem.h>

@interface BTMAppListController : PSListController
@property (nonatomic) NSArray* apps;
-(id)initWithAppList:(NSArray*)list;
@end

@interface BluetoothManager : NSObject
+(id)sharedInstance;
-(id)pairedDevices;
@end