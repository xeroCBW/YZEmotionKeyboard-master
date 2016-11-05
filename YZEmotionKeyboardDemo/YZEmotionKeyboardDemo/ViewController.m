//
//  ViewController.m
//  YZEmotionKeyboardDemo
//
//  Created by yz on 16/8/6.
//  Copyright © 2016年 yz. All rights reserved.
//

#import "ViewController.h"
#import "YZInputView.h"
#import "UITextView+YZEmotion.h"
#import "YZTextAttachment.h"

@interface ViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet YZInputView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHCons;
@property (strong, nonatomic) YZEmotionKeyboard *emotionKeyboard;
@property (weak, nonatomic) IBOutlet UILabel *testLabel;

@end

@implementation ViewController

//=======微信的表情键盘输入表情后,只会显示[微笑];不会显示文本的
//qq 

// 懒加载键盘
- (YZEmotionKeyboard *)emotionKeyboard
{
    // 创建表情键盘
    if (_emotionKeyboard == nil) {
        
        YZEmotionKeyboard *emotionKeyboard = [YZEmotionKeyboard emotionKeyboard];
        
        emotionKeyboard.sendContent = ^(NSString *content){
            // 点击发送会调用，自动把文本框内容返回给你
            
            NSLog(@"%@",content);
            
        };
        
        _emotionKeyboard = emotionKeyboard;
    }
    return _emotionKeyboard;
}

- (IBAction)clickEmtionKeyboard:(UIButton *)sender {
    
    if (_textView.inputView == nil)
    {
        _textView.yz_emotionKeyboard = self.emotionKeyboard;
        [sender setBackgroundImage:[UIImage imageNamed:@"toolbar-text"] forState:UIControlStateNormal];
    }
    else
    {
        //普通键盘---切换键盘时候才会调用
        _textView.inputView = nil;
        [_textView reloadInputViews];
        [sender setBackgroundImage:[UIImage imageNamed:@"smail"] forState:UIControlStateNormal];
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];

    
    // 监听键盘弹出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    // 设置文本框占位文字
    _textView.placeholder = @"cbw";
    _textView.placeholderColor = [UIColor redColor];
    
    _textView.delegate = self;
    
    
    // 监听文本框文字高度改变
    _textView.yz_textHeightChangeBlock = ^(NSString *text,CGFloat textHeight){
        // 文本框文字高度改变会自动执行这个【block】，可以在这【修改底部View的高度】
        // 设置底部条的高度 = 文字高度 + textView距离上下间距约束
        // 为什么添加10 ？（10 = 底部View距离上（5）底部View距离下（5）间距总和）
        _bottomHCons.constant = textHeight + 10;
    };
    
    // 设置文本框最大行数
    _textView.maxNumberOfLines = 4;
}

-  (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

// 键盘弹出会调用
- (void)keyboardWillChangeFrame:(NSNotification *)note
{
    // 获取键盘frame
    CGRect endFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 获取键盘弹出时长
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    // 修改底部视图距离底部的间距
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    _bottomCons.constant = endFrame.origin.y != screenH? endFrame.size.height:0;
    
    // 约束动画
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - delegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        
        NSLog(@"textView按下 return 的文本===%@",[self emotionTextWithTextView:textView]);
        
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}


- (NSString *)emotionTextWithTextView:(UITextView *)textView
{
    
    NSMutableString *strM = [NSMutableString string];
    
    [textView.attributedText enumerateAttributesInRange:NSMakeRange(0, textView.attributedText.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        NSString *str = nil;
        
        YZTextAttachment *attachment = attrs[@"NSAttachment"];
        
        if (attachment) { // 表情
            str = attachment.emotionStr;
            [strM appendString:str];
        } else { // 文字
            str = [textView.attributedText.string substringWithRange:range];
            [strM appendString:str];
        }
        
    }];
    return strM;
}


@end
