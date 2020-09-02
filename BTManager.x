#import <BTManager.h>

BOOL enabled = NO;
NSDictionary* deviceOrder;
NSDictionary* deviceSettings;
SBMediaController* mediaController;
MPAVRoutingController* routeController;
NSMutableDictionary* routes;
MPAVRoute* activeRoute;
MPAVRoute* previousRoute;

UIView* routingSuperview;

SBApplication* nowPlayingApplication;

void updateAvailableRoutes() {
    mediaController = [%c(SBMediaController) sharedInstance];
    routeController = [mediaController valueForKey:@"_routingController"];
    NSArray* availableRoutes = [routeController availableRoutes];
    [routes removeAllObjects];
    for (MPAVOutputDeviceRoute* route in availableRoutes) {
        if ([route isAppleTVRoute]) {
            continue;
        }
        NSString* uid = route.routeUID;
        [routes setObject:route forKey:uid];
    }
    activeRoute = [routeController pickedRoute];
}

void updateActiveRoute() {
    mediaController = [%c(SBMediaController) sharedInstance];
    routeController = [mediaController valueForKey:@"_routingController"];
    for (NSString* routeAddress in deviceOrder[nowPlayingApplication.bundleIdentifier] ?: deviceOrder[@"SYSTEM"]) {
        for (NSString* routeUID in routes) {
            if ([routeUID containsString:routeAddress]) {
                activeRoute = routes[routeUID];
                [routeController pickRoute:routes[routeUID]];
                return;
            }
        }
    }

    for (NSString* routeUID in routes) {
        if ([routeUID isEqual:@"Speaker"]) {
            [routeController pickRoute:routes[routeUID]];
            return;
        }
    }
}

static void loadPrefs() {
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.beckettobrien.btmanagerprefs.plist"];
    
    enabled = [[settings objectForKey:@"enabled"] boolValue];
    deviceOrder = [settings objectForKey:@"deviceOrder"] ?: [[NSDictionary alloc] init];
    deviceSettings = [settings objectForKey:@"deviceSettings"] ?: [[NSDictionary alloc] init];
}

%hook SBBluetoothController

-(id)deviceForAudioRoute:(id)arg1 {
    id out = %orig;
    if (enabled == 0) {
        return out;
    }

    if ([arg1[@"RouteUID"] isEqual:activeRoute.routeUID]) {
        return out;
    }

    previousRoute = activeRoute;

    updateAvailableRoutes();

    NSString* mac;
    for (NSString* routeAddress in deviceSettings) {
        if ([arg1[@"RouteUID"] containsString:routeAddress]) {
            mac = routeAddress;
        }
    }
    if (!mac) {
        return out;
    }
    if ([deviceSettings[mac][@"switchConfirm"] isEqual:@0]) {
        return out;
    }

    UIWindow* foundWindow = nil;
    for (UIWindow* window in [[UIApplication sharedApplication] windows]) {
        if (window.isKeyWindow) {
            foundWindow = window;
            break;
        }
    }

    if (routingSuperview) {
        if (routingSuperview.hidden == NO | [foundWindow class] == NSClassFromString(@"SBTransientOverlayWindow")) {
            return out;
        }
    }

    if ([[%c(SBMediaController) sharedInstance] isPlaying]) {
        [[%c(SBMediaController) sharedInstance] togglePlayPauseForEventSource:0];
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"Switch to %@", arg1[@"RouteName"]] message:
                                [NSString stringWithFormat:@"Confirm to switch to this device, cancel to return to %@ if available or switch to speakers and stop.", previousRoute.routeName]
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            if ([[%c(SBMediaController) sharedInstance] isPaused]) {
                                [[%c(SBMediaController) sharedInstance] togglePlayPauseForEventSource:0];
                            }
                        }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            updateAvailableRoutes();
                            MPAVOutputDeviceRoute* route = routes[previousRoute.routeUID] ?: routes[@"Speaker"];
                            [[[%c(SBMediaController) sharedInstance] valueForKey:@"_routingController"] pickRoute:route];
                            if (![route.routeUID isEqual:@"Speaker"]) {
                                [[%c(SBMediaController) sharedInstance] togglePlayPauseForEventSource:0];
                            }
                        }];
    [alert addAction:cancel];
    [alert addAction:ok];

    [foundWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    
    return out;
}

%end

%hook SBMediaController
-(void)routingControllerAvailableRoutesDidChange:(id)arg1 {
    %orig;

    if (enabled == 0) {
        return;
    }

    updateAvailableRoutes();
    if (!routes[activeRoute.routeUID]) {
        updateActiveRoute();
    }
}
-(void)_mediaRemoteNowPlayingApplicationDidChange:(id)arg1 {
    %orig;
    if (enabled == 0) {
        return;
    }

    nowPlayingApplication = [self nowPlayingApplication];
    updateAvailableRoutes();
    updateActiveRoute();
}

%end

%hook MPAVRoutingController

-(bool)pickRoute:(id)arg1 {
    updateAvailableRoutes();
    return %orig;
}

%end

%hook MPAVClippingTableView
-(void)didMoveToSuperview {
    routingSuperview = self.superview;
    %orig;
}
%end

%ctor {
    routes = [NSMutableDictionary new];
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.beckettobrien.btmanagerprefs.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
