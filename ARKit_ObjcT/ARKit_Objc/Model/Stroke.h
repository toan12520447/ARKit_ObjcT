//
//  Stroke.h
//  ios-ngn-stack
//
//  Created by Toan Tran on 02/06/2022.
//  Copyright © 2022 Softfoundry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ARKit/ARKit.h>
#import "BiquadFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface Stroke : NSObject
@property (strong, nonatomic) NSMutableArray<NSValue *> *points;
@property (assign, nonatomic) BOOL drawnLocally;
@property (strong, nonatomic) NSMutableArray *mTaperLookup;
@property (assign, nonatomic) int mTapperPoints;
@property (assign, nonatomic) float mTapperSlope;
@property (assign, nonatomic) int lineWidth;
@property (strong, nonatomic) ARAnchor *anchor;
@property (strong, nonatomic) SCNNode *node;
@property (assign, nonatomic) CGPoint touchStart;
@property (assign, nonatomic) CGFloat mLineWidth;
@property (strong, nonatomic) NSMutableArray *positionsVec3;
@property (strong, nonatomic) NSMutableArray *mSide;
@property (strong, nonatomic) NSMutableArray *mLength;
@property (assign, nonatomic) CGFloat smoothingCount;
@property (strong, nonatomic) BiquadFilter *biquadFilter;
@property (strong, nonatomic) BiquadFilter *animationFilter;
@property (assign, nonatomic) CGFloat totalLength;
@property (assign, nonatomic) CGFloat animatedLength;
@property (strong, nonatomic) NSString *creatorUid;
@property (strong, nonatomic) NSMutableArray *previousPoints;
- (instancetype)initStroke;
- (int)size;
- (BOOL)updateAnimatedStroke;
- (BOOL)add:(SCNVector3)point;
- (SCNVector3)scaleVec:(SCNVector3)vec factor:(CGFloat)factor;
- (SCNVector3)addVecs:(SCNVector3)lhs rhs:(SCNVector3)rhs;
- (SCNVector3)normalizeVec:(SCNVector3)vec;
- (SCNVector3)subVecs:(SCNVector3)lhs rhs:(SCNVector3)rhs;
- (CGFloat)calcAngle:(SCNVector3)n1 n2:(SCNVector3)n2;
- (CGFloat)calculateAngle:(int)index;
- (void)subdivideSection:(int)s maxAngle:(CGFloat)maxAngle iteration:(int)iteration;
- (SCNVector3)get:(int)i;
- (void)setTapper:(CGFloat)slope numPoints:(int)numPoints;
- (CGFloat)getLineWidth;
- (void)prepareLine;
- (void)resetMemory;
- (void)setMemory:(int)index pos:(SCNVector3)pos side:(CGFloat)side length:(CGFloat)length;
- (void) cleanup;
- (id)copyWithZone;
@end

NS_ASSUME_NONNULL_END
