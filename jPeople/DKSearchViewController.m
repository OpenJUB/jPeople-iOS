//
//  DKSearchViewController.m
//  jPeople
//
//  Created by Dmitry on 5/6/13.
//  Copyright (c) 2013 Dmitrii Cucleschin. All rights reserved.
//

#import "DKSearchViewController.h"

@implementation DKSearchViewController

-(void) viewWillAppear:(BOOL)animated {
    
    if (![self isJacobs]) {
        searchField.hidden = YES;
        background.image = [UIImage imageNamed:@"out_of_jacobs"];
    }
    else if (foundPeople.count == 0) {
        searchField.hidden = NO;
        background.image = [UIImage imageNamed:@"empty_search"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Search"; //Tabbar
    self.navigationItem.title = @"jPeople"; // Navbar
    
    
    // Search bar
    searchField.backgroundImage = [UIImage imageNamed:@"bar"];
    [((UITextField*)[searchField.subviews objectAtIndex:1]) setKeyboardAppearance:UIKeyboardAppearanceAlert];
    
    // Left
    UIButton *a1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [a1 setFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [a1 addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];
    [a1 setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:a1];
    self.navigationItem.leftBarButtonItem = barButton;
    
    self.navigationItem.hidesBackButton = YES;
    
    //Center
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jacobs"]];
    
    foundPeople = [NSMutableArray array];
}

-(IBAction) openMenu {
    [searchField setShowsCancelButton:NO animated:YES];
    [searchField resignFirstResponder];
    
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"E-mail all", @"Add all to favorites", @"Export to Contacts", nil];
    [menu showFromTabBar:self.tabBarController.tabBar];

}

-(BOOL) isJacobs {
    return [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://majestix.gislab.jacobs-university.de"] encoding:NSUTF8StringEncoding error:nil] != nil;
}

-(BOOL) contactExistsWithFirstname:(NSString *)first lastname:(NSString *)last {
    ABAddressBookRef addressbook = ABAddressBookCreate();
    NSArray *allPeople = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(addressbook);
    
    for (int i=0; i<[allPeople count]; i++)
    {
        ABRecordRef contact = (__bridge ABRecordRef)([allPeople objectAtIndex:i]);
        NSString *fContact = (__bridge NSString *)(ABRecordCopyValue(contact, kABPersonFirstNameProperty));
        NSString *lContact = (__bridge NSString *)(ABRecordCopyValue(contact, kABPersonLastNameProperty));
        
        if ([fContact isEqualToString:first] && [lContact isEqualToString:last])
            return TRUE;
    }
    
    return FALSE;
}

-(void) allToFavorites {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favorites = [prefs mutableArrayValueForKey:@"favorites"];
    
    searchResults.allowsSelection = NO;
    searchResults.scrollEnabled = NO;
    
    for (NSDictionary *person in foundPeople) {
        bool exists = FALSE;
        for (NSDictionary *personObject in favorites) {
            if ([[personObject objectForKey:@"eid"] isEqual:[person objectForKey:@"eid"]])
                exists=TRUE;
        }
        
        if (!exists)
            [favorites addObject:person];
    }
    
    [prefs setObject:favorites forKey:@"favorites"];
    [prefs synchronize];
    
    searchResults.allowsSelection = YES;
    searchResults.scrollEnabled = YES;
    [self.view hideToastActivity];
    [self.view makeToast:@"Success!"];
}

-(void) allToContacts {
    
    ABAddressBookRef addressBook = ABAddressBookCreate(); // create address book record
    BOOL exists = FALSE;
    
    for (NSDictionary *dude in foundPeople) {
         [self.view makeToastActivity];
        
        if (![self contactExistsWithFirstname:[dude objectForKey:@"fname"] lastname:[dude objectForKey:@"lname"]]) {
            ABRecordRef person = ABPersonCreate(); // create a person
            
            if ([dude objectForKey:@"phone"] != nil && ![[dude objectForKey:@"phone"] isEqual:[NSNull null]]) {
                NSString *phone = [NSString stringWithFormat:@"+49421200%@",[dude objectForKey:@"phone"]];
                ABMutableMultiValueRef phoneNumberMultiValue =
                ABMultiValueCreateMutable(kABMultiStringPropertyType);
                ABMultiValueAddValueAndLabel(phoneNumberMultiValue ,(__bridge CFTypeRef)(phone),kABPersonPhoneMobileLabel, NULL);
                ABRecordSetValue(person, kABPersonPhoneProperty, phoneNumberMultiValue, nil); // set the phone number property
            }
            
            if ([dude objectForKey:@"room"] != nil && ![[dude objectForKey:@"room"] isEqual:[NSNull null]]) {
                ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
                NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
                [addressDictionary setObject:[NSString stringWithFormat:@"Room %@",[dude objectForKey:@"room"]] forKey:(NSString*)kABPersonAddressStreetKey];
                
                ABMultiValueAddValueAndLabel(address, (__bridge CFDictionaryRef)addressDictionary, kABHomeLabel, NULL);
                ABRecordSetValue(person, kABPersonAddressProperty, address, NULL);
            }
            
            ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFTypeRef)([dude objectForKey:@"fname"]) , nil);
            ABRecordSetValue(person, kABPersonLastNameProperty, (__bridge CFTypeRef)([dude objectForKey:@"lname"]), nil);
            
            ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
            ABMultiValueAddValueAndLabel(multiEmail, (__bridge CFTypeRef)([dude objectForKey:@"email"]), kABHomeLabel, NULL);
            ABRecordSetValue(person, kABPersonEmailProperty, multiEmail, nil);
            
            ABAddressBookAddRecord(addressBook, person, nil); //add the new person to the record
        }
        else {
            exists = TRUE;
        }
        
        [self.view hideToastActivity];
    }
    
    ABAddressBookSave(addressBook, nil); //save the records
    
    if (!exists)
        [self.view makeToast:@"Success!" duration:1.5 position:@"bottom"];
    else
        [self.view makeToast:@"Some contacts already exist and were not added." duration:1.5 position:@"bottom"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (foundPeople.count > 0)
        background.hidden = YES;
    else
        background.hidden = NO;
    
    return [foundPeople count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *person = [foundPeople objectAtIndex:indexPath.row];
    
    UIView *college = [cell viewWithTag:11];
    
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
    
    UIImageView* country = (UIImageView*)[cell viewWithTag:12];
    country.image = [DKCountry iconForCountry:[person objectForKey:@"country"]];
    
    UILabel *name = (UILabel*)[cell viewWithTag:13];
    name.text = [NSString stringWithFormat:@"%@ %@",[person objectForKey:@"fname"],[person objectForKey:@"lname"]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [searchResults deselectRowAtIndexPath:indexPath animated:YES];
    
    [searchField setShowsCancelButton:NO animated:YES];
    [searchField resignFirstResponder];
    
    DKDetailViewController *detail = (DKDetailViewController*) [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"detailView"];
    detail.person = [[foundPeople objectAtIndex:indexPath.row] mutableCopy];
    
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - Search bar delegate

-(void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    searchBar.text=@"";
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    if (searchBar.text.length < 3)
    {
        [self.view makeToast:@"Please, enter more than 3 characters to search." duration:1.5 position:@"bottom"];
        [self searchBarCancelButtonClicked:searchBar];
        return;
    }
    
    [foundPeople removeAllObjects];
    
    NSString *searchQuery = [NSString stringWithFormat:@"http://majestix.gislab.jacobs-university.de/jPeople/ajax.php?action=fullAutoComplete&str=%@",CFURLCreateStringByAddingPercentEscapes(NULL,(__bridge CFStringRef)[searchBar text],NULL,(CFStringRef) @"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8)];
    
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:searchQuery]];
    
    [self.view makeToastActivity];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError *error)  {
        
        [self.view hideToastActivity];
        
        if (error != nil)
        {
            [self.view makeToast:@"Seems like there's a trouble with your Internet connection... Try again later?" duration:1.5 position:@"bottom"];
            [foundPeople removeAllObjects];
            [searchResults reloadData];
            return;
        }
        
        NSDictionary *jsonRoot = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        for (NSDictionary *person in [jsonRoot objectForKey:@"records"])
        {
            [foundPeople addObject:person];
        }
        
        [searchResults reloadData];
        
        if ([foundPeople count] == 0)
            [self.view makeToast:@"No one found :(" duration:1.5 position:@"bottom"];
        
        if ([foundPeople count] == 1)
        {
            [searchBar setShowsCancelButton:NO animated:YES];
            [searchBar resignFirstResponder];
            
            DKDetailViewController *detail = (DKDetailViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"detailView"];
            detail.person = [[foundPeople objectAtIndex:0] mutableCopy];
            
            [self.navigationController pushViewController:detail animated:YES];
        }
    }];
}

#pragma mark - UIActionSheet delegate

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 3)
        return;
    
    if ([foundPeople count] > 0)
    {
        if (buttonIndex == 0) //email all
        {
            NSMutableArray *sendTo = [NSMutableArray array];
            
            for (NSDictionary *person in foundPeople)
                [sendTo addObject:[person objectForKey:@"email"]];
            
            MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
            
            mailer.mailComposeDelegate = self;
            [mailer setSubject:@""];
            
            [mailer setToRecipients:sendTo];
            
            NSString *emailBody = @"";
            [mailer setMessageBody:emailBody isHTML:NO];
            
            [self presentViewController:mailer animated:YES completion:nil];
        }
        
        else if (buttonIndex == 1) //favorites
        {
            [searchResults scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            [self performSelectorInBackground:@selector(allToFavorites) withObject:nil];
            [self.view makeToastActivity];
        }
        
        
        else if (buttonIndex == 2) //export to contacts
        {
            [searchResults scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            [self performSelectorInBackground:@selector(allToContacts) withObject:nil];
            [self.view makeToastActivity];
        }
        
    }
    
    else
    {
        [self.view makeToast:@"There are no people in the list right now. Please, add some people before calling group actions." duration:1.5 position:@"bottom"];
    }
    
}

#pragma mark - Mail controller delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            [self.view makeToast:@"Saved in drafts." duration:1.5 position:@"bottom"];
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            [self.view makeToast:@"Message sent! ;)" duration:1.5 position:@"bottom"];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            [self.view makeToast:@"Sending failed. Maybe Internet problems? :(" duration:1.5 position:@"bottom"];
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
