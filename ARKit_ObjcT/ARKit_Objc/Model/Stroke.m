//
//  Stroke.m
//  ios-ngn-stack
//
//  Created by Toan Tran on 02/06/2022.
//  Copyright © 2022 Softfoundry. All rights reserved.
//

#import "Stroke.h"
#include "math.h"

@implementation Stroke
- (instancetype)initStroke{
    self = [super init];
    self.points = [NSMutableArray new];
    self.drawnLocally = true;
    self.mTaperLookup = [NSMutableArray new];
    self.mTapperPoints = 0;
    self.mTapperSlope = 0;
    self.lineWidth = 0.011;
    self.touchStart = CGPointZero;
    self.mLineWidth = 0;
    self.positionsVec3 = [NSMutableArray new];
    self.mSide = [NSMutableArray new];
    self.mLength = [NSMutableArray new];
    self.smoothingCount = 1500;
    self.biquadFilter = [[BiquadFilter alloc] initWithFc:0.07 dimensions:3];
    self.animationFilter = [[BiquadFilter alloc] initWithFc:0.025 dimensions:1];
    self.totalLength = 0;
    self.animatedLength = 0;
    self.previousPoints = [NSMutableArray new];
    return self;
}
- (int)size{
    return (int)_points.count;
}
- (BOOL)updateAnimatedStroke{
    BOOL renderNeedsUpdate = false;
    if(!self.drawnLocally) {
        CGFloat previousLength = _animatedLength;
        _animatedLength = [_animationFilter updateFloatIn:_totalLength];
        
        if(fabs(_animatedLength - previousLength) > 0.001){
            renderNeedsUpdate = true;
        }
    }
    return renderNeedsUpdate;
}
- (BOOL)add:(SCNVector3)point{
    NSUInteger s = _points.count;
    
    // Filter the point
    SCNVector3 p = [self.biquadFilter updateVectorIn:point];
    
    // Check distance, and only add if moved far enough
    if(s > 0){
        SCNVector3 lastPoint = [_points[s-1] SCNVector3Value];
        CGFloat result = [self distance:point receiver:lastPoint];
        if (result < _lineWidth / 10) {
            return false;
        }
    }
    
    _totalLength += [self distance:[_points[_points.count-1] SCNVector3Value] receiver:p];
    
    
    // Add the point
    [_points addObject:[NSValue valueWithSCNVector3:p]];
    
    
    // Cleanup vertices that are redundant
    if(s > 3) {
        CGFloat angle = [self calculateAngle:(int)s-2];
        // Remove points that have very low angle change
        if (angle < 0.05) {
            [_points removeObjectAtIndex:(s - 2)];
        } else {
            [self subdivideSection:(int)(s - 3) maxAngle:0.3 iteration:0];
        }
    }
    
    [self prepareLine];
    
    return true;
}

- (CGFloat)distance:(SCNVector3)a receiver:(SCNVector3)receiver{
    CGFloat xd = receiver.x - a.x;
    CGFloat yd = receiver.y - a.y;
    CGFloat zd = receiver.z - a.z;
    CGFloat distance = sqrt(xd * xd + yd * yd + zd * zd);
    if (distance < 0){
        return (distance * -1);
    } else {
        return (distance);
    }
}

- (SCNVector3)scaleVec:(SCNVector3)vec factor:(CGFloat)factor{
    CGFloat sX = vec.x * factor;
    CGFloat sY = vec.y * factor;
    CGFloat sZ = vec.z * factor;
    return SCNVector3Make(sX, sY, sZ);
}

- (SCNVector3)addVecs:(SCNVector3)lhs rhs:(SCNVector3)rhs{
    CGFloat x = lhs.x + rhs.x;
    CGFloat y = lhs.y + rhs.y;
    CGFloat z = lhs.z + rhs.z;
    return SCNVector3Make(x, y, z);
}

- (SCNVector3)normalizeVec:(SCNVector3)vec{
    CGFloat x = vec.x;
    CGFloat y = vec.y;
    CGFloat z = vec.z;
    
    CGFloat sqLen = x*x + y*y + z*z;
    CGFloat len = sqrt(sqLen);
    
    // zero-div may occur.
    return SCNVector3Make(x / len, y / len, z / len);
}
- (SCNVector3)subVecs:(SCNVector3)lhs rhs:(SCNVector3)rhs{
    CGFloat x = lhs.x - rhs.x;
    CGFloat y = lhs.y - rhs.y;
    CGFloat z = lhs.z - rhs.z;
    return SCNVector3Make(x, y, z);
}
- (CGFloat)calcAngle:(SCNVector3)n1 n2:(SCNVector3)n2{
    CGFloat xx = n1.y*n2.z - n1.z*n2.y;
    CGFloat yy = n1.z*n2.x - n1.x*n2.z;
    CGFloat zz = n1.x*n2.y - n1.y*n2.x;
    CGFloat cross = sqrt(xx*xx + yy*yy + zz*zz);
    
    CGFloat dot = n1.x*n2.x + n1.y*n2.y + n1.z*n2.z;
    
    return fabs(atan2(cross, dot));
}
- (CGFloat)calculateAngle:(int)index{
    SCNVector3 p1 = [_points[index-1] SCNVector3Value];
    SCNVector3 p2 = [_points[index] SCNVector3Value];
    SCNVector3 p3 = [_points[index+1] SCNVector3Value];
    
    CGFloat x = p2.x - p1.x;
    CGFloat y = p2.y - p1.y;
    CGFloat z = p2.z - p1.z;
    SCNVector3 n1 = SCNVector3Make(x, y, z);
    
    x = p3.x - p2.x;
    y = p3.y - p2.y;
    z = p3.z - p2.z;
    SCNVector3 n2 = SCNVector3Make(x, y, z);
    
    CGFloat xx = n1.y*n2.z - n1.z*n2.y;
    CGFloat yy = n1.z*n2.x - n1.x*n2.z;
    CGFloat zz = n1.x*n2.y - n1.y*n2.x;
    CGFloat cross = sqrt(xx*xx + yy*yy + zz*zz);
    
    CGFloat dot = n1.x*n2.x + n1.y*n2.y + n1.z*n2.z;
    
    return abs(atan2(cross, dot));
}
- (void)subdivideSection:(int)s maxAngle:(CGFloat)maxAngle iteration:(int)iteration{
    if (iteration == 6) {
        return;
    }
    
    SCNVector3 p1 = [_points[s] SCNVector3Value];
    SCNVector3 p2 = [_points[s + 1] SCNVector3Value];
    SCNVector3 p3 = [_points[s + 2] SCNVector3Value];
    
    SCNVector3 n1 = [self subVecs:p2 rhs:p1];
    SCNVector3 n2 = [self subVecs:p3 rhs:p2];
    
    CGFloat angle = [self calcAngle:n1 n2:n2];
    
    
    // If angle is too big, add points
    if(angle > maxAngle){
        
        n1 = [self scaleVec:n1 factor:0.5];
        n2 = [self scaleVec:n2 factor:0.5];
        n1 = [self addVecs:n1 rhs:p1];
        n2 = [self addVecs:n2 rhs:p2];
        
        [_points insertObject:[NSValue valueWithSCNVector3:n1] atIndex: s + 1];
        [_points insertObject:[NSValue valueWithSCNVector3:n2] atIndex: s + 3];
        
        [self subdivideSection:s+2 maxAngle:maxAngle iteration:iteration+1];
        [self subdivideSection:s maxAngle:maxAngle iteration:iteration+1];
    }
}
- (SCNVector3)get:(int)i{
    return [_points[i] SCNVector3Value];
}

