#import <UIKit/UIKit.h>

// 1. 自定义一个悬浮窗类
@interface MomoFloatingWindow : UIWindow
@property (nonatomic, strong) UIButton *button;
@end

@implementation MomoFloatingWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 设置层级极高，保证在状态栏和常规页面之上
        self.windowLevel = 2000;
        self.backgroundColor = [UIColor clearColor];
        
        // 创建圆形的蓝色按钮
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.frame = self.bounds;
        self.button.backgroundColor = [UIColor systemBlueColor];
        self.button.layer.cornerRadius = frame.size.width / 2;
        [self.button setTitle:@"M" forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.button.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        
        // 加点阴影
        self.button.layer.shadowColor = [UIColor blackColor].CGColor;
        self.button.layer.shadowOffset = CGSizeMake(0, 2);
        self.button.layer.shadowOpacity = 0.4;
        self.button.layer.shadowRadius = 4;
        
        // 绑定点击事件和拖动手势
        [self.button addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self.button addGestureRecognizer:pan];
        
        [self addSubview:self.button];
    }
    return self;
}

- (void)buttonClicked {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Momo 助手"
                                                                   message:@"你点击了悬浮按钮！"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    [self.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self];
    CGPoint newCenter = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (newCenter.x >= 25 && newCenter.x <= screenSize.width - 25 &&
        newCenter.y >= 40 && newCenter.y <= screenSize.height - 40) {
        self.center = newCenter;
    }
    [pan setTranslation:CGPointZero inView:self];
}
@end

// 2. 全局变量持有这个 Window
static MomoFloatingWindow *momoWindow = nil;

%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundleID isEqualToString:@"com.wemomo.momoappdemo1"]) {
        if (!momoWindow) {
            // 在屏幕左上角 (20, 150) 创建一个 50x50 的悬浮窗
            momoWindow = [[MomoFloatingWindow alloc] initWithFrame:CGRectMake(20, 150, 50, 50)];
            momoWindow.rootViewController = [[UIViewController alloc] init];
            momoWindow.hidden = NO; // 显示窗口
        }
    }
}
%end