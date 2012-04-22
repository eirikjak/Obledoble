//
//  HelloWorldLayer.mm
//  Obledoble
//
//  Created by Ellen Johansen on 3/29/12.
//  Copyright Voksenopplæringen 2012. All rights reserved.
//


// Import the interfaces
#import "GameLayer.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32
#define ARC4RANDOM_MAX 0x100000000 -1
#define BULLET_RADIUS  0.2*PTM_RATIO
#define PATH_DOT_WIDTH 2
// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};


//typedef struct circle circle;
// HelloWorldLayer implementation
@implementation GameLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
    
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = NO;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
		
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, 0.0f);
		triesLeft = 3;
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		
		world->SetContinuousPhysics(true);
		
		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		world->SetDebugDraw(m_debugDraw);
		
		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
//		flags += b2DebugDraw::e_jointBit;
//		flags += b2DebugDraw::e_aabbBit;
//		flags += b2DebugDraw::e_pairBit;
//		flags += b2DebugDraw::e_centerOfMassBit;
		m_debugDraw->SetFlags(flags);		
		
		
		// Define the ground body.
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(0, 0); // bottom-left corner
		
		// Call the body factory which allocates memory for the ground body
		// from a pool and creates the ground box shape (also from a pool).
		// The body is also added to the world.
		b2Body* groundBody = world->CreateBody(&groundBodyDef);
		
		// Define the ground box shape.
		b2PolygonShape groundBox;		
		
		// bottom
		groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
		groundBody->CreateFixture(&groundBox,0);
		
		// top
		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO));
		groundBody->CreateFixture(&groundBox,0);
		
		// left
		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
		groundBody->CreateFixture(&groundBox,0);
		
		// right
		groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
		groundBody->CreateFixture(&groundBox,0);
		
        
		//Set up sprite
        [self addCannonAtPoint:ccp(screenSize.width/2,0)];
		CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:150];
        
		[self addChild:batch z:0 tag:kTagBatchNode];
		srand(time(NULL));
		int CircleCount = ((float)rand()/RAND_MAX)*10;
        CircleCount = 10;
        
        circles = new Circle[(int)CircleCount];

        for (int i =0; i<CircleCount;i++) {
            
            float xpos = ((float)rand()/RAND_MAX)*screenSize.width;
            float ypos = ((float)rand()/RAND_MAX)*screenSize.height;
            float radius = ((float)rand()/RAND_MAX)*50 + 10;
            Circle someCircle;
            someCircle.radius = radius;
            someCircle.position = ccp(xpos,ypos);
            circles[i] = someCircle;
         
        }
        
		[self schedule: @selector(tick:)];
       
	}
	return self;
}
-(void)PathTick:(ccTime)t{
    
    
    CGPoint dot = ccp(bullet->GetPosition().x*PTM_RATIO,bullet->GetPosition().y*PTM_RATIO);
    [path addObject:[NSValue valueWithCGPoint:dot]];
    
    

}
-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);

	world->DrawDebugData();
	for (int i = 0;i< sizeof(circles);i++) {
        Circle someCircle = circles[i];
        ccDrawCircle(someCircle.position, someCircle.radius, 0, 30, YES);
        
    }
    if(path != nil){
    for (NSValue* p in path) {
        CGPoint point = [p CGPointValue];
        ccDrawCircle(point, PATH_DOT_WIDTH, 0, 10, YES);
    }
    }
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}
-(void)addNewCircleWitchCoords:(CGPoint)p{
    b2BodyDef bodyDef;
	bodyDef.type = b2_staticBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
    
	b2CircleShape circle;
    circle.m_radius = 1.0f;
	
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &circle;	
	
    fixtureDef.restitution = 0.0f;
	fixtureDef.friction = 0.0f;
	body->CreateFixture(&fixtureDef);

    
}
-(void)addCannonAtPoint:(CGPoint)p{
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    
    bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    b2Body*body = world->CreateBody(&bodyDef);
    
    b2CircleShape circle;
    circle.m_radius = 1.0f;
    b2PolygonShape tube;
   
    b2Vec2 vec = b2Vec2(0.0,1.0f);
    tube.SetAsBox(0.3f, 0.7f, vec, 0.0f);
    b2FixtureDef fixture1;
    fixture1.shape = &circle;
    b2FixtureDef fixture2;
    fixture2.shape = &tube;
    
    body->CreateFixture(&fixture1);
    body->CreateFixture(&fixture2);
    cannon = body;
   
    
}
-(void) addNewSpriteWithCoords:(CGPoint)p
{
	CCSpriteBatchNode *batch = (CCSpriteBatchNode*) [self getChildByTag:kTagBatchNode];
	
	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
	//just randomly picking one of the images
	int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
	CCSprite *sprite = [CCSprite spriteWithBatchNode:batch rect:CGRectMake(32 * idx,32 * idy,32,32)];
	[batch addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;

	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	bodyDef.userData = sprite;
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
}



-(void) tick: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
    
	world->Step(dt, velocityIterations, positionIterations);
    
    if([self CollisionCheck]){
        
        hasFired = NO;
        world->DestroyBody(bullet);
        bullet = NULL;
        [self unschedule:@selector(PathTick:)];
        
        int len = [path count] -1;
        int index = (rand()/RAND_MAX)*len;
        
        [path release];
        path = nil;

    };
   
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
}

