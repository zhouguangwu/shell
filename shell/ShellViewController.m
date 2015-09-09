//
//  ShellViewController.m
//  Utils
//
//  Created by wayos-ios on 10/13/14.
//  Copyright (c) 2014 webuser. All rights reserved.
//

#import "ShellViewController.h"
#import "Shell.h"
@interface ShellViewController (){
    IBOutlet UITextField *_inField;
    IBOutlet UITextView *_outTextView;
}

@end

@implementation ShellViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"uid:%u",getuid());
    system("ls > /tmp/t");
}

- (IBAction)_hideKeyboard:(id)sender{
    [_inField resignFirstResponder];
}

- (IBAction)_pwd{
    _outTextView.text = [Shell pwd];
}

- (IBAction)_test:(id)sender{

}

- (IBAction)_cd:(id)sender{
    NSAssert(_inField.text.length > 0, @"长度为空");
    NSLog(@"%d",[Shell cd:_inField.text]);
}

- (IBAction)_ls:(id)sender{
    if (_inField.text.length > 0) {
        _outTextView.text = [[Shell ls:_inField.text] description];
    }else{
        _outTextView.text = [[Shell ls] description];
    }
}

- (IBAction)_cat:(id)sender{
    _outTextView.text = [Shell cat:_inField.text];
}

- (IBAction)_ps:(id)sender{
    _outTextView.text = [[Shell ps] description];
}

- (IBAction)_mkdir:(id)sender{
    NSLog(@"mkdir是否成功 %d",[Shell mkdir:_inField.text]);
}

- (IBAction)_rmdir:(id)sender{
    NSLog(@"rmdir是否成功%d",[Shell rmdir:_inField.text]);
}

- (IBAction)_uname:(id)sender{
    _outTextView.text = [Shell uname];
}

- (IBAction)_chmod:(id)sender{//被阉割, mac是可以的
    [Shell chmod:_inField.text];
}

- (IBAction)_touch:(id)sender{
    [Shell touch:_inField.text];
}

- (IBAction)_rm:(id)sender{
    [Shell rm:_inField.text];
}

- (IBAction)_write:(id)sender{
    [Shell writeTo:_inField.text content:@"eeeeee"];
}

- (IBAction)_exec:(id)sender{
    _outTextView.text = [Shell exec:_inField.text];
}

- (IBAction)_ping:(id)sender{
    NSLog(@"%d",[Shell ping:_inField.text]);
}

- (IBAction)_route:(id)sender{
    _outTextView.text = [Shell route];
}

- (IBAction)_arp:(id)sender{
    _outTextView.text = [[Shell arp] description];
}

- (IBAction)_df:(id)sender{
    _outTextView.text = [Shell df];
}

- (IBAction)_top:(id)sender{
    _outTextView.text = [Shell top];
}
@end
