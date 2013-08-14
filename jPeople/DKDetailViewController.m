//
//  DKDetailViewController.m
//  jPeople
//
//  Created by Dmitry on 5/6/13.
//  Copyright (c) 2013 Dmitrii Cucleschin. All rights reserved.
//

#import "DKDetailViewController.h"

#warning Make iPhone 5 / professor compliant

@implementation DKDetailViewController

@synthesize person;

-(void) viewDidLoad {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    self.navigationItem.hidesBackButton = YES;
    
    // Left
    UIButton *a1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [a1 setFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [a1 addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    [a1 setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:a1];
    self.navigationItem.leftBarButtonItem = barButton;

    // Right
    BOOL exists = FALSE;
    
    for (NSDictionary *personObject in [prefs objectForKey:@"favorites"])
        if ([[personObject objectForKey:@"eid"] isEqual:[person objectForKey:@"eid"]]) {
            exists = TRUE;
        }
    
    self.navigationItem.rightBarButtonItem = [self barButtonForExisting:exists];
    
    fullName.text = [NSString stringWithFormat:@"%@ %@",[person objectForKey:@"fname"],[person objectForKey:@"lname"]];
    personId.text = [person objectForKey:@"eid"];
    description.text = [person objectForKey:@"description"];
    
    if (![[person objectForKey:@"majorlong"] isEqual: @""]) major.text = [person objectForKey:@"majorlong"]; else major.text = [person objectForKey:@"deptinfo"];
    
    if (![[person objectForKey:@"phone"] isEqual:@""]) {
        if ([[person objectForKey:@"phone"] length] == 4)
            phone.text = [NSString stringWithFormat:@"(+49 421 200)   %@",[person objectForKey:@"phone"]];
        else phone.text = [person objectForKey:@"phone"];
    }
    else {
        phone.text = @"";
        callButton.hidden = YES;
    }
    
    if (![[person objectForKey:@"room"] isEqual: @""]) room.text = [person objectForKey:@"room"]; else room.text = [person objectForKey:@"office"];
    
    email.text = [person objectForKey:@"email"];
    country.text = [person objectForKey:@"country"];
    
    flag.image = [DKCountry iconForCountry:[person objectForKey:@"country"]];
    
    if ([[person objectForKey:@"college"] isEqual:@"Krupp"]) {
        college.backgroundColor = RGB(217,41,41);
    }
    else if ([[person objectForKey:@"college"] isEqual:@"Nordmetall"]) {
        college.backgroundColor = RGB(227,211,34);
    }
    else if ([[person objectForKey:@"college"] isEqual:@"Mercator"]) {
        college.backgroundColor = RGB(34,137,227);
    }
    else if ([[person objectForKey:@"college"] isEqual:@"College-III"]) {
        college.backgroundColor = RGB(56,181,25);
    }
    
    
    if ([person objectForKey:@"photo"])
    {
        photo.image = [UIImage imageWithData:[person objectForKey:@"photo"]];
        
        float w = [photo.image size].width;
        float h = [photo.image size].height;
        
        if (w != 96)
        {
            NSLog(@"Resized from: %.2f x %.2f",w,h);
            float k = w/96;
            w = w/k;
            h = h/k;
        }
        
        [photo setFrame:CGRectMake(photo.frame.origin.x, photo.frame.origin.y+(128-h)/2, w,h)];
    }
    else {
        NSLog(@"Downloading image...");
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[person objectForKey:@"photo_url"]]]];
        
        if(image) {
            float w = [image size].width;
            float h = [image size].height;
            
            if (w != 96)
            {
                NSLog(@"Resized from: %2f x %2f",w,h);
                float k = w/96;
                w = w/k;
                h = h/k;
            }
            
            [photo setFrame:CGRectMake(photo.frame.origin.x, photo.frame.origin.y+(128-h)/2, w,h)];
            photo.image = image;
            [person setValue:[NSData dataWithContentsOfURL:[NSURL URLWithString:[person objectForKey:@"photo_url"]]] forKey:@"photo"];
        }
    }
}

-(UIBarButtonItem*) barButtonForExisting:(BOOL)ex {
    
    UIBarButtonItem * barButton;
    
    if (ex) {
        UIButton *a1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [a1 setFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        [a1 addTarget:self action:@selector(addToFavorites:) forControlEvents:UIControlEventTouchUpInside];
        [a1 setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];
        a1.tag = 2;
        
        barButton = [[UIBarButtonItem alloc] initWithCustomView:a1];
    }
    else {
        UIButton *a1 = [UIButton buttonWithType:UIButtonTypeCustom];
        [a1 setFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        [a1 addTarget:self action:@selector(addToFavorites:) forControlEvents:UIControlEventTouchUpInside];
        [a1 setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        a1.tag = 1;
        
        barButton = [[UIBarButtonItem alloc] initWithCustomView:a1];
    }
    
    return barButton;
}

-(IBAction) addToFavorites:(id)sender
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [prefs mutableArrayValueForKey:@"favorites"];
    
    if (((UIButton*)sender).tag == 1)
    {
        [favorites addObject:person];
        self.navigationItem.rightBarButtonItem = [self barButtonForExisting:TRUE];
    }
    else if (((UIButton*)sender).tag == 2)
    {
        //using complicated removal way, because contents of "person" are unpredictable: comparing IDs instead.
        for (NSDictionary *personObject in [prefs objectForKey:@"favorites"])
            if ([[personObject objectForKey:@"eid"] isEqual:[person objectForKey:@"eid"]])
                [favorites removeObject:personObject];
        self.navigationItem.rightBarButtonItem = [self barButtonForExisting:FALSE];
    }
    
    [prefs setObject:favorites forKey:@"favorites"];
    [prefs synchronize];
    
}

-(IBAction) sendEmail:(id)sender
{
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    
    mailer.mailComposeDelegate = self;
    
    NSArray *toRecipients = [NSArray arrayWithObjects:[person objectForKey:@"email"], nil];
    [mailer setToRecipients:toRecipients];
    
    [mailer setSubject:@""];
    [mailer setMessageBody:@"" isHTML:NO];
    
    [self presentModalViewController:mailer animated:YES];
    
}

-(IBAction) call:(id)sender
{
    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] ) {
        
        NSURL *callURL;
        
        if ([[person objectForKey:@"phone"] length] == 4)
            callURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:+49421200%@",[person objectForKey:@"phone"]]];
        else callURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",[person objectForKey:@"phone"]]];
        
        [[UIApplication sharedApplication] openURL:callURL];
        
    } else {
        
        [self.view makeToast:@"Your device doesn't support calling. Sorry :<" duration:2 position:@"bottom"];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
}

@end
