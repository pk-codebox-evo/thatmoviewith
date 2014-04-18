//
//  TMWCustomAnimations.h
//  ThatMovieWith
//
//  Created by johnrhickey on 4/17/14.
//  Copyright (c) 2014 Jay Hickey. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface TMWCustomAnimations : CABasicAnimation

+ (CABasicAnimation *)ringBorderWidthAnimation;
+ (CABasicAnimation *)actorOpacityAnimation;
+ (CABasicAnimation *)buttonOpacityAnimation;

@end
