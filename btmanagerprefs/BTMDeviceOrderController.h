#import <UIKit/UIKit.h>

@interface BTMDeviceOrderController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString *defaults;
@property (strong, nonatomic) NSString *application;
@property (strong, nonatomic) NSString *bundleId;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *availableDevices;
@property (strong, nonatomic) NSMutableArray *selectedDevices;
@property (strong, nonatomic) NSArray *allDevices;
@property (strong, nonatomic) NSString *postNotification;

-(id)setProperties:(NSDictionary*)properties;

@end

@interface BluetoothDevice : NSObject {
	NSString* _name;
	NSString* _address;
}
-(id)name;
-(id)address;
@end