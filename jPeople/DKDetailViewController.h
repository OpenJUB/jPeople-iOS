//
//  DKDetailViewController.h
//  jPeople
//
//  Created by Dmitry on 5/6/13.
//  Copyright (c) 2013 Dmitrii Cucleschin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface DKDetailViewController : UIViewController <MFMailComposeViewControllerDelegate> {

    IBOutlet UILabel *fullName;

    IBOutlet UIImageView *photo;
    IBOutlet UIImageView *flag;
    IBOutlet UIView *college;

    IBOutlet UILabel *description;
    IBOutlet UILabel *phone;
    IBOutlet UILabel *country;
    IBOutlet UILabel *major;
    IBOutlet UILabel *room;
    IBOutlet UILabel *email;
    IBOutlet UILabel *personId;

    IBOutlet UIButton *callButton;
    IBOutlet UIButton *emailButton;

}

@property (strong) NSDictionary *person;

-(IBAction) addToFavorites: (id)sender;
-(IBAction) sendEmail:(id)sender;
-(IBAction) call: (id)sender;


@end