-(BOOL)CollisionCheck{
    if (bullet != NULL) {
        
    
    for (int i = 0; i<sizeof(circles); i++) {
        Circle somecircle = circles[i];
        float radius = somecircle.radius;
        if (radius < BULLET_RADIUS) {
            radius = BULLET_RADIUS;
        }
        if ((abs(somecircle.position.x - bullet->GetPosition().x*PTM_RATIO) <= radius)
            && (abs(somecircle.position.y - bullet->GetPosition().y*PTM_RATIO )<= radius)) {
                        
            return YES;
            
        }
    }
        }
    return NO;
}
-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    didAim = NO;
    CCLOG(@"began");
    
}
-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    didAim = YES;
    UITouch*touch = [[touches allObjects]objectAtIndex:0];
    CGPoint location =  [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
   b2Vec2 vec =  cannon->GetWorldCenter();
    float dx = location.x - vec.x*PTM_RATIO;
    float dy = location.y - vec.y*PTM_RATIO;
 
    
    if (dx<0) {
        cannon->SetTransform(vec,atanf(dy/dx) + 3.14/2);
   

    }else{
        cannon->SetTransform(vec,atanf(dy/dx)- 3.14/2);

    }
   
        
}
-(void)FireBullet:(float)angle{

    
    
    float maxForce = 3;
    float dx = cos(angle + 3.14/2);
    float dy = sin(angle + 3.14/2);
    b2BodyDef bodydef;
    bodydef.type = b2_dynamicBody;
   
    bodydef.position.Set(cannon->GetPosition().x + 1.5*dx,cannon->GetPosition().y+ 1.5*dy);
    b2Body*body = world->CreateBody(&bodydef);
    b2CircleShape _bullet;
    _bullet.m_radius = BULLET_RADIUS/PTM_RATIO;
    b2FixtureDef fixture;
    fixture.shape = &_bullet;
    fixture.density = 1.0f;
    fixture.friction = 0.0f;
    fixture.restitution = 1.0f;
    body->CreateFixture(&fixture);
    body->ApplyLinearImpulse(b2Vec2(dx*maxForce,dy*maxForce), body->GetWorldCenter());
    bullet = body;
    
    if (path !=nil) {
        [path release];
        path = nil;
    }
    triesLeft--;
    hasFired = YES;
    path = [[NSMutableArray alloc] init];
        [self schedule:@selector(PathTick:) interval:0.1];
    
    
}
-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!didAim && triesLeft>0 && !hasFired) {
        [self FireBullet:cannon->GetAngle()];
        
    }}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	
	delete m_debugDraw;

	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
