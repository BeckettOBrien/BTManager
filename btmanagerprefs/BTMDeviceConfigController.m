#import "BTMDeviceConfigController.h"

@implementation BTMDeviceConfigController

NSString* mac;
NSString* currentName;

- (NSArray *)specifiers {
	NSMutableArray* specifiers = [[NSMutableArray alloc] init];

    PSSpecifier* nameEdit = [NSClassFromString(@"PSSpecifier") preferenceSpecifierNamed:@"Name:"
			target:self
			set:@selector(changeName:specifier:)
			get:@selector(getCurrentName)
			detail:nil
			cell:PSEditTextCell
			edit:nil
    ];

    [specifiers addObject:nameEdit];

    PSSpecifier* settingsGroup = [NSClassFromString(@"PSSpecifier") preferenceSpecifierNamed:@"SETTINGS:"
            target:self
            set:nil
            get:nil
            detail:nil
            cell:PSGroupCell
            edit:nil
    ];
    [settingsGroup setProperty:@"When Confirm Before Switching is enabled, any time the audio route is switched to this device you will be prompted." forKey:@"footerText"];
    [specifiers addObject:settingsGroup];

    PSSpecifier* confirmSwitch = [NSClassFromString(@"PSSpecifier") preferenceSpecifierNamed:@"Confirm Before Switching"
            target:self
            set:@selector(setPreferenceValue:specifier:)
            get:@selector(readPreferenceValue:)
            detail:nil
            cell:PSSwitchCell
            edit:nil
    ];
    [confirmSwitch setProperty:@"com.beckettobrien.btmanagerprefs" forKey:@"defaults"];
    [confirmSwitch setProperty:@"com.beckettobrien.btmanagerprefs.settingschanged" forKey:@"PostNotification"];
    [confirmSwitch setProperty:@"switchConfirm" forKey:@"key"];
    [specifiers addObject:confirmSwitch];

    PSSpecifier* saveGroup = [NSClassFromString(@"PSSpecifier") emptyGroupSpecifier];
    [saveGroup setProperty:@"Save to store name changes. You must restart bluetoothd for changes to take effect. NOTE: You must press return on the keyboard to change the name." forKey:@"footerText"];
    [specifiers addObject:saveGroup];

    PSSpecifier* saveButton = [NSClassFromString(@"PSSpecifier") preferenceSpecifierNamed:@"Save"
            target:self
            set:nil
            get:nil
            detail:nil
            cell:PSButtonCell
            edit:nil
    ];
    saveButton.buttonAction = @selector(save);
    [saveButton setProperty:@2 forKey:@"alignment"];
    [specifiers addObject:saveButton];

    self.specifiers = specifiers;

	return specifiers;
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	return (settings[@"deviceSettings"][self.mac][specifier.properties[@"key"]]) ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSString *path = [NSString stringWithFormat:@"/User/Library/Preferences/%@.plist", specifier.properties[@"defaults"]];
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    if (!settings[@"deviceSettings"]) {
        settings[@"deviceSettings"] = [[NSMutableDictionary alloc] init];
    }
    if (!settings[@"deviceSettings"][self.mac]) {
        settings[@"deviceSettings"][self.mac] = [[NSMutableDictionary alloc] init];
    }
	[settings[@"deviceSettings"][self.mac] setObject:value forKey:specifier.properties[@"key"]];
	[settings writeToFile:path atomically:YES];
	CFStringRef notificationName = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (notificationName) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notificationName, NULL, NULL, YES);
	}
}

- (NSString*)getCurrentName {
    return self.currentName;
}

- (void)changeName:(id)name specifier:(PSSpecifier*)specifier {
    self.currentName = name;
}

- (void)save {
    [self saveName:self.currentName forAddress:self.mac];
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSString*)saveName:(NSString*)name forAddress:(NSString*)mac {
    NSMutableDictionary *devicePlist = [NSMutableDictionary dictionaryWithContentsOfFile:[self getMobileBluetoothDevicesPlistPath]];
    devicePlist[mac][@"Name"] = name;
    [devicePlist writeToFile:[self getMobileBluetoothDevicesPlistPath] atomically:YES];

    NSString *path = @"/User/Library/Preferences/com.beckettobrien.btmanagerprefs.plist";
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
    if (!settings[@"deviceSettings"]) {
        settings[@"deviceSettings"] = [[NSMutableDictionary alloc] init];
    }
    if (!settings[@"deviceSettings"][self.mac]) {
        settings[@"deviceSettings"][self.mac] = [[NSMutableDictionary alloc] init];
    }
	[settings[@"deviceSettings"][self.mac] setObject:name forKey:@"name"];
	[settings writeToFile:path atomically:YES];

    return name;
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

-(void)viewDidLoad {
    self.navigationItem.title = [NSString stringWithFormat:@"Device Configuration: %@", self.currentName];
    [super viewDidLoad];
}

-(void)_returnKeyPressed:(NSNotification *)sender {
    [self.view endEditing:YES];
    [super _returnKeyPressed:sender];
}

@end