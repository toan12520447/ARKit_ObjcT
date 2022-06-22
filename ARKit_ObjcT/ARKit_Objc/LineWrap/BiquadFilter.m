//
//  BiquadFilter.m
//  ARKit_Objc
//
//  Created by Toan Tran on 20/06/2022.
//

#import "BiquadFilter.h"

@implementation BiquadFilter
- (instancetype)initWithFc:(double)fc dimensions:(int)dimensions{
    self = [super init];
    if (!self.inst) {
        self.inst = [[NSMutableArray alloc] init];
    }
    for (int i=0; i<dimensions; i++) {
        BiquadFilterInstance *item = [[BiquadFilterInstance alloc] initWithFc:fc];
        [self.inst addObject:item];
    }
    return self;
}
- (float)updateFloatIn:(CGFloat)floatIn{
    if (self.inst.count == 1) {
        return [self.inst[0] process:floatIn];
    }else{
        NSLog(@"nimation BiquadFilter set up incorrectly");
        return 0;
    }
}
- (SCNVector3)updateVectorIn:(SCNVector3)vectorIn{
    if (self.inst.count == 3) {
        SCNVector3 val = SCNVector3Make(0, 0, 0);
        val.x = [self.inst[0] process:vectorIn.x];
        val.y = [self.inst[0] process:vectorIn.y];
        val.z = [self.inst[0] process:vectorIn.z];
        return val;
    }else{
        NSLog(@"BiquadFilter set up incorrectly");
        return SCNVector3Zero;
    }
}

@end

@implementation BiquadFilterInstance

- (instancetype)initWithFc:(double)fc{
    self = [super init];
    Fc = 0.5;
    Q = 0.707;
    Fc = fc;
    // calcBiquad (in Swift, can't call from init unless all vars are defined first)
    CGFloat K = tan(M_PI * Fc);
    CGFloat norm = 1 / (1 + K / Q + K * K);
    a0 = K * K * norm;
    a1 = 2 * a0;
    a2 = a0;
    b1 = 2 * (K * K - 1) * norm;
    b2 = (1 - K / Q + K * K) * norm;
    return self;
}
- (float)process:(double)valueIn{
    CGFloat out = valueIn * a0 + z1;
    z1 = valueIn * a1 + z2 - b1 * out;
    z2 = valueIn * a2 - b2 * out;
    return out;
}

@end
