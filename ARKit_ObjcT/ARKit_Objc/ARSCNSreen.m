//
//  ARSCNSreen.m
//  ARKit_Objc
//
//  Created by Toan Tran on 20/06/2022.
//

#import "ARSCNSreen.h"
#import <ARKit/ARKit.h>
#import "Stroke.h"
#import "Constant.h"
#import "LineGeometry.h"

@interface ARSCNSreen ()<ARSCNViewDelegate, ARSessionDelegate>{
    
    // SenceView Configuration
    ARSCNView *scenceView;
    ARWorldTrackingConfiguration *configuration;
    
    // Model Arrow Node
    NSMutableArray<SCNNode*> *objectNode;
    SCNNode *lastNode;
    SCNNode *hitNode;
    
    // Drawing line
    CGPoint touchPoint;
    NSMutableArray<Stroke*> *strokes;
    
    // options tool
    UISwitch *modeTrack;
    UILabel *modeLabel;
    UIButton *reloadBut;
    UISlider *slideWith;
    
    //private variable
    BOOL isNode;
    CGFloat minimumDistance;
    LINE_WIDTH strokeSize;
    ViewMode mode;
}

@end

@implementation ARSCNSreen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self setupSenceView];
    [self setupControlButton];
    [self setupSwitch];
    [self setupSlider];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self configureARSession:false runOptions:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [self resetTouches];
}

#pragma mark - View State.

