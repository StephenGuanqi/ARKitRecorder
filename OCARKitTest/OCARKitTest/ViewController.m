//
//  ViewController.m
//  OCARKitTest
//
//  Created by Guanqi Yu on 29/6/17.
//  Copyright © 2017 Guanqi Yu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <ARSCNViewDelegate, ARSessionDelegate>
{
    NSMutableDictionary *dict;
    NSString *recordTime;
    enum RecordingState {Recording, NotRecording};
    enum RecordingState currentState;
    enum RecordingState previousState;
    ARFrameHandler* handler;
}
@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@end

    
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set the view's delegate
    self.sceneView.delegate = self;
    self.sceneView.session.delegate = self;
    
    // Show statistics such as fps and timing information
    self.sceneView.showsStatistics = YES;
    
    //other scenceView configuration
    self.sceneView.preferredFramesPerSecond = 30;
    self.sceneView.automaticallyUpdatesLighting = false;
    // Create a new scene
//    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
    
    // Set the scene to the view
//    self.sceneView.scene = scene;
    dict = [NSMutableDictionary new];
    currentState = NotRecording;
    previousState = NotRecording;
    handler = [[ARFrameHandler alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Create a session configuration
    ARWorldTrackingSessionConfiguration *configuration = [ARWorldTrackingSessionConfiguration new];
   
    // Run the view's session
    [self.sceneView.session runWithConfiguration:configuration];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - ARSCNViewDelegate

/*
// Override to create and configure nodes for anchors added to the view's session.
- (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
    SCNNode *node = [SCNNode new];
 
    // Add geometry to the node...
 
    return node;
}
*/

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}

- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame {
    if (_recordButton.state & UIControlStateHighlighted) {
        currentState = Recording;
        //set the name of folder to save images and json to be the button pressed time
        if (recordTime == NULL) {
            recordTime = [handler getCurrentTime];
        }
        [handler parse:frame toJsonObject:dict andSaveInto:recordTime];
        //the button is not pressed and the previous state is recording state
        //which means the button is released
    } else if (previousState == Recording) {
        NSLog(@"state into not highlighter");
        currentState = NotRecording;
        [handler saveAndClear:dict toDir:recordTime];
        recordTime = NULL;
    }
    //update recording state per frame update
    previousState = currentState;
}

@end
