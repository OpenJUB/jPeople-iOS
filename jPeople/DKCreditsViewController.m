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

- (void)viewDidLoad
{
    self.title = @"Credits";
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    // Center
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glasses"]];
    
    // Move buttons if iPhone 5
    if (IS_WIDESCREEN) {
        MOVE(dimaButton,0,39);
        MOVE(stefanButton,0,39);
        MOVE(nyanButton,0,39);
        MOVE(nerdButton,0,39);
    }
    
    // Easter eggs
    nyanPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"nyan" ofType:@"m4a"]] error:nil];
    [nyanPlayer prepareToPlay];
    
    nerdPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"nerd" ofType:@"m4a"]] error:nil];
    [nerdPlayer prepareToPlay];

}

-(IBAction) goDima {

    NSString *json = @"{\"sanitize\":\"dmitrii\",\"parse\":{\"ambiguous\":[\"dmitrii\"],\"strict\":[]},\"length\":1,\"clause\":\" (query LIKE '%dmitrii%')\",\"records\":[{\"id\":\"1377\",\"eid\":\"31479\",\"employeetype\":\"student\",\"attributes\":\"Student\",\"account\":\"dcucleschi\",\"fname\":\"Dmitrii\",\"lname\":\"Cucleschin\",\"birthday\":\"\",\"country\":\"Moldova\",\"college\":\"Krupp\",\"majorlong\":\"Computer Science\",\"majorinfo\":\"ug 15 CS\",\"major\":\"CS\",\"status\":\"undergrad\",\"year\":\"15\",\"room\":\"KA-124\",\"phone\":\"5040\",\"email\":\"d.cucleschin@jacobs-university.de\",\"description\":\"ug 15 CS\",\"title\":\"\",\"office\":\"\",\"deptinfo\":\"\",\"block\":\"A\",\"floor\":\"1\",\"photo_url\":\"http://swebtst01.public.jacobs-university.de/jPeople/image.php?id=31479\",\"flag_url\":\"http://swebtst01.public.jacobs-university.de/jPeople/embed_assets/flags/Moldova.png\",\"flag_small_url\":\"http://majestix.gislab.jacobs-university.de/jPeople/images/flags/Moldova.png\"}]}";
    NSDictionary *jsonRoot = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    
    NSMutableDictionary *dima = [[[jsonRoot objectForKey:@"records"] objectAtIndex:0] mutableCopy];
    [dima setObject:UIImagePNGRepresentation([UIImage imageNamed:@"dimaPic"]) forKey:@"photo"];
    
    DKDetailViewController *detail = (DKDetailViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"detailView"];
    detail.person = dima;

    [self.navigationController pushViewController:detail animated:YES];
}

-(IBAction) goStefan {
    
    NSString *json = @"{\"sanitize\":\"mirea\",\"parse\":{\"ambiguous\":[\"mirea\"],\"strict\":[]},\"length\":1,\"clause\":\" (query LIKE '%mirea%')\",\"records\":[{\"id\":\"61\",\"eid\":\"16862\",\"employeetype\":\"student\",\"attributes\":\"Student\",\"account\":\"smirea\",\"fname\":\"Stefan\",\"lname\":\"Mirea\",\"birthday\":\"\",\"country\":\"Romania\",\"college\":\"Mercator\",\"majorlong\":\"Computer Science\",\"majorinfo\":\"ug 13 CS\",\"major\":\"CS\",\"status\":\"undergrad\",\"year\":\"13\",\"room\":\"MC-108\",\"phone\":\"5450\",\"email\":\"s.mirea@jacobs-university.de\",\"description\":\"ug 13 CS\",\"title\":\"\",\"office\":\"\",\"deptinfo\":\"\",\"block\":\"C\",\"floor\":\"1\",\"photo_url\":\"http://swebtst01.public.jacobs-university.de/jPeople/image.php?id=16862\",\"flag_url\":\"http://swebtst01.public.jacobs-university.de/jPeople/embed_assets/flags/Romania.png\",\"flag_small_url\":\"http://majestix.gislab.jacobs-university.de/jPeople/images/flags/Romania.png\"}]}";
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
    }
}

-(IBAction) playNerd {
    NSLog(@"NEEEEEEEERD!");
    
    if (!nerdPlayer.isPlaying && !nyanPlayer.isPlaying) {
        [nerdPlayer play];
    }
}

@end
