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

#define FEEDBACK_EMAILBOX @"****@***"

@interface HEFeedbackController ()<UITextViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic,strong) UILabel *tipLabel;
@property (nonatomic,strong) UITextView *textView;
@property (nonatomic,strong) UITextField *textField;

@end

@implementation HEFeedbackController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"意见反馈";
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"返回"] style:UIBarButtonItemStyleDone target:self action:@selector(clickBack)];
    self.navigationItem.leftBarButtonItem = left;
    [self initViews];
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
    emailButton.layer.cornerRadius = 35/2.0;
    emailButton.backgroundColor = [UIColor colorWithRed:0.298 green:0.302 blue:0.306 alpha:1];
    [emailButton setTitle:[NSString stringWithFormat:@"  或发送邮件到:%@  ", FEEDBACK_EMAILBOX] forState:UIControlStateNormal];
    [self.view addSubview:emailButton];
    [emailButton mas_makeConstraints:^(MASConstraintMaker *make) {
        UIView *top = (UIView *)self.topLayoutGuide;
        make.top.mas_equalTo(top.mas_bottom).offset(20);
        make.height.mas_equalTo(35);
    }];
    [emailButton sizeToFit];
    [emailButton addTarget:self action:@selector(clickEmailButton) forControlEvents:UIControlEventTouchUpInside];
    
    self.textView = [UITextView new];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.delegate = self;
    self.textView.layer.cornerRadius = 8;
    self.textView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.textView.layer.borderWidth = 0.8;
    self.textView.textColor = [UIColor lightGrayColor];
    self.textView.font = [UIFont systemFontOfSize:18];
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.mas_equalTo(emailButton.mas_bottom).offset(20);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(self.view.mas_width).multipliedBy(0.88);
        make.height.mas_equalTo(150);
    }];
    
    self.tipLabel = [UILabel new];
    self.tipLabel.textColor = [UIColor darkGrayColor];
    self.tipLabel.numberOfLines = 0;
    self.tipLabel.text = @"您的意见，是我们前进的动力，我们会不断的改善产品，非常感谢！";
    self.tipLabel.font = self.textView.font;
    [self.view addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self.textView).offset(5);
        make.right.mas_equalTo(self.textView).offset(-5);
    }];
    [self.tipLabel sizeToFit];
    
    self.textField = [UITextField new];
    self.textField.layer.cornerRadius = 5;
    self.textField.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.textField.layer.borderWidth = 0.8;
    self.textField.textColor = [UIColor lightGrayColor];
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"您的电话或者邮箱" attributes:@{ NSForegroundColorAttributeName : [UIColor darkGrayColor] }];
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
    button.backgroundColor = [UIColor colorWithRed:0.298 green:0.302 blue:0.306 alpha:1];
    [button setTitle:@"提交" forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textField.mas_bottom).offset(25);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(self.view).multipliedBy(0.8);
        make.height.mas_equalTo(35);
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

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
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
    // 提交
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