- (void)setTapper:(CGFloat)slope numPoints:(int)numPoints{
    if (self.mTapperSlope != slope && numPoints != self.mTapperPoints) {
        self.mTapperSlope = slope;
        self.mTapperPoints = numPoints;
        
        CGFloat v = 1.0;
        for (int i = numPoints - 1; i > 0; i--) {
            v *= self.mTapperSlope;
            self.mTaperLookup[i] = [NSNumber numberWithDouble:v];
        }
    }
}
- (CGFloat)getLineWidth{
    return _lineWidth;
}
- (void)prepareLine{
    [self resetMemory];
    int lineSize = [self size];
    CGFloat mLineWidthMax = [self getLineWidth];
    CGFloat lengthAtPoint = 0;
    if (_totalLength <= 0) {
        for (int i = 1; i<lineSize; i++) {
            _totalLength += [self distance:[_points[i-1] SCNVector3Value] receiver:[_points[i] SCNVector3Value]];
        }
    }
    int ii = 0;
    for (int i = 0; i<lineSize; i++) {
        int iGood = i;
        if (iGood < 0) {
            iGood = 0;
        }
        if (iGood >= lineSize) {
            iGood = lineSize - 1;
        }
        
        int i_m_1 = (iGood - 1) < 0 ? iGood : iGood - 1;
        
        SCNVector3 current = [self get:iGood];
        SCNVector3 previous = [self get:i_m_1];
        if (i < _mTapperPoints) {
            _mLineWidth = mLineWidthMax * [_mTaperLookup[i] floatValue];
        } else if (i > lineSize - _mTapperPoints) {
            _mLineWidth = mLineWidthMax * [_mTaperLookup[lineSize - i] floatValue];
        } else {
            _mLineWidth = [self getLineWidth];
        }
        
        lengthAtPoint += [self distance:previous receiver:current];
//            print("Length so far: \(lengthAtPoint)")
        
        _mLineWidth = MAX(0, MIN(mLineWidthMax, _mLineWidth));
        ii += 1;
        [self setMemory:ii pos:current side:1.0 length:lengthAtPoint];
        ii += 1;
        [self setMemory:ii pos:current side:-1.0 length:lengthAtPoint];
    }
}

- (void)resetMemory{
    [_mSide removeAllObjects];
    [_mLength removeAllObjects];
    _totalLength = 0;
    _mLineWidth = 0;
    [_positionsVec3 removeAllObjects];
}
- (void)setMemory:(int)index pos:(SCNVector3)pos side:(CGFloat)side length:(CGFloat)length{
    [_positionsVec3 addObject:[NSValue valueWithSCNVector3:pos]];
    [_mLength addObject:[NSNumber numberWithFloat:length]];
    [_mSide addObject:[NSNumber numberWithFloat:side]];
}
- (void)cleanup{
    [self resetMemory];
    [_points removeAllObjects];
    [_node removeFromParentNode];
    _node = nil;
    _anchor = nil;
    [_mTaperLookup removeAllObjects];
    _mTapperPoints = 0;
    _mTapperSlope = 0;
    _lineWidth = 0;
    _creatorUid = nil;
    _touchStart = CGPointZero;
}
- (id)copyWithZone{
    Stroke *strokeCopy = [Stroke new];
    strokeCopy.points = _points;
    strokeCopy.mTaperLookup = _mTaperLookup;
    strokeCopy.mTapperPoints = _mTapperPoints;
    strokeCopy.mTapperSlope = _mTapperSlope;
    strokeCopy.lineWidth = _lineWidth;
    strokeCopy.creatorUid = _creatorUid;
    strokeCopy.node = _node;
    strokeCopy.anchor = _anchor;
    strokeCopy.touchStart = _touchStart;
    strokeCopy.mLineWidth = _mLineWidth;
    strokeCopy.mSide = _mSide;
    strokeCopy.mLength = _mLength;

    // strokeCopy.fbReference is not copied
    
    return strokeCopy;
}

@end
