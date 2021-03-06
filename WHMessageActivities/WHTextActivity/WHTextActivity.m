/*
 
 Copyright (c) 2013, Wayne Hartman
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of Wayne Hartman nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL WAYNE HARTMAN BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

#import "WHTextActivity.h"

@interface WHTextActivity () <MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) WHTextActivityItem *textActivityItem;
@property (nonatomic, copy) NSDictionary *navigationBarTitleTextAttributes;
@property (nonatomic, copy) NSDictionary *barButtonItemTitleTextAttributes;

@end

@implementation WHTextActivity

#pragma mark - UIActivity Overrides

+ (UIActivityCategory)activityCategory {
	return UIActivityCategoryShare;
}

- (NSString *)activityType {
	return NSStringFromClass([self class]);
}

- (NSString *)activityTitle {
	return NSLocalizedString(@"Message", @"title for iMessage activity");
}

- (UIImage *)activityImage {
	return [UIImage imageNamed:@"TextActivity"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
	if (![MFMessageComposeViewController canSendText]) {
		return NO;
	}
	
	for (id item in activityItems) {
		if ([item isKindOfClass:[WHTextActivityItem class]]) {
			return YES;
		}
	}
	
	return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
	for (id item in activityItems) {
		if ([item isKindOfClass:[WHTextActivityItem class]]) {
			self.textActivityItem = item;
		}
	}
}

- (UIViewController *)activityViewController {
	self.navigationBarTitleTextAttributes = [[UINavigationBar appearance] titleTextAttributes];
	self.barButtonItemTitleTextAttributes = [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] titleTextAttributesForState:UIControlStateNormal];
	[[UINavigationBar appearance] setTitleTextAttributes: @{NSForegroundColorAttributeName : [UIColor blackColor]}];
	[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:14.0/255 green:122.0/255 blue:254.0/255 alpha:1.0]} forState:UIControlStateNormal];
	
	MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
	
	if (self.textActivityItem.onTextActivitySelected) {
		self.textActivityItem.onTextActivitySelected(messageController);
	}
	
	messageController.messageComposeDelegate = self;
	return messageController;
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[[UINavigationBar appearance] setTitleTextAttributes: self.navigationBarTitleTextAttributes];
	[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:self.barButtonItemTitleTextAttributes forState:UIControlStateNormal];
	
	[self activityDidFinish:result == MessageComposeResultSent];
}


@end