- (void)initData{
    configuration = [[ARWorldTrackingConfiguration alloc] init];
    objectNode = [[NSMutableArray alloc] init];
    touchPoint = CGPointZero;
    strokes = [[NSMutableArray alloc] init];
    isNode = false;
    minimumDistance = 0.05;
    strokeSize = LINE_WIDTH_Small;
}
- (void)setupSenceView{
    scenceView = [[ARSCNView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:scenceView];
    scenceView.translatesAutoresizingMaskIntoConstraints = false;
    NSArray *contraints = @[
        [scenceView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [scenceView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [scenceView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [scenceView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor]
    ];
    [NSLayoutConstraint activateConstraints:contraints];
    hitNode = [[SCNNode alloc] init];
    hitNode.position = SCNVector3Make(0, 0, -0.2);
    [scenceView.pointOfView addChildNode:hitNode];
    scenceView.autoenablesDefaultLighting = true;
    scenceView.delegate = self;
    scenceView.session.delegate = self;
}
- (void)setupControlButton{
    reloadBut = [[UIButton alloc] init];
    reloadBut.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addSubview:reloadBut];
    [self.view bringSubviewToFront:reloadBut];
    [reloadBut setImage:[UIImage systemImageNamed:@"arrow.clockwise"] forState:UIControlStateNormal];
    reloadBut.tintColor = UIColor.grayColor;
    [reloadBut addTarget:self action:@selector(onClickReload) forControlEvents:UIControlEventTouchUpInside];
    NSArray *contraints = @[
        [reloadBut.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:10],
        [reloadBut.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [reloadBut.heightAnchor constraintEqualToConstant:50],
        [reloadBut.widthAnchor constraintEqualToConstant:50]
    ];
    [NSLayoutConstraint activateConstraints:contraints];
}
- (void)setupSwitch{
    modeLabel = [[UILabel alloc] init];
    modeTrack = [[UISwitch alloc] init];
    [self.view addSubview:modeTrack];
    modeTrack.translatesAutoresizingMaskIntoConstraints = false;
    [modeTrack setOn:false];
    [modeTrack addTarget:self action:@selector(onTapSwitch) forControlEvents:UIControlEventValueChanged];
    
    NSArray *contraints = @[
        [modeTrack.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:25],
        [modeTrack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:30],
        [modeTrack.heightAnchor constraintEqualToConstant:50],
        [modeTrack.widthAnchor constraintEqualToConstant:50]
    ];
    [NSLayoutConstraint activateConstraints:contraints];
    
    [self.view addSubview:modeLabel];
    modeLabel.translatesAutoresizingMaskIntoConstraints = false;
    modeLabel.font = [UIFont boldSystemFontOfSize: 20];
    modeLabel.textColor = [UIColor systemBlueColor];
    [self setDrawing];
    NSArray *contraints1 = @[
        [modeLabel.topAnchor constraintEqualToAnchor:modeTrack.bottomAnchor constant:5],
        [modeLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:30],
        [modeLabel.heightAnchor constraintEqualToConstant:50],
        [modeLabel.widthAnchor constraintEqualToConstant:150]
    ];
    [NSLayoutConstraint activateConstraints:contraints1];
}

- (void)setupSlider{
    slideWith = [[UISlider alloc] init];
    [self.view addSubview:slideWith];
    slideWith.translatesAutoresizingMaskIntoConstraints = false;
    [slideWith addTarget:self action:@selector(onSliderChangeValue) forControlEvents:UIControlEventValueChanged];
    [slideWith setValue:1.0 animated:true];
    [slideWith setTransform:CGAffineTransformMakeRotation(1.5 * M_PI)];
    NSArray *contraints = @[
        [slideWith.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:300],
        [slideWith.leadingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-140],
        [slideWith.heightAnchor constraintEqualToConstant:200],
        [slideWith.widthAnchor constraintEqualToConstant:50]
    ];
    [NSLayoutConstraint activateConstraints:contraints];
}

#pragma mark - Actions.

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    CGPoint touchPoint1 = [self getTouchPoint:touches];
    touchPoint = touchPoint1;
    switch (mode) {
        case OBJECT:
        {
            lastNode = nil;
            ARAnchor *anchor = [self makeAnchor:touchPoint];
            if (anchor) {
                [scenceView.session addAnchor:anchor];
            }
            break;
        }
        case DRAWING:{
            // begin a new stroke
            Stroke *stroke = [[Stroke alloc] initStroke];
            ARAnchor *anchor = [self makeAnchor:touchPoint];
            if (anchor) {
                stroke.anchor = anchor;
                [stroke.points addObject:[NSValue valueWithSCNVector3:SCNVector3Zero]];
                stroke.touchStart = touchPoint;
                stroke.lineWidth = LINE_WIDTH_float(strokeSize);
                
                [strokes addObject:stroke];
                [scenceView.session addAnchor:anchor];
            }
            break;
        }
        default:
            break;
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    NSLog(@"Test1 touchesMoved");
    if (mode == DRAWING) {
        CGPoint touchPoint1 = [self getTouchPoint:touches];
        touchPoint = touchPoint1;
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    NSLog(@"Test1 touchesEnded");
    [self resetTouches];
    [strokes.lastObject resetMemory];
}
- (CGPoint)getTouchPoint:(NSSet<UITouch *> *)touches{
    UITouch *touch = [touches allObjects].firstObject;
    CGPoint point = [touch locationInView:scenceView];
    return point;
}

- (void)onClickReload{
    [self resetScene];
}
- (void)onTapSwitch{
    if (modeTrack.isOn) {
        [self setObject];
    } else {
        [self setDrawing];
    }
}

- (void)onSliderChangeValue{
    NSLog(@"tHIEN vi: %f", slideWith.value);
    SCNNode *node_arm = lastNode;
    SCNAction *action = [SCNAction customActionWithDuration:0 actionBlock:^(SCNNode * _Nonnull node, CGFloat elapsedTime) {
        node.physicsBody = nil;
        node.scale = SCNVector3Make(self->slideWith.value, self->slideWith.value, self->slideWith.value);
    }];
    [node_arm runAction:action];
}

#pragma mark - Node.

- (void)addNode:(SCNNode *)node atPoint:(CGPoint)point{
    ARRaycastQuery *raycastQuery = [scenceView raycastQueryFromPoint:point allowingTarget:ARRaycastTargetEstimatedPlane alignment:ARRaycastTargetAlignmentAny];
    NSArray<ARRaycastResult *> *results = [scenceView.session raycast:raycastQuery];
    if (results.count > 0) {
        node.simdTransform = results.firstObject.worldTransform;
    }
    [self addNodeToParentNode:node toParentNode:scenceView.scene.rootNode];
}
- (void)addNodeToParentNode:(SCNNode *)node toParentNode:(SCNNode *)parentNode{
    SCNNode *clonedNode = [node clone];
    lastNode = clonedNode;
    [objectNode addObject:clonedNode];
    [parentNode addChildNode:clonedNode];
}

- (Stroke *)getStrokeFromAnchor:(ARAnchor *)anchor{
    for (Stroke *stroke in strokes) {
        if (stroke.anchor == anchor) {
            return stroke;
        }
    }
    return nil;
}
//Checks user's strokes for match, then partner's strokes
- (Stroke *)getStrokeFromSCNNode:(SCNNode *)node{
    for (Stroke *stroke in strokes) {
        if (stroke.node == node) {
            return stroke;
        }
    }
    return nil;
}
- (ARAnchor *)makeAnchor:(CGPoint)point{
    
    SCNVector3 offset = [self unprojectedPositionAtBegin:point];
    
    if (offset.x != 0 && offset.y != 0 && offset.z != 0) {
        matrix_float4x4 blankTransform;
        blankTransform.columns[3].x = offset.x;
        blankTransform.columns[3].y = offset.y;
        blankTransform.columns[3].z = offset.z;
        
        return [[ARAnchor alloc] initWithTransform:blankTransform];
    }
    NSLog(@"Can not create anchor");
    return nil;
}
- (void)updateLine:(Stroke *)stroke{
    SCNNode *strokeNode = stroke.node;
    if (stroke.points.lastObject && stroke.node) {
        SCNVector3 offset = [self unprojectedPositionAtBegin:touchPoint];
        SCNVector3 newPoint = [strokeNode convertPosition:offset toNode:scenceView.scene.rootNode];
        stroke.lineWidth = LINE_WIDTH_float(strokeSize);
        if ([stroke add:newPoint]) {
            [self updateGeometry:stroke];
        }
        NSLog(@"Test1 Total Points, %ld", stroke.points.count);
    }
}
- (void)updateGeometry:(Stroke *)stroke{
    if (stroke.positionsVec3.count > 4) {
        NSMutableArray *vectors = stroke.positionsVec3;
        NSArray *sides = stroke.mSide;
        CGFloat width = 0.006;
        NSArray *lengths = stroke.mLength;
        CGFloat totalLength = (stroke.drawnLocally) ? stroke.totalLength : stroke.animatedLength;
        LineGeometry *line = [[LineGeometry alloc] initVectors:vectors sides:sides width:width lengths:lengths endCapPosition:totalLength];
        stroke.node.geometry = line;
    }
}
- (SCNVector3)unprojectedPositionAtBegin:(CGPoint)touch{
    ARRaycastQuery *raycastQuery = [scenceView raycastQueryFromPoint:touch allowingTarget:ARRaycastTargetEstimatedPlane alignment:ARRaycastTargetAlignmentAny];
    NSArray<ARRaycastResult *> *results = [scenceView.session raycast:raycastQuery];
    if (results.count > 0) {
        SCNVector3 projectedOrigin = [scenceView projectPoint:hitNode.worldPosition];
        SCNVector3 offset = [scenceView unprojectPoint:SCNVector3Make(touch.x, touch.y, projectedOrigin.z)];
        return offset;
    }
    return SCNVector3Zero;
}

- (SCNVector3)unprojectedPosition:(CGPoint)touch{
    if (hitNode) {
        SCNVector3 projectedOrigin = [scenceView projectPoint:hitNode.worldPosition];
        SCNVector3 offset = [scenceView unprojectPoint:SCNVector3Make(touch.x, touch.y, projectedOrigin.z)];
        return offset;
    }else{
        return SCNVector3Zero;
    }
}
- (void)clearAllStrokes{
    for (Stroke *stroke in strokes) {
        if (stroke.anchor) {
            [scenceView.session removeAnchor:stroke.anchor];
        }
    }
}

#pragma mark - ARSCNViewDelegate.

- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    NSLog(@"renderer did Add Node");
    isNode = true;
    if ([self isObject]) {
        if (!CGPointEqualToPoint(touchPoint, CGPointZero)) {
            SCNNode *node = [self setNodeModel];
            if (!node) {
                return;
            }
            if (isNode) {
                [self addNode:node atPoint:touchPoint];
            }
        }
    }else{
        ARRaycastQuery *raycastQuery = [scenceView raycastQueryFromPoint:touchPoint allowingTarget:ARRaycastTargetEstimatedPlane alignment:ARRaycastTargetAlignmentAny];
        
        NSArray<ARRaycastResult *> *results = [scenceView.session raycast:raycastQuery];
        if (results.count > 0) {
            node.simdTransform = results.firstObject.worldTransform;
        }
        Stroke *stroke = [self getStrokeFromAnchor:anchor];
        if (stroke) {
            NSLog(@"did add: %f, %f, %f",node.position.x, node.position.y, node.position.z);
            NSLog(@"stroke first position:%@", stroke.points[0]);
            stroke.node = node;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateGeometry:stroke];
            });
        }
    }
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    if ([self isObject]) {
        
    }else{
        Stroke *stroke = [self getStrokeFromAnchor:anchor];
        if (stroke) {
            stroke.node = node;
            if ([strokes containsObject:stroke]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateGeometry:stroke];
                });
            }
        }
    }
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    if ([self isObject]) {

    } else {
        Stroke *stroke = [self getStrokeFromSCNNode:node];
        if (stroke) {
            if ([strokes containsObject:stroke]) {
                NSUInteger index = [strokes indexOfObject:stroke];
                [strokes removeObjectAtIndex:index];
            }
            [stroke cleanup];
        }
        NSLog(@"Stroke removed.  Total strokes=%lu", (unsigned long)strokes.count);
    }
}

- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time{
    if ([self isObject]) {
        
    }else{
        if (!CGPointEqualToPoint(touchPoint, CGPointZero)) {
            if (strokes.lastObject) {
                Stroke *stroke = strokes.lastObject;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self updateLine:stroke];
                });
            }
        }
    }
}

#pragma mark - ARSessionDelegate.
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame{
//    NSLog(@"session: didUpdate");
}
- (void)session:(ARSession *)session didAddAnchors:(NSArray<__kindof ARAnchor *> *)anchors{
    NSLog(@"session: didAdd");
}
- (void)session:(ARSession *)session didUpdateAnchors:(NSArray<__kindof ARAnchor *> *)anchors{
//    NSLog(@"session: didUpdate");
    if (!CGPointEqualToPoint(touchPoint, CGPointZero)) {
//        ARRaycastQuery *raycastQuery = [scenceView raycastQueryFromPoint:touchPoint allowingTarget:ARRaycastTargetEstimatedPlane alignment:ARRaycastTargetAlignmentAny];
//
//        NSArray<ARRaycastResult *> *results = [scenceView.session raycast:raycastQuery];
//        if (results) {
//            ARRaycastResult *result = results.firstObject;
//            AnchorEntity *resultAnchor = [AnchorEntity AnchorEntityw];
//        }
        
    }
}
- (void)session:(ARSession *)session didRemoveAnchors:(NSArray<__kindof ARAnchor *> *)anchors{
    NSLog(@"session: didRemove");
}

