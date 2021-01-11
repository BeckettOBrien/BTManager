#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSEditableTableCell.h>

@interface BTMNameEditCell : PSEditableTableCell
@end

@interface PSSpecifier ()
-(void)performSetterWithValue:(id)arg1;
@end

@interface PSListController ()
-(void)_keyboardWillShow:(NSNotification *)sender;
-(void)_keyboardWillHide:(NSNotification *)sender;
-(void)_returnKeyPressed:(NSNotification *)sender;
@end

// @interface PSEditableTableCell
// -(id)textField;
// @end

@interface BTMDeviceConfigController : PSListController
@property (strong, nonatomic) NSString* mac;
@property (strong, nonatomic) NSString* currentName;
@end