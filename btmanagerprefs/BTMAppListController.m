#include "BTMAppListController.h"
#include "BTMDeviceOrderController.h"
#import <Preferences/PSSpecifier.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <Foundation/NSNotification.h>
#import <SparkAppItem.h>

@implementation BTMAppListController

NSArray* apps;

-(id)initWithAppList:(NSArray*)list {
	self.apps = list;
	return [super init];
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Apps" target:self];
	}

	NSArray* specs = [self addSpecifierLinks:self.apps toSpecifiers:_specifiers];
	self.specifiers = [specs mutableCopy];
	return specs;
	
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

-(NSArray*)addSpecifierLinks:(NSArray*)apps toSpecifiers:(NSArray*)specifiers {
	NSMutableArray* specs = [specifiers mutableCopy];
	PSSpecifier* defaultPage = specs[2];
	[defaultPage setProperty:[UIImage systemImageNamed:@"gear"] forKey:@"iconImage"];
	defaultPage.buttonAction = @selector(openOrderControllerForSpecifier:);
	specs[2] = defaultPage;
	NSMutableArray* appsSorted = [apps mutableCopy];
	[appsSorted sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES]]];
	for (SparkAppItem* app in appsSorted) {
		PSSpecifier* s = [
			NSClassFromString(@"PSSpecifier") preferenceSpecifierNamed:app.displayName
			target:self
			set:@selector(setPreferenceValue:specifier:)
			get:@selector(readPreferenceValue:)
			detail:nil
			cell:PSLinkCell
			edit:nil
		];
		[s setProperty:[app icon] forKey:@"iconImage"];
		[s setProperty:app forKey:@"app"];
		s.buttonAction = @selector(openOrderControllerForSpecifier:);
		[specs addObject:s];
	}

	return [specs copy];
}

-(void)openOrderControllerForSpecifier:(PSSpecifier*)specifier {
	SparkAppItem* app = [specifier.properties objectForKey:@"app"];
	NSMutableDictionary* properties = [[NSMutableDictionary alloc] init];
	if (!app) {
		properties[@"bundleId"] = @"SYSTEM";
		properties[@"application"] = @"System";
	} else {
		properties[@"bundleId"] = app.bundleIdentifier;
		properties[@"application"] = app.displayName;
	}
	properties[@"defaults"] = @"com.beckettobrien.btmanagerprefs";
	properties[@"postNotification"] = @"com.beckettobrien.btmanagerprefs.settingschanged";
	properties[@"allDevices"] = [[NSClassFromString(@"BluetoothManager") sharedInstance] pairedDevices];
	BTMDeviceOrderController* orderController = [[BTMDeviceOrderController alloc] init];
	[orderController setProperties:[properties copy]];
	[self.navigationController pushViewController:orderController animated:YES];
}

@end