#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

@interface PSListController ()
-(void)_keyboardWillShow:(NSNotification *)sender;
-(void)_keyboardWillHide:(NSNotification *)sender;
-(void)_returnKeyPressed:(NSNotification *)sender;
@end

@interface BTMDeviceConfigController : PSListController
@property (strong, nonatomic) NSString* mac;
@property (strong, nonatomic) NSString* currentName;
@end