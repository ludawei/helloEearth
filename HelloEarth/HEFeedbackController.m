//
//  HEFeedbackController.m
//  HelloEarth
//
//  Created by 卢大维 on 15/9/10.
//  Copyright (c) 2015年 weather. All rights reserved.
//

#import "HEFeedbackController.h"
#import "Masonry.h"
#import <MessageUI/MessageUI.h>
#import "CWHttpCmdFeedback.h"
#import "MBProgressHUD+Extra.h"
#import "Util.h"

#define FEEDBACK_EMAILBOX @"****@***"

@interface HEFeedbackController ()<UITextViewDelegate, UITextFieldDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic,strong) UILabel *tipLabel;
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) UITextField *textField;

@end

@implementation HEFeedbackController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"意见反馈";
    UIButton *leftNavButton = [Util leftNavButtonWithSize:CGSizeMake(self.navigationController.navigationBar.height, self.navigationController.navigationBar.height)];
    [leftNavButton addTarget:self action:@selector(clickBack) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftNavButton];
    
    [self initViews];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // 键盘出现消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHidden:) name: UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    //    [self.navigationController setNavigationBarHidden:YES];
    [self exitKeyboard];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// 键盘出现的消息
- (void)keyboardWillShow:(NSNotification *)notification
{
    // 下面这句很重要,UIKeyboardFrameEndUserInfoKey这个属性很关键
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat appFrameHeight;
    CGFloat keyboardFrameHeight;
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
        appFrameHeight = [[UIScreen mainScreen] bounds].size.height;
        keyboardFrameHeight = keyboardRect.size.height;
    }
    else
    {
        appFrameHeight = [[UIScreen mainScreen] bounds].size.width;
        keyboardFrameHeight = keyboardRect.size.width;
    }
    CGFloat keyboardPosY = appFrameHeight - keyboardFrameHeight;
    
    //如果当前的文本框被键盘挡住
    if (CGRectGetMaxY(self.textField.frame) > keyboardPosY) //64为状态栏高度+文本框高度
    {
//        [self.view layoutIfNeeded];
        //设置view的origin
        CGRect rect = self.view.frame;
        CGFloat upOffset;
        
        upOffset = 0 - (CGRectGetMaxY(self.textField.frame) - keyboardPosY)-10;
        if (upOffset > 0)
        {
            upOffset = 0;
        }
        rect.origin.y = upOffset;
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = rect;
        }];
    }
    
    
//    keyBoardShowing = YES;
}

-(void)keyboardWillHidden:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    self.view.frame = rect;
    
