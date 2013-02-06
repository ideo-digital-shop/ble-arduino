

#import <UIKit/UIKit.h>
#import "nBlue.h"
#import "GenericDevice.h"


@interface ViewController : UIViewController <nBlueDelegate>{
    NSUInteger _currentMode;
    GenericDevice *_d;
    nBlue *_nb;
}
@property (strong, nonatomic) IBOutlet UIButton *buttonChangeMode;

@property (strong, nonatomic) GenericDevice *d;                    


@end
