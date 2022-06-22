//
//  LineGeometry.h
//  ARKit_Objc
//
//  Created by Toan Tran on 21/06/2022.
//
#import <SceneKit/SceneKit.h>
#include <vector>
@interface LineGeometry : SCNGeometry
- (SCNGeometry*) lineByVector:(std::vector<SCNVector3>)vector
            sides:(NSMutableArray*)side
            width:(CGFloat)wid
           lengths:(NSMutableArray*)length
        endCapPosition:(CGFloat)position;
@end


