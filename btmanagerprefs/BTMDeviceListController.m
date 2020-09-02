#import "BTMDeviceListController.h"
#import "BTMDeviceConfigController.h"

@implementation BTMDeviceListController

NSString* defaults;
NSString* postNotification;

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Devices" target:self];
	}

	NSArray* specs = [self addToSpecifiers:_specifiers];
	self.specifiers = [specs mutableCopy];
	return specs;
	
}

-(NSArray *)addToSpecifiers:(NSArray*)specifiers {
    NSMutableArray* specs = [specifiers mutableCopy];
    for (BluetoothDevice* device in [[NSClassFromString(@"BluetoothManager") sharedInstance] pairedDevices]) {
		PSSpecifier* s = [
			NSClassFromString(@"PSSpecifier") preferenceSpecifierNamed:[self getDevicePreferenceName:[device address]] ? : [device name]
			target:self
			set:@selector(setPreferenceValue:specifier:)
			get:@selector(readPreferenceValue:)
			detail:nil
			cell:PSLinkCell
			edit:nil
		];
		s.buttonAction = @selector(didOpenConfigForSpecifier:);
		[specs addObject:s];
        [s setProperty:[device address] forKey:@"address"];
        [s setProperty:[self getDevicePreferenceName:[device address]] ? : [device name] forKey:@"name"];
	}

	return [specs copy];
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return (settings[specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	[settings setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

- (id)getDevicePreferenceName:(NSString*)mac {
	NSString *path = @"/User/Library/Preferences/com.beckettobrien.btmanagerprefs.plist";
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return settings[@"deviceSettings"][mac][@"name"];
}

-(void)didOpenConfigForSpecifier:(PSSpecifier*)specifier {
    BTMDeviceConfigController *vc = [[BTMDeviceConfigController alloc] init];
	vc.mac = [specifier.properties objectForKey:@"address"];
    vc.currentName = [specifier.properties objectForKey:@"name"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)viewDidLoad {
    [super viewDidLoad];

    defaults = @"com.beckettobrien.btmanagerprefs";
    postNotification = @"com.beckettobrien.btmanagerprefs.settingschanged";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(restartBluetoothd)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor systemBlueColor];
}

-(void)viewWillAppear:(BOOL)animated {
    [self reloadSpecifiers];
    [super viewWillAppear:animated];

    if (self.isMovingToParentViewController == NO) {
        [self reloadSpecifiers];
    }
}

-(void)restartBluetoothd {
    NSTask *t = [[NSTask alloc] init];
    [t setLaunchPath:@"/usr/bin/killall"];
    [t setArguments:[NSArray arrayWithObjects:@"bluetoothd", nil]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Restart Bluetoothd" message:
                                @"Confirm to save name changes and restart bluetoothd. WARNING: Any connected devices will be disconnected."
                                preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [t launch];
                            [self reloadSpecifiers];
                        }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [alert addAction:ok];
    UIWindow* foundWindow = nil;
    for (UIWindow* window in [[UIApplication sharedApplication] windows]) {
        if (window.isKeyWindow) {
            foundWindow = window;
            break;
        }
    }
    [foundWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

-(NSString*)getMobileBluetoothDevicesPlistPath {
    NSString *basePath = @"/var/containers/Shared/SystemGroup";
    NSString *metadataPlistName = @".com.apple.mobile_container_manager.metadata.plist";
    NSString *mobileBTFolder;

    NSArray *allFolders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:nil];
    for (NSString *oneFolderName in allFolders) {
        NSString *fullFolderPath = [basePath stringByAppendingPathComponent:oneFolderName];
        NSString *metadataPlist = [fullFolderPath stringByAppendingPathComponent:metadataPlistName];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:metadataPlist];
        NSString *bundleID = [dict objectForKey:@"MCMMetadataIdentifier"];
        if ([bundleID isEqualToString:@"systemgroup.com.apple.bluetooth"]) {
            mobileBTFolder = fullFolderPath;
            break;
        }
    }

    NSString *finalPath = [mobileBTFolder stringByAppendingPathComponent:@"Library"];
    finalPath = [finalPath stringByAppendingPathComponent:@"Preferences"];
    finalPath = [finalPath stringByAppendingPathComponent:@"com.apple.MobileBluetooth.devices.plist"];
    return finalPath;
}

@end