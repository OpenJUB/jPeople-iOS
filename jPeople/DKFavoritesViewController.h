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

@interface DKFavoritesViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    NSMutableArray *favorites;
    
    IBOutlet UIImageView* background;
    IBOutlet UITableView* favoritesTable;
}

-(IBAction) openMenu;
-(void) renewData;
-(void) allToContacts;
-(void) checkContactsPermission;
-(void) allToContacts: (ABAddressBookRef)addressBook;
-(BOOL) contactExistsWithFirstname: (NSString*) first lastname: (NSString*)last;

@end
