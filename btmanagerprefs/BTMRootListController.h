#import <Preferences/PSListController.h>

@interface BTMRootListController : PSListController
@property (nonatomic) NSArray* appList;
@end

@interface SBApplicationController : NSObject
+(id)sharedInstance;
-(NSArray*)allApplications;
@end

@interface SBApplicationIcon {
    UIImage* _chachedSquareHomeScreenContentsImage;
}
-(id)initWithApplication:(id)arg1;
-(id)generateIconImage:(id)arg1;
@end

@interface SBApplication : NSObject
@property (nonatomic, readonly) NSString * displayName;
@end

@interface OBButtonTray : UIViewController
-(void)addButton:(id)arg1;
-(void)addCaptionText:(id)arg1;
@end

@interface OBBoldTrayButton : UIButton
+(id)buttonWithType:(long long) arg1;
-(void)setTitle:(id)arg1 forState:(unsigned long long)arg2;
@end

@interface OBWelcomeController : UIViewController
-(OBButtonTray*)buttonTray;
-(id)initWithTitle:(id)arg1 detailText:(id)arg2 icon:(id)arg3;
-(void)addBulletedListItemWithTitle:(id)arg1 description:(id)arg2 image:(id)arg3;
@end