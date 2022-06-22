//
//  BiquadFilter.h
//  ARKit_Objc
//
//  Created by Toan Tran on 20/06/2022.
//

#import <Foundation/Foundation.h>
#import <ARKit/ARKit.h>
NS_ASSUME_NONNULL_BEGIN
@class BiquadFilterInstance;
@interface BiquadFilter : NSObject
@property (assign, nonatomic) SCNVector3 val;
@property (strong, nonatomic) NSMutableArray <BiquadFilterInstance *> *inst;
- (instancetype)initWithFc:(double)fc dimensions:(int)dimensions;
- (float)updateFloatIn:(CGFloat)floatIn;
- (SCNVector3)updateVectorIn:(SCNVector3)vectorIn;
@end

@interface BiquadFilterInstance : NSObject{
    double a0, a1, a2, b1, b2;
    double Fc;
    double Q;
    double z1,z2;
}
- (instancetype)initWithFc:(double)fc;
- (float)process:(double)valueIn;

@end

NS_ASSUME_NONNULL_END
