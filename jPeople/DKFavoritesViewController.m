//
//  DKFavoritesViewController.m
//  jPeople
//
//  Created by Dmitry on 5/6/13.
//  Copyright (c) 2013 Dmitrii Cucleschin. All rights reserved.
//

#import "DKFavoritesViewController.h"


@implementation DKFavoritesViewController

-(void) viewWillAppear:(BOOL)animated {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    favorites = [prefs mutableArrayValueForKey:@"favorites"];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    self.title = @"Favorites";
    
    [super viewDidLoad];
    
    // Left
    UIButton *a1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [a1 setFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [a1 addTarget:self action:@selector(openMenu) forControlEvents:UIControlEventTouchUpInside];
    [a1 setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:a1];
    self.navigationItem.leftBarButtonItem = barButton;
    
    self.navigationItem.hidesBackButton = YES;
    
    // Center    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorites"]];
    
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    favorites = [prefs mutableArrayValueForKey:@"favorites"];

}

-(void) renewData {
    
    if (favorites.count == 0) return;
    
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *fUpdated = [NSMutableArray array];
    
    self.tableView.allowsSelection = NO;
    self.tableView.scrollEnabled = NO;
    
    [self.view makeToastActivity];
    
    int nQ = ([favorites count]+19)/20;
    NSLog(@"%i queries to update the data.",nQ);
    
    [self.view makeToastActivity];
    
    for (int i=0; i<nQ; i++)
    {
        NSString *query = @"http://majestix.gislab.jacobs-university.de/jPeople/ajax.php?action=fullAutoComplete&str=account:";
        
        for (int k = i*20; k < MIN(i*20+20,[favorites count]); k++)
        {
            query = [query stringByAppendingString:[NSString stringWithFormat:@"%@,",[[favorites objectAtIndex:k]objectForKey:@"account"]]];
        }
        
        query = [query substringToIndex:[query length]-1]; // remove the last comma
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:query]];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData* data, NSError* error) {
            
            if (error != nil)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hey hey hey!" message:@"Is somebody chewing on your router's wires? Because you certainly seem to lack Internet connection. Try again later?" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                return;
            }
    
            NSDictionary *jsonRoot = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            for (NSDictionary *person in [jsonRoot objectForKey:@"records"])
            {
                [fUpdated addObject:person];
            }

        }];
        
    }
    
    [self.view hideToastActivity];
    [prefs setObject:fUpdated forKey:@"favorites"];
    [prefs synchronize];
    
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
    
    [self.view hideToastActivity];
    [self.view makeToast:@"Success!" duration:1.5 position:@"bottom"];
    
    [self.tableView reloadData];
}

-(IBAction) openMenu {
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Clear all" otherButtonTitles:@"E-mail all", @"Export to Contacts", @"Update data", nil];
    [menu showFromTabBar:self.tabBarController.tabBar];
}

-(void) allToContacts {
    
    ABAddressBookRef addressBook = ABAddressBookCreate(); // create address book record
    
    for (NSDictionary *dude in favorites) {
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
        
        [self.view hideToastActivity];
    }
    
    ABAddressBookSave(addressBook, nil); //save the records
    NSLog(@"done");
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


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [favorites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    NSDictionary *person = [favorites objectAtIndex:indexPath.row];
    NSLog(@"%@",person);
    
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


#pragma mark - Table view editing

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath {
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableArray *favs = favorites;
    
    NSDictionary *tempPerson = [NSDictionary dictionaryWithDictionary:[favs objectAtIndex:fromIndexPath.row]];
    
    [favs removeObject:[favs objectAtIndex:fromIndexPath.row]];
    [favs insertObject:tempPerson atIndex:toIndexPath.row];
    
    [prefs setObject:favs forKey:@"favorites"];
    [prefs synchronize];
    
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSMutableArray *favs = favorites;
        
        [favs removeObject:[favs objectAtIndex:indexPath.row]];
        
        [prefs setObject:favs forKey:@"favorites"];
        [prefs synchronize];
        
        [self.tableView reloadData];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DKDetailViewController *detail = (DKDetailViewController*) [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"detailView"];
    detail.person = [[favorites objectAtIndex:indexPath.row] mutableCopy];
    
    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark UIActionSheet delegate

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (buttonIndex == 4)
        return;
    
    if (buttonIndex == 0) //clear
    {
        NSMutableArray *empty = [NSMutableArray array];
        [prefs setObject:empty forKey:@"favorites"];
        [prefs synchronize];
        [self.tableView reloadData];
        return;
    }
    
    
    if ([favorites count] > 0)
    {
        if (buttonIndex == 1) //email all
        {
            NSMutableArray *sendTo = [NSMutableArray array];
            
            for (NSDictionary *person in favorites)
                [sendTo addObject:[person objectForKey:@"email"]];
            
            MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
            
            mailer.mailComposeDelegate = self;
            [mailer setSubject:@""];
            
            [mailer setToRecipients:sendTo];
            
            NSString *emailBody = @"";
            [mailer setMessageBody:emailBody isHTML:NO];
            
            [self presentModalViewController:mailer animated:YES];
        }
        
        else if (buttonIndex == 2) //export to contacts
        {
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            [self performSelectorInBackground:@selector(allToContacts) withObject:nil];
            [self.view makeToastActivity];
        }
        
        else if (buttonIndex == 3) //update data
        {
            [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            [self performSelectorInBackground:@selector(renewData) withObject:nil];
            [self.view makeToastActivity];
        }
        
    }
    
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"There are no people in the list right now. Please, add some people before calling group actions." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
}


@end
