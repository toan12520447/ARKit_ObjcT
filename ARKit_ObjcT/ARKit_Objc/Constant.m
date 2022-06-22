//
//  Constant.m
//  ARKit_Objc
//
//  Created by Toan Tran on 20/06/2022.
//

#import "Constant.h"

@implementation Constant

float LINE_WIDTH_float(LINE_WIDTH width) {
    switch (width) {
        case LINE_WIDTH_Large:
            return 0.020;
        case LINE_WIDTH_Medium:
            return 0.011;
        case LINE_WIDTH_Small:
            return 0.006;
        default: return 0.006;
    }
}
@end
