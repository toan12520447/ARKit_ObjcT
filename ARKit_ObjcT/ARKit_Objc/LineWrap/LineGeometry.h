//
//  LineGeometry.h
//  ARKit_Objc
//
//  Created by Toan Tran on 21/06/2022.
//

#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LineGeometry : SCNGeometry
- (instancetype)initVectors:(NSArray<NSValue*> *)vectors sides:(NSArray *)sides width:(CGFloat)width lengths:(NSArray *)lengths endCapPosition:(CGFloat)endCapPosition;
@end

NS_ASSUME_NONNULL_END
