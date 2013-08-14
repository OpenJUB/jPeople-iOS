//
//  DKFavoritesViewController.h
//  jPeople
//
//  Created by Dmitry on 5/6/13.
//  Copyright (c) 2013 Dmitrii Cucleschin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>

@interface DKFavoritesViewController : UITableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    NSMutableArray *favorites;
}

-(IBAction) openMenu;
-(void) renewData;
-(void) allToContacts;
-(BOOL) contactExistsWithFirstname: (NSString*) first lastname: (NSString*)last;


@end
