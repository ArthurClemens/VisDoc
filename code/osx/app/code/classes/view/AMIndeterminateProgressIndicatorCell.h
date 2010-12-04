#import <Cocoa/Cocoa.h>

@interface AMIndeterminateProgressIndicatorCell : NSCell {
	double doubleValue;
	NSTimeInterval animationDelay;
	BOOL displayedWhenStopped;
	BOOL spinning;
	NSColor *color;
	float redComponent;
	float greenComponent;
	float blueComponent;
}

- (NSColor *)color;
- (void)setColor:(NSColor *)value;

- (double)doubleValue;
- (void)setDoubleValue:(double)value;

- (NSTimeInterval)animationDelay;
- (void)setAnimationDelay:(NSTimeInterval)value;

- (BOOL)isDisplayedWhenStopped;
- (void)setDisplayedWhenStopped:(BOOL)value;

- (BOOL)isSpinning;
- (void)setSpinning:(BOOL)value;

@end
