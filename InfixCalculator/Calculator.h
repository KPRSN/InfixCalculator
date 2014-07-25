//
//  Calculator.h
//  InfixCalculator
//
//  Created by Karl Persson on 2014-07-21.
//  Copyright (c) 2014 Karl Persson. All rights reserved.
//
//	Calculates a mathematical infix expression.
//	Will handle addition, subtraction, multiplication, division and parenthesis,
//	as well as both integer and floating point operands.

#import <Foundation/Foundation.h>

@interface Calculator : NSObject

// Execute calculation based on input string (infix expression)
+ (NSNumber *)calculate:(NSString *)calculation;

@end
