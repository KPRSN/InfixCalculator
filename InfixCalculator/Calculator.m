//
//  Calculator.m
//  InfixCalculator
//
//  Created by Karl Persson on 2014-07-21.
//  Copyright (c) 2014 Karl Persson. All rights reserved.
//

#import "Calculator.h"

// Operation types
// {right parenthesis, subtraction, addition, divition multiplication, left parenthesis}
typedef enum {RIP, SUB, ADD, DIV, MUL, LEP} operatorType;

/*
 * Helper class for handling operators
 */
@interface Operator : NSObject
@property (nonatomic) operatorType type;
+ (Operator *)operatorFromChar:(char)c;
- (NSNumber *)calculate:(NSNumber *)first second:(NSNumber *)second;
@end


/*
 * Calculator
 */
@implementation Calculator
// Execute calculation based on input string
+ (NSNumber *)calculate:(NSString *)calculation
{
	// Infix to postfix
	NSArray *postfix = [self infixToPostfix:calculation];
	// Calculate
	return [self executeCalculation:postfix];
}

// Convert infix expression to postfix
+ (NSArray *)infixToPostfix:(NSString *)infix
{
	NSCharacterSet *operatorCharacters = [NSCharacterSet characterSetWithCharactersInString:@"-+/*()"];
	NSCharacterSet *operandCharacters = [NSCharacterSet characterSetWithCharactersInString:@"1234567890."];
	
	NSMutableArray *postfix = [[NSMutableArray alloc] init];
	NSMutableArray *stack = [[NSMutableArray alloc] init];
	
	// Start conversion
	NSMutableString *operand = [[NSMutableString alloc] init];
	for (int i = 0; i < infix.length; ++i) {
		char c = [infix characterAtIndex:i];
		
		// Save operand
		if (operand.length > 0 && ([operatorCharacters characterIsMember:c] || i == infix.length-1)) {
			[postfix addObject:[NSNumber numberWithDouble:[operand doubleValue]]];
			[operand setString:@""];
		}
		
		// Test character
		if ([operandCharacters characterIsMember:c]) {
			// Operand part
			[operand appendString:[NSString stringWithFormat:@"%c", c]];
		}
		else if ([operatorCharacters characterIsMember:c]) {
			// Operator
			Operator *operator = [Operator operatorFromChar:c];
			
			// Pop stack until lower type is found
			Operator *topOperator = [stack lastObject];
			while (stack.count > 0 && topOperator.type > operator.type) {
				// Stop popping where a complete parenthesis is found
				if (topOperator.type != LEP || operator.type == RIP) {
					[stack removeObject:topOperator];
					
					// Don't add LEP to postfix
					if (topOperator.type != LEP) {
						[postfix addObject:topOperator];
					}
				}
				else break;
				
				topOperator = [stack lastObject];
			}
			
			// Save operator
			if (operator.type != RIP) {
				[stack addObject:operator];
			}
		}
	}
	
	// Pop remaining stack
	for (Operator *operator in [stack reverseObjectEnumerator]) {
		if (operator.type != LEP) {
			[postfix addObject:operator];
		}
	}
	
	return postfix;
}

// Execute postfix calculation
+ (NSNumber *)executeCalculation:(NSArray *)postfix
{
	NSMutableArray *stack = [[NSMutableArray alloc] init];
	
	for (NSString *component in postfix) {
		if ([component isKindOfClass:[NSValue class]]) {
			// Operand
			[stack addObject:component];
		}
		else {
			// Operator
			if (stack.count >= 2) {
				// Pop operands from stack
				NSNumber *second = [stack lastObject];
				[stack removeLastObject];
				NSNumber *first = [stack lastObject];
				[stack removeLastObject];

				// Calculate result and push to stack
				[stack addObject:[(Operator *)component calculate:first second:second]];
			}
			else {
				NSLog(@"ERROR: Not sufficient values!");
			}
		}
	}
	
	// Check result
	if (stack.count == 1) {
		return [stack objectAtIndex:0];
	}
	else {
		NSLog(@"ERROR: Too many values!");
	}
	
	
	return [NSNumber numberWithDouble:0.0f];
}
@end


@implementation Operator
// Create an operator
+ (Operator *)operatorFromChar:(char)c
{
	operatorType type;
	switch (c) {
		case '-':
			type = SUB;
			break;
		case '+':
			type = ADD;
			break;
		case '/':
			type = DIV;
			break;
		case '*':
			type = MUL;
			break;
		case '(':
			type = LEP;
			break;
		case ')':
			type = RIP;
			break;
		default:
			return nil;
	}
	
	// Create operator
	Operator *op = [[Operator alloc] init];
	op.type = type;
	return op;
}

// Calculate with operator
- (NSNumber *)calculate:(NSNumber *)first second:(NSNumber *)second
{
	switch (self.type) {
		case SUB: return [NSNumber numberWithDouble:[first doubleValue] - [second doubleValue]];
		case ADD: return [NSNumber numberWithDouble:[first doubleValue] + [second doubleValue]];
		case DIV: return [NSNumber numberWithDouble:[first doubleValue] / [second doubleValue]];
		case MUL: return [NSNumber numberWithDouble:[first doubleValue] * [second doubleValue]];
		default: return [NSNumber numberWithDouble:0.0f];
	}
}
@end