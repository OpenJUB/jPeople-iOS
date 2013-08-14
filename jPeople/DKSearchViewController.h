//
//  DKSearchViewController.h
//  jPeople
//
//  Created by Dmitry on 5/6/13.
//  Copyright (c) 2013 Dmitrii Cucleschin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>

@interface DKSearchViewController : UIViewController <UISearchBarDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
    NSMutableArray* foundPeople;
    IBOutlet UISearchBar* searchField;
    IBOutlet UITableView* searchResults;
}

-(IBAction) openMenu;

-(BOOL) isJacobs;
-(void) allToFavorites;
-(void) allToContacts;
-(BOOL) contactExistsWithFirstname: (NSString*) first lastname: (NSString*)last;


@end
