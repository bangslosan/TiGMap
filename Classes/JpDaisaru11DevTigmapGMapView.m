//
//  JpDaisaru11DevGMapView.m
//  tigmap
//
//  Created by 酒井 大地 on 2013/02/23.
//
//

#import "JpDaisaru11DevTigmapGMapView.h"
#import "JpDaisaru11DevTigmapGMapAnnotationProxy.h"

@implementation JpDaisaru11DevTigmapGMapView

#pragma mark Internal

-(id)init
{
    if (self = [super init]) {
		_location = CLLocationCoordinate2DMake(0,0);
		_zoom = 0;
		_rendered = NO;
		_animate = YES;
    }
    return self;
}

- (void)dealloc
{
    if (_map!=nil)
    {
        _map.delegate = nil;
		RELEASE_TO_NIL(_map);
	}
	[super dealloc];
}

- (GMSMapView *) map
{
	if (_map==nil)
	{
		NSLog(@"initialize map");

		_map = [[GMSMapView alloc] initWithFrame:self.bounds];
		//NSLog(@"map retainCount:%d",[_map retainCount]);
		_map.myLocationEnabled = YES;
        _map.delegate = self;

		[self addSubview:_map];
	}

	return _map;
}

-(void)render
{
	if (![NSThread isMainThread]) {
		TiThreadPerformOnMainThread(^{[self render];}, NO);
		return;
	}

	if (!_rendered || !_animate) {
		GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:_location zoom:16];
		[_map setCamera: camera];
		_rendered = YES;
	} else {
		[_map animateToLocation:_location];
		[_map animateToZoom: _zoom];
	}
	// no animation
	//GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.8683
	//longitude:151.2086
	//zoom:6];
}

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
	[TiUtils setView:[self map] positionRect:bounds];
	[super frameSizeChanged:frame bounds:bounds];
	//NSLog(@"framesizechanged latitude: %f, longitude: %f", _location.latitude, _location.longitude);
	[self render];
}

#pragma mark Public APIs

-(void)setLocation_:(id)location
{
	ENSURE_SINGLE_ARG(location,NSDictionary);
    ENSURE_UI_THREAD(setLocation_,location)
	id lat = [location objectForKey:@"latitude"];
	id lon = [location objectForKey:@"longitude"];
	if (lat)
	{
		_location.latitude = [lat doubleValue];
	}
	if (lon)
	{
		_location.longitude = [lon doubleValue];
	}
	//id an = [location objectForKey:@"animate"];
	//if (an)
	//{
	//	animate = [an boolValue];
	//}
	NSLog(@"latitude: %f, longitude: %f", _location.latitude, _location.longitude);
	[self render];
}

-(void)setZoom_:(id)zoom
{
	ENSURE_SINGLE_ARG(zoom,NSObject);
	ENSURE_UI_THREAD(setZoom_,zoom);

	_zoom = [TiUtils floatValue:zoom];

	NSLog(@"zoom: %f", _zoom);
	[self render];
}

-(void)setAnimate_:(id)animate
{
	ENSURE_SINGLE_ARG(animate,NSObject);
	_animate = [TiUtils boolValue:animate];
}

-(void)addAnnotation:(id)arg
{
	ENSURE_SINGLE_ARG(arg,NSObject);
	ENSURE_UI_THREAD(addAnnotation,arg);

	JpDaisaru11DevTigmapGMapAnnotationProxy* annProxy = arg;
	[annProxy addToMap:[self map]];
}

-(void)removeAnnotation:(id)arg
{
	ENSURE_SINGLE_ARG(arg,NSObject);
	ENSURE_UI_THREAD(removeAnnotation,arg);

	JpDaisaru11DevTigmapGMapAnnotationProxy *annProxy = arg;
	[annProxy removeFromMap:[self map]];
}

#pragma mark Delegates

- (void)mapView:(GMSMapView *)mapView
    didChangeCameraPosition:(GMSCameraPosition *)position
{
	if ([self.proxy _hasListeners:@"cameraPositionChanged"]) // listener name is too long?
	{
		NSDictionary *target = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithDouble:position.target.latitude],@"latitude",
			[NSNumber numberWithDouble:position.target.longitude],@"longitude",
			nil];
		NSDictionary *props = [NSDictionary dictionaryWithObjectsAndKeys:
			@"cameraPositionChanged",@"type",
			target,@"target",
			[NSNumber numberWithDouble:position.zoom],@"zoom",
			[NSNumber numberWithDouble:position.bearing],@"bearing",
			[NSNumber numberWithDouble:position.viewingAngle],@"bearing",
			nil];
		[self.proxy fireEvent:@"cameraPositionChanged" withObject:props];
	}
}

- (void)mapView:(GMSMapView *)mapView
    didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
	if ([self.proxy _hasListeners:@"click"])
	{
		NSDictionary * props = [NSDictionary dictionaryWithObjectsAndKeys:
			@"click",@"type",
			[NSNumber numberWithDouble:coordinate.latitude],@"latitude",
			[NSNumber numberWithDouble:coordinate.longitude],@"longitude",
			nil];
		[self.proxy fireEvent:@"click" withObject:props];
	}
}

- (void)mapView:(GMSMapView *)mapView
    didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
	if ([self.proxy _hasListeners:@"longpress"])
	{
		NSDictionary * props = [NSDictionary dictionaryWithObjectsAndKeys:
			@"longpress",@"type",
			[NSNumber numberWithDouble:coordinate.latitude],@"latitude",
			[NSNumber numberWithDouble:coordinate.longitude],@"longitude",
			nil];
		[self.proxy fireEvent:@"longpress" withObject:props];
	}
}
-(void)recognizedLongPress:(UILongPressGestureRecognizer*)recognizer
{
	// ignore the event by recognized in TiUIView
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(id<GMSMarker>)marker
{
}

- (void)mapView:(GMSMapView *)mapView
    didTapInfoWindowOfMarker:(id<GMSMarker>)marker
{
}


- (UIView *)mapView:(GMSMapView *)mapView
    markerInfoWindow:(id<GMSMarker>)marker
{
}





@end
