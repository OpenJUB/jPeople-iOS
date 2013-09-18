//
//  DKCreditsViewController.m
//  jPeople
//
//  Created by Dmitry on 8/15/13.
//  Copyright (c) 2013 Dmitrii Cucleschin. All rights reserved.
//

#import "DKCreditsViewController.h"
#import "DKDetailViewController.h"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define MOVE(obj,dx,dy) obj.frame=CGRectMake(obj.frame.origin.x+dx,obj.frame.origin.y+dy,obj.frame.size.width,obj.frame.size.height)

@implementation DKCreditsViewController

-(void) viewWillUnload {
    [ALAlertBanner hideAllAlertBanners];
    [super viewWillUnload];
}

- (void)viewDidLoad
{
    self.title = @"Credits";
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    /*//Swipe between tabs
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tappedRightButton:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tappedLeftButton:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipeRight];*/
    
    // Center
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glasses"]];
    
    // Move buttons if iPhone 5
    if (IS_WIDESCREEN) {
        NSLog(@"Widescreen: moving buttons.");
        MOVE(dimaButton,0,39);
        MOVE(stefanButton,0,39);
        MOVE(nyanButton,0,39);
        MOVE(nerdButton,0,39);
    }
}

-(void) viewDidAppear:(BOOL)animated {
    
    // Easter eggs
    nyanPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"nyan" ofType:@"m4a"]] error:nil];
    nerdPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"nerd" ofType:@"m4a"]] error:nil];
    
    [nyanPlayer prepareToPlay];
    [nerdPlayer prepareToPlay];
}

-(IBAction) goDima {

    NSString *json = @"{\"sanitize\":\"dmitrii\",\"parse\":{\"ambiguous\":[\"dmitrii\"],\"strict\":[]},\"length\":1,\"clause\":\" (query LIKE '%dmitrii%')\",\"records\":[{\"id\":\"1553\",\"eid\":\"31479\",\"employeetype\":\"student\",\"attributes\":\"Student\",\"account\":\"dcucleschi\",\"fname\":\"Dmitrii\",\"lname\":\"Cucleschin\",\"birthday\":\"\",\"country\":\"Moldova\",\"college\":\"Krupp\",\"majorlong\":\"Computer Science\",\"majorinfo\":\"ug 15 CS\",\"major\":\"CS\",\"status\":\"undergrad\",\"year\":\"15\",\"room\":\"KC-316\",\"phone\":\"5192\",\"email\":\"d.cucleschin@jacobs-university.de\",\"description\":\"ug 15 CS\",\"title\":\"\",\"office\":\"\",\"deptinfo\":\"\",\"block\":\"C\",\"floor\":\"3\",\"photo_url\":\"http://188.26.116.4:8082/jpeople/utils/images/31479.jpg\",\"flag_url\":\"http://swebtst01.public.jacobs-university.de/jPeople/embed_assets/flags/Moldova.png\",\"flag_small_url\":\"http://188.26.116.4:8082/jpeople/images/flags/Moldova.png\"}]}";
    
    NSDictionary *jsonRoot = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    NSMutableDictionary *dima = [[[jsonRoot objectForKey:@"records"] objectAtIndex:0] mutableCopy];
    [dima setObject:UIImagePNGRepresentation([UIImage imageNamed:@"dimaPic"]) forKey:@"photo"];
    
    DKDetailViewController *detail = (DKDetailViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"detailView"];
    detail.person = dima;

    [self.navigationController pushViewController:detail animated:YES];
}

-(IBAction) goStefan {
    
    NSString *json = @"{\"sanitize\":\"mirea\",\"parse\":{\"ambiguous\":[\"mirea\"],\"strict\":[]},\"length\":1,\"clause\":\" (query LIKE '%mirea%')\",\"records\":[{\"id\":\"61\",\"eid\":\"16862\",\"employeetype\":\"student\",\"attributes\":\"Student\",\"account\":\"smirea\",\"fname\":\"Stefan\",\"lname\":\"Mirea\",\"birthday\":\"\",\"country\":\"Romania\",\"college\":\"\",\"majorlong\":\"Computer Science\",\"majorinfo\":\"ug 13 CS\",\"major\":\"CS\",\"status\":\"undergrad\",\"year\":\"13\",\"room\":\"\",\"phone\":\"\",\"email\":\"steven.mirea@gmail.com\",\"description\":\"CS Geek and Sensei '13\",\"title\":\"\",\"office\":\"\",\"deptinfo\":\"\",\"block\":\"\",\"floor\":\"\",\"photo_url\":\"http://swebtst01.public.jacobs-university.de/jPeople/image.php?id=16862\",\"flag_url\":\"http://swebtst01.public.jacobs-university.de/jPeople/embed_assets/flags/Romania.png\",\"flag_small_url\":\"http://majestix.gislab.jacobs-university.de/jPeople/images/flags/Romania.png\"}]}";
    NSDictionary *jsonRoot = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    NSMutableDictionary *stefan = [[[jsonRoot objectForKey:@"records"] objectAtIndex:0] mutableCopy];
    [stefan setObject:UIImagePNGRepresentation([UIImage imageNamed:@"stefanPic"]) forKey:@"photo"];
    
    DKDetailViewController *detail = (DKDetailViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"detailView"];
    detail.person = stefan;
    
    [self.navigationController pushViewController:detail animated:YES];
}

-(IBAction) playNyanCat {
    NSLog(@"NYAN TIME! :3");
    
    if (!nyanPlayer.isPlaying && !nerdPlayer.isPlaying) {
        [nyanPlayer play];
        ALAlertBanner* banner = [ALAlertBanner alertBannerForView:self.view style:ALAlertBannerStyleNotify position:ALAlertBannerPositionTop title:@"IT'S NYAAAAN TIME!!! %)" subtitle:nil];
        [banner show];
    }
}

-(IBAction) playNerd {
    NSLog(@"NEEEEEEEERD!");
    
    if (!nerdPlayer.isPlaying && !nyanPlayer.isPlaying) {
        [nerdPlayer play];
    }
}

- (IBAction)tappedRightButton:(id)sender
{
    int selectedIndex = [self.tabBarController selectedIndex];
    
    if (selectedIndex + 1 >= [[self.tabBarController viewControllers] count]) {
        return;
    }
    
    /*
     UIView * fromView = self.view;
    UIView * toView = [[self.tabBarController.viewControllers objectAtIndex:selectedIndex+1] view];
    
    // Transition using a page curl.
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    completion:^(BOOL finished) {
                        if (finished) {
                            self.tabBarController.selectedIndex = selectedIndex+1;
                        }
                    }];
     */

    self.tabBarController.selectedIndex = selectedIndex+1;
}

- (IBAction)tappedLeftButton:(id)sender
{
    int selectedIndex = [self.tabBarController selectedIndex];
    
    if (selectedIndex - 1 < 0) {
        return;
    }
    
    /*
     UIView * fromView = self.view;
    UIView * toView = [[self.tabBarController.viewControllers objectAtIndex:selectedIndex-1] view];
    
    // Transition using a page curl.
    [UIView transitionFromView:fromView
                        toView:toView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    completion:^(BOOL finished) {
                        if (finished) {
                            self.tabBarController.selectedIndex = selectedIndex-1;
                        }
                    }];
     */

    self.tabBarController.selectedIndex = selectedIndex-1;
}

@end
