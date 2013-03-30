//
//  CreateMessageViewController.m
//  iReddit
//
//  Created by Alejandro Paredes Alva on 3/29/13.
//
//

#import "CreateMessage.h"

@interface CreateMessage ()
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSString *captchaID;
@property (nonatomic, retain) UIImage  *captchaImage;
@end

@implementation CreateMessage

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _subject = nil;
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://www.reddit.com/api/new_captcha"]];
        [request setHTTPBody:[@"api_type=json" dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPMethod:@"POST"];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
        if (connection) {
            _receivedData = [[NSMutableData data] retain];
        } else {
            NSLog(@"Error");
        }

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 //   _toLabel.layer.borderColor = [[UIColor lightGrayColor] CGColor];
 //   _toLabel.layer.borderWidth = 1.0f;
    _subjectLabel.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _subjectLabel.layer.borderWidth = 1.0f;
    NSLog(@"11111%@",_subject);
    if (_subject) {
        [_subjectField setText:_subject];
//        _subjectField.text = _subject;
    }
    
    _toField.text = _to;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:60.0/255.0 green:120.0/255.0 blue:225.0/255.0 alpha:1.0];
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)]];

    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(send:)]];

}
-(void)send:(id)sender {
    GIDAAlertView *gav = [[GIDAAlertView alloc] initWithImage:_captchaImage andPrompt:@"" cancelButtonTitle:@"cancel" acceptButtonTitle:@"accept"];
    [gav setColor:[UIColor colorWithRed:60.0/255.0 green:120.0/255.0 blue:225.0/255.0 alpha:1.0]];
    [gav setDelegate:self];
    [gav show];
         //
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
   // [_receivedData setLength:0];
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    id dict = [NSJSONSerialization JSONObjectWithData:_receivedData options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"%@",dict);
    if ([dict isKindOfClass:[NSDictionary class]]) {
        _captchaID = [dict[@"json"][@"data"][@"iden"] retain];
        _captchaImage = [[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.reddit.com/captcha/%@.png",_captchaID]]]] retain];
    }
}
-(void)alertOnClicked:(GIDAAlertView *)alertView {
    if ([alertView accepted]) {
    NSArray *array = [NSArray arrayWithObjects:_toField.text, _subjectField.text, _body.text, _captchaID, [alertView enteredText], nil];
        NSLog(@"%@",array);
        [self.delegate composeController:self didSendFields:array];
    }
}
-(void)cancel:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_toLabel release];
    [_subjectLabel release];
    [_subjectField release];
    [_toField release];
    [_body release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setToLabel:nil];
    [self setSubjectLabel:nil];
    [self setSubjectField:nil];
    [self setToField:nil];
    [self setBody:nil];
    [super viewDidUnload];
}
@end