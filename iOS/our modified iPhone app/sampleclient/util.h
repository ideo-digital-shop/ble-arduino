//
//  util.h
//
//  Created by Mel He on 4/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef intuit_p3_util_h
#define intuit_p3_util_h



#import <QuartzCore/QuartzCore.h>


#pragma mark - debug setup


#pragma mark - colors


#define COLOUR_RGB_A(r255, g255, b255, a)  \
[UIColor colorWithRed:((r255)/255.0) green:((g255)/255.0) blue:((b255)/255.0) alpha:(a)]


#define COLOUR_GRAYSCALE_A(g255, a)  \
COLOUR_RGB_A((g255), (g255), (g255), a)


#pragma mark - animation parameters


#define ANIMATION_DURATION_SECONDS 0.25


#pragma mark - debug message


#if defined (DEBUG)
#define DLog(s,...) NSLog(@"%s %d: "s, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DLog(s,...)
#endif


#pragma mark - check view layout


#if defined (DEBUG)
#define WIRE_FRAME_UIVIEW(UIViewObjectID, UIColorID)                                     \
{                                                                                        \
(UIViewObjectID).backgroundColor = [(UIColorID) colorWithAlphaComponent:0.4];        \
(UIViewObjectID).layer.borderWidth = 1;                                              \
(UIViewObjectID).layer.cornerRadius = 12;                                            \
(UIViewObjectID).layer.borderColor = [(UIColorID) CGColor];                          \
DLog("%@: orig(%.0f, %0.f) size(%.0f, %.0f)",                                        \
[[(UIViewObjectID) class] description],                                         \
(UIViewObjectID).frame.origin.x, (UIViewObjectID).frame.origin.y,               \
(UIViewObjectID).frame.size.width, (UIViewObjectID).frame.size.height);         \
UILabel *frameLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200/2, 60/2)]; \
frameLable.backgroundColor = [UIColor darkGrayColor];                                \
frameLable.alpha = 0.7;                                                              \
frameLable.numberOfLines = 2;                                                        \
frameLable.font = [UIFont boldSystemFontOfSize:20/2];                                \
frameLable.textColor = [UIColor whiteColor];                                         \
frameLable.text = [NSString stringWithFormat:@"(%.0f, %.0f)\n%@",                    \
(UIViewObjectID).frame.size.width,                                \
(UIViewObjectID).frame.size.height,                               \
[[(UIViewObjectID) class] description]];                          \
[(UIViewObjectID) addSubview:frameLable];                                            \
[frameLable release];                                                                \
}
#else
#define WIRE_FRAME_UIVIEW(UIViewObjectID, UIColorID)                                     \
{}
#endif


#if defined (DEBUG)
#define PRINT_FRAME(UIViewObjectID)                                                      \
{                                                                                        \
DLog("frame: orig(%.0f, %.0f) size(%.0f, %.0f)",                                     \
(UIViewObjectID).frame.origin.x, (UIViewObjectID).frame.origin.y,                    \
(UIViewObjectID).frame.size.width, (UIViewObjectID).frame.size.height);              \
}
#else
#define PRINT_FRAME(UIViewObjectID)                                                      \
{}
#endif


#if defined (DEBUG)
#define PRINT_BOUNDS(UIViewObjectID)                                                     \
{                                                                                        \
DLog("bounds: orig(%.0f, %.0f) size(%.0f, %.0f)",                                    \
(UIViewObjectID).bounds.origin.x, (UIViewObjectID).bounds.origin.y,                  \
(UIViewObjectID).bounds.size.width, (UIViewObjectID).bounds.size.height);            \
}
#else
#define PRINT_BOUNDS(UIViewObjectID)                                                     \
{}
#endif


#if defined (DEBUG)
#define PRINT_RECT(CGRectRef)                                                            \
{                                                                                        \
DLog("rect: orig(%.0f, %.0f) size(%.0f, %.0f)",                                      \
(CGRectRef).origin.x, (CGRectRef).origin.y,                                          \
(CGRectRef).size.width, (CGRectRef).size.height);                                    \
}
#else
#define PRINT_RECT(CGRectRef)                                                            \
{}
#endif


#pragma mark - resources


#pragma mark - sizes


#pragma mark - times


#pragma mark - tags




#endif
