#include "BTMRootListController.h"
#include "BTMAppListController.h"
#import <Preferences/PSSpecifier.h>
#import <SparkAppList.h>

OBWelcomeController* welcomeController;
@implementation BTMRootListController

NSArray* appList;

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
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

-(void)setupWelcomeController {
	welcomeController = [[NSClassFromString(@"OBWelcomeController") alloc] initWithTitle:@"BTManager+" detailText:@"A tweak that gives you the tools to take control of your bluetooth devices"
						icon:[UIImage imageWithContentsOfFile:@"/Library/Application Support/btmanager.bundle/bluetooth.png"]];
	[welcomeController addBulletedListItemWithTitle:@"Customize" description:@"Change the name of all your bluetooth devices, not just Apple products"
						image:[UIImage imageWithContentsOfFile:@"/Library/Application Support/btmanager.bundle/edit.png"]];
	[welcomeController addBulletedListItemWithTitle:@"Unlimited Configuration" description:@"Manage the ways your devices interact with your apps" image:[UIImage systemImageNamed:@"slider.horizontal.3"]];
	[welcomeController addBulletedListItemWithTitle:@"Take Control" description:@"Only switch devices when you want" image:[UIImage systemImageNamed:@"gear"]];
	[welcomeController.buttonTray addCaptionText:@"Developed by Beckett O'Brien"];

	OBBoldTrayButton* continueButton = [NSClassFromString(@"OBBoldTrayButton") buttonWithType:1];
	[continueButton addTarget:self action:@selector(dismissWelcomeController) forControlEvents:UIControlEventTouchUpInside];
	[continueButton setTitle:@"Continue" forState:UIControlStateNormal];
	[continueButton setClipsToBounds:YES];
	[continueButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[continueButton.layer setCornerRadius:15];
	[welcomeController.buttonTray addButton:continueButton];

	welcomeController.modalPresentationStyle = UIModalPresentationPageSheet;
	welcomeController.modalInPresentation = YES;
	welcomeController.viewIfLoaded.backgroundColor = [UIColor systemGray6Color]; //[UIColor systemGray6Color] (colorWithRed: 0.11 green: 0.11 blue: 0.12 alpha: 1.00)
	[self presentViewController:welcomeController animated:YES completion:nil];
}

-(void)dismissWelcomeController {
	NSString *path = @"/var/mobile/Library/Preferences/com.beckettobrien.btmanagerprefs.plist";
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	[settings setObject:@1 forKey:@"didShowOBWelcomeController"];
	[settings writeToFile:path atomically:YES];
	[welcomeController dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewDidLoad {
	SparkAppList* appList = [[SparkAppList alloc] init];
    [appList getAppList:^(NSArray* apps){
        self.appList = apps;
    }];

	// This segment has been removed for the time being due to scaling issues
	// UITableView *tableView = [self valueForKey:@"_table"];
    // tableView.tableHeaderView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/btmanagerprefs.bundle/PrefHeader.png"]];
	// tableView.tableHeaderView.contentMode = UIViewContentModeScaleAspectFill;
	// CGRect rect = tableView.tableHeaderView.frame;
	// rect.size.height = 450;
	// tableView.tableHeaderView.frame = rect;
	// tableView.tableHeaderView.frame.size.height = @450;

	NSString *path = @"/var/mobile/Library/Preferences/com.beckettobrien.btmanagerprefs.plist";
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];
	[settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:path]];
	NSNumber *didShowOBWelcomeController = [settings valueForKey:@"didShowOBWelcomeController"] ?: @0;
	if([didShowOBWelcomeController isEqual:@0]){
		[self setupWelcomeController];
	}

	[super viewDidLoad];
}

- (void)didOpenAppListController {
    BTMAppListController *vc = [[BTMAppListController alloc] init];
	vc.apps = self.appList;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didOpenSource {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.github.com/beckettobrien/BTManager"] options:@{} completionHandler:nil];
}

- (void)didOpenPrank {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.abc.ca.gov/education/licensee-education/checking-identification/"] options:@{} completionHandler:nil];
}

- (void)didOpenSupport {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.me/beckettobrien"] options:@{} completionHandler:nil];
}

@end