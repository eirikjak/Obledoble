//
//  HelloWorldLayer.h
//   MNBVC
//
//  Created by Ellen Johansen on 3/29/12.
//  Copyright Voksenopplæringen 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
struct Circle{
    CGPoint position;
    float radius;
    
    
};

// HelloWorldLayer
@interface GameLayer: CCLayer
{
    BOOL didAim;
    int triesLeft;
    BOOL hasFired;
    b2Body*cannon;
    b2Body* bullet;
	b2World* world;
	GLESDebugDraw *m_debugDraw;
    Circle* circles;
    NSMutableArray*path;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
// adds a new sprite at a given coordinate
-(void)PathTick:(ccTime)t;
-(void) addNewSpriteWithCoords:(CGPoint)p;
-(void)addNewCircleWitchCoords:(CGPoint)p;
-(void)addCannonAtPoint:(CGPoint)p;
-(void)FireBullet:(float)angle;
-(BOOL)CollisionCheck;
@end