#pragma mark Private function.

- (SCNNode *)setNodeModel{
    NSString *name = [resourceFolder stringByAppendingString:@"/arrow1.scn"];
    SCNScene *sence = [SCNScene sceneNamed:name];
    return sence.rootNode;
}

- (void)configureARSession:(BOOL)isReset runOptions:(ARSessionRunOptions)runOptions{
    if (isReset) {
        for (SCNNode *node in objectNode) {
            [node removeFromParentNode];
        }
        [objectNode removeAllObjects];
    }
    configuration.environmentTexturing = AREnvironmentTexturingAutomatic;
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    [scenceView.session runWithConfiguration:configuration options:runOptions];
}

- (void)sencePause{
    [scenceView.session pause];
}

- (void)setMaxValueSlide{
    [slideWith setValue:1.0 animated:true];
}

- (void)resetScene{
    isNode = false;
    [self clearAllStrokes];
    [self resetTouches];
    [self configureARSession:true runOptions:ARSessionRunOptionRemoveExistingAnchors];
    [self dismissViewControllerAnimated:true completion:nil];
}
- (void)resetTouches{
    touchPoint = CGPointZero;
}
- (void)setDrawing{
    NSLog(@"Mode change to Drawing");
    modeLabel.text = @"Drawing";
    mode = DRAWING;
}
- (void)setObject{
    NSLog(@"Mode change to Object Tracking");
    modeLabel.text = @"Object";
    mode = OBJECT;
}
- (BOOL)isObject{
    if (mode == OBJECT) {
        return true;
    }else{
        return false;
    }
}
@end