//    keyBoardShowing = NO;
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initViews
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor colorWithRed:0.188 green:0.212 blue:0.259 alpha:1];
    
    UIButton *emailButton = [UIButton new];
    emailButton.layer.borderColor = UIColorFromRGB(0x28a7e1).CGColor;
    emailButton.layer.borderWidth = 1;
    emailButton.layer.cornerRadius = 35/2.0;
    emailButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    emailButton.titleLabel.font = [Util modifySystemFontWithSize:16];
    [emailButton setTitle:[NSString stringWithFormat:@"     或发送邮件到:%@     ", FEEDBACK_EMAILBOX] forState:UIControlStateNormal];
    [self.view addSubview:emailButton];
    [emailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_topLayoutGuide).offset(20);
        make.height.mas_equalTo(35);
    }];
    [emailButton sizeToFit];
    [emailButton addTarget:self action:@selector(clickEmailButton) forControlEvents:UIControlEventTouchUpInside];
    
    UIFont *font = [Util modifySystemFontWithSize:17];
    
    self.textView = [UITextView new];
    self.textView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
    self.textView.delegate = self;
    self.textView.layer.cornerRadius = 8;
    self.textView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.textView.layer.borderWidth = 0.8;
    self.textView.textColor = [UIColor whiteColor];
    self.textView.font = font;
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(emailButton.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.88);
        make.height.mas_equalTo(150);
    }];
    
    self.tipLabel = [UILabel new];
    self.tipLabel.textColor = UIColorFromRGB(0xadadad);
    self.tipLabel.numberOfLines = 0;
    self.tipLabel.text = @"您的意见，是我们前进的动力，我们会不断的改善产品，非常感谢！";
    self.tipLabel.font = font;
    [self.view addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textView).offset(7);
        make.left.mas_equalTo(self.textView).offset(5);
        make.right.mas_equalTo(self.textView).offset(-5);
    }];
    [self.tipLabel sizeToFit];
    
    self.textField = [UITextField new];
    self.textField.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
    self.textField.layer.cornerRadius = 5;
    self.textField.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.textField.layer.borderWidth = 0.8;
    self.textField.delegate = self;
    self.textField.font = font;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.textColor = [UIColor whiteColor];
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"您的电话或者邮箱" attributes:@{ NSForegroundColorAttributeName : UIColorFromRGB(0xadadad)}];
    self.textField.attributedPlaceholder = str;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
    self.textField.leftView = leftView;
    self.textField.leftViewMode = UITextFieldViewModeAlways;
    
    [self.view addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textView.mas_bottom).offset(10);
        make.left.right.mas_equalTo(self.textView);
        make.height.mas_equalTo(40);
    }];
    
    UIButton *button = [UIButton new];
    button.layer.cornerRadius = 35/2.0;
    button.clipsToBounds = YES;
    [button setBackgroundImage:[Util createImageWithColor:UIColorFromRGB(0x28a7e1) width:1 height:1] forState:UIControlStateNormal];
    [button setTitle:@"提交" forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textField.mas_bottom).offset(25);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(self.view).multipliedBy(0.3);
        make.height.mas_equalTo(38);
    }];
    [button addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    
    [emailButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.textView);
    }];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    self.tipLabel.hidden = textView.text.length > 0;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self exitKeyboard];
}

-(void)exitKeyboard
{
    [self.textView resignFirstResponder];
    [self.textField resignFirstResponder];
}

-(void)clickEmailButton
{
    // 邮件服务器
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    // 设置邮件代理
    [mailCompose setMailComposeDelegate:self];
    
    // 设置邮件主题
    [mailCompose setSubject:@"蓝π蚂蚁-意见反馈"];
    
    // 设置收件人
    [mailCompose setToRecipients:@[FEEDBACK_EMAILBOX]];
    
    // 弹出邮件发送视图
    [self presentViewController:mailCompose animated:YES completion:nil];
}

-(void)clickButton
{
    [self.textView resignFirstResponder];
    [self.textField resignFirstResponder];
    if ([self.textField.text length] == 0) {
        [MBProgressHUD showHUDNoteWithText:@"填写电话或邮箱"];
        return;
    }
    if ([self.textView.text length] == 0) {
        [MBProgressHUD showHUDNoteWithText:@"没有内容!"];
        return;
    }
    // 提交
    CWHttpCmdFeedback *cmd = [CWHttpCmdFeedback cmd];
    cmd.content = self.textView.text;
    if ([self.textField.text rangeOfString:@"@"].location == NSNotFound) {
        cmd.tel = self.textField.text;
    }
    else
    {
        cmd.email = self.textField.text;
    }
    [cmd setSuccess:^(id object){
        [MBProgressHUD showHUDNoteWithText:@"感谢您的尊贵建议!"];
        [self clickBack];
    }];
    [cmd setFail:^(AFHTTPRequestOperation *response){
        [MBProgressHUD showHUDNoteWithText:@"出了点问题，稍后再试试吧"];
    }];
    [cmd startRequest];
}

-(void)clickBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled: // 用户取消编辑
            LOG(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved: // 用户保存邮件
            LOG(@"Mail saved...");
            break;
        case MFMailComposeResultSent: // 用户点击发送
            LOG(@"Mail sent...");
            break;
        case MFMailComposeResultFailed: // 用户尝试保存或发送邮件失败
            LOG(@"Mail send errored: %@...", [error localizedDescription]);
            break;
    }
    
    // 关闭邮件发送视图
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
