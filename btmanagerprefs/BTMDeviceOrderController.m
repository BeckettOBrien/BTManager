#import "BTMDeviceOrderController.h"

@implementation BTMDeviceOrderController

- (id)setProperties:(NSDictionary*)properties {
    self.application = properties[@"application"];
	self.bundleId = properties[@"bundleId"];
    self.defaults = properties[@"defaults"];
    self.postNotification = properties[@"postNotification"];
    self.allDevices = properties[@"allDevices"];
	NSArray* selectedAddresses = [[self readPreferenceValue:self.bundleId] mutableCopy];
    self.selectedDevices = [[NSMutableArray alloc] init];
	for (NSString* mac in selectedAddresses) {
		for (BluetoothDevice* device in self.allDevices) {
			if ([[device address] isEqual:mac]) {
				[self.selectedDevices addObject:device];
				break;
			}
		}
	}
    self.availableDevices = [self.allDevices mutableCopy];
    [self.availableDevices removeObjectsInArray:self.selectedDevices];
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	self.navigationItem.title = [NSString stringWithFormat:@"Order Devices: %@", self.application];

	// Setup tableview
	self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;

	[self.tableView setEditing:YES animated:NO];
	[self.view addSubview:self.tableView];
}

- (void)save {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", self.defaults];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	if (!settings[@"deviceOrder"]) {
		settings[@"deviceOrder"] = [[NSMutableDictionary alloc] init];
	}
	NSMutableArray* selectedAddresses = [[NSMutableArray alloc] init];
	for (BluetoothDevice* device in self.selectedDevices) {
		[selectedAddresses addObject:[device address]];
	}
	[settings[@"deviceOrder"] setObject:selectedAddresses forKey:self.bundleId];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (__bridge CFStringRef)self.postNotification;
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

- (id)readPreferenceValue:(NSString*)key {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", self.defaults];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return settings[@"deviceOrder"][key];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Selected Devices";
	} else {
		return @"Available Devices";
	}
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return [self.selectedDevices count];
	} else {
		return [self.availableDevices count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		static NSString *cellIdentifier = @"SelectedDeviceCell";

		UITableViewCell *cell = (UITableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		}

		BluetoothDevice* device = self.selectedDevices[indexPath.row];
		cell.textLabel.text = [device name];

		return cell;
	} else {
		static NSString *cellIdentifier = @"DeviceCell";

		UITableViewCell *cell = (UITableViewCell *)[tv dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		}

		BluetoothDevice* device = self.availableDevices[indexPath.row];
		cell.textLabel.text = [device name];

		return cell;
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
		   toIndexPath:(NSIndexPath *)toIndexPath {
	if (fromIndexPath != toIndexPath) {
		if (toIndexPath.section == 0) {
			if (fromIndexPath.section == toIndexPath.section) {
				NSString *identifier = [self.selectedDevices objectAtIndex:fromIndexPath.row];
				[self.selectedDevices removeObject:identifier];
				[self.selectedDevices insertObject:identifier atIndex:toIndexPath.row];
			} else {
				NSString *identifier = [self.availableDevices objectAtIndex:fromIndexPath.row];
				[self.availableDevices removeObject:identifier];
				[self.selectedDevices insertObject:identifier atIndex:toIndexPath.row];
			}
		} else {
			if (fromIndexPath.section == toIndexPath.section) {
				NSString *identifier = [self.availableDevices objectAtIndex:fromIndexPath.row];
				[self.availableDevices removeObject:identifier];
				[self.availableDevices insertObject:identifier atIndex:toIndexPath.row];
			} else {
				NSString *identifier = [self.selectedDevices objectAtIndex:fromIndexPath.row];
				[self.selectedDevices removeObject:identifier];
				[self.availableDevices insertObject:identifier atIndex:toIndexPath.row];
			}
		}

		[self save];
		[self.tableView reloadData];
	} else {
		[self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
	}
}

@end