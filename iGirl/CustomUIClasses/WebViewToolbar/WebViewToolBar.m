

#import "WebViewToolBar.h"

@interface WebViewToolBar ()
@property (retain) UIBarButtonItem* itemRefesh;
@property (retain) UIBarButtonItem* itemBack;
@property (retain) UIBarButtonItem* itemForward;
@property (retain) UIBarButtonItem* spacer1;
@property (retain) UIBarButtonItem* spacer2;
@property (retain) UIBarButtonItem* spacer3;
@property (retain) UIBarButtonItem* spacer4;

-(void) refreshToolBarButtons;

@end

@implementation WebViewToolBar

@synthesize webView = _webView;
@synthesize itemBack, itemRefesh, itemForward, spacer1, spacer2, spacer3, spacer4;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor colorWithRed:91.0 / 255.0 green:91.0 / 255.0 blue:91.0 / 255.0 alpha:0.7];
        self.clearsContextBeforeDrawing = YES;
		self.itemBack = [[UIBarButtonItem alloc]
                         initWithImage:[UIImage imageNamed:@"back.png"]
                         style:UIBarButtonItemStylePlain
                         target:self
                         action:@selector(back)];
        
		self.itemForward = [[UIBarButtonItem alloc]
                            initWithImage:[UIImage imageNamed:@"forward.png"]
                            style:UIBarButtonItemStylePlain
                            target:self
                            action:@selector(forward)];
        
        self.spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        self.spacer1.width = 30;
        
        self.spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        self.spacer3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        self.spacer4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        self.spacer4.width = 30;
		
		[self refreshToolBarItems];
		self.barStyle = UIBarStyleBlackOpaque;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor colorWithRed:91.0 / 255.0 green:91.0 / 255.0 blue:91.0 / 255.0 alpha:0.7];
        self.clearsContextBeforeDrawing = YES;
		self.itemBack = [[UIBarButtonItem alloc] 
					initWithImage:[UIImage imageNamed:@"back.png"]
					style:UIBarButtonItemStylePlain
					target:self 
					action:@selector(back)];

		self.itemForward = [[UIBarButtonItem alloc] 
					   initWithImage:[UIImage imageNamed:@"forward.png"]
					   style:UIBarButtonItemStylePlain
					   target:self 
					   action:@selector(forward)];
        
        self.spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        self.spacer1.width = 30;
        
        self.spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        self.spacer3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        self.spacer4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        self.spacer4.width = 30;
		
		[self refreshToolBarItems];
		self.barStyle = UIBarStyleBlackOpaque;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    // do nothing
}

-(void) refreshToolBarButtons
{
	self.itemForward.enabled = _webView.canGoForward;
	self.itemBack.enabled = _webView.canGoBack;
}

-(void) refreshToolBarItems
{
	[self setItems:[NSArray arrayWithObjects:spacer1, itemBack, spacer2, itemForward, spacer3, itemRefesh, spacer4, nil] animated:FALSE];
	[self refreshToolBarButtons];
}

-(void) setLoadingRequest
{	
	UIActivityIndicatorView* activityInd = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
	activityInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
	[activityInd startAnimating];
	self.itemRefesh = [[UIBarButtonItem alloc] initWithCustomView:activityInd];
	
	[self refreshToolBarItems];
}

-(void) setIdle
{
	self.itemRefesh = [[UIBarButtonItem alloc]
                       initWithImage:[UIImage imageNamed:@"refresh.png"]
                       style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(refresh)];
	[self refreshToolBarItems];
}

-(void) forward
{
	[self.webView goForward];
	[self refreshToolBarButtons];
}

-(void) back
{
	[self.webView goBack];
	[self refreshToolBarButtons];
}

-(void) refresh {
	[self.webView reload];
}

@end
