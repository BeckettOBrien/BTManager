#import <Preferences/PSListController.h>

@interface BTMCreditsController: PSListController
@end

@implementation BTMCreditsController
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Credits" target:self];
	}

	return _specifiers;
}
@end