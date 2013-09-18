//
//  DKCreditsViewController.h
//  jPeople
//
//  Created by Dmitry on 8/15/13.
//  Copyright (c) 2013 Dmitrii Cucleschin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface DKCreditsViewController : UIViewController {
    IBOutlet UIButton* dimaButton;
    IBOutlet UIButton* stefanButton;
    IBOutlet UIButton* nyanButton;
    IBOutlet UIButton* nerdButton;
    
    AVAudioPlayer *nyanPlayer;
    AVAudioPlayer *nerdPlayer;
}

-(IBAction) goDima;
-(IBAction) goStefan;
-(IBAction) playNyanCat;
-(IBAction) playNerd;
@end
