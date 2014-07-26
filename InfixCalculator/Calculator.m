//
//  Calculator.m
//  InfixCalculator
//
//  Created by Karl Persson on 2014-07-21.
//  Copyright (c) 2014 Karl Persson. All rights reserved.
//

#import "Calculator.h"

// Operation types
// {right parenthesis, subtraction, addition, divition multiplication, unary subtraction, left parenthesis}
typedef enum {RIP, SUB, ADD, DIV, MUL, LEP, USU} operatorType;

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
	// Split infix
	NSArray *infix = [self splitInfixCalculation:calculation];
	// Infix to postfix
	NSArray *postfix = [self infixToPostfix:infix];
	// Calculate
	return [self executeCalculation:postfix];
}

// Split infix calculation into operators and operands
+ (NSArray *)splitInfixCalculation:(NSString *)calculation
{
	NSCharacterSet *operatorCharacters = [NSCharacterSet characterSetWithCharactersInString:@"-+/*()"];
	NSCharacterSet *operandCharacters = [NSCharacterSet characterSetWithCharactersInString:@"1234567890."];
	
	NSMutableArray *result = [[NSMutableArray alloc] init];
	NSMutableString *operand = [[NSMutableString alloc] init];
	for (int i = 0; i < calculation.length; ++i) {
		char c = [calculation characterAtIndex:i];
		
		if ([operatorCharacters characterIsMember:c]) {
			// Operator
			// Save buffered operand
			if (operand.length > 0) {
				[result addObject:[NSNumber numberWithDouble:[operand doubleValue]]];
				[operand setString:@""];
			}
			
			Operator *op = [Operator operatorFromChar:c];
			
			// Unary check
			// Operator is unary only if...
			//		- the previous component was an operator or nothing at all
			//		- the previous component wasn't a parenthesis
			//		- and the operator is either addition or subtraction.
			if ((result.count == 0 || [[result lastObject] isKindOfClass:[Operator class]]) &&
				(op.type == ADD || op.type == SUB)) {
				Operator *top = [result lastObject];
				if (top == nil || (top.type != RIP && top.type != LEP)) {
					// Ignore unary addition
					if (op.type == ADD) continue;
					else op.type = USU;
				}
			}
			
			[result addObject:op];
		}
		else if ([operandCharacters characterIsMember:c]) {
			// Operand
			[operand appendString:[NSString stringWithFormat:@"%c", c]];
		}
	}
	
	// Save remaining operand
	if (operand.length > 0) {
		[result addObject:[NSNumber numberWithDouble:[operand doubleValue]]];
	}

	return result;
}

// Convert infix expression to postfix
+ (NSArray *)infixToPostfix:(NSArray *)infix
{
	NSMutableArray *postfix = [[NSMutableArray alloc] init];
	NSMutableArray *stack = [[NSMutableArray alloc] init];
	
	for (id component in infix) {
		if ([component isKindOfClass:[Operator class]]) {
			// Operator found
			Operator *op = component;
			
			if (op.type == LEP) {
				// Left parenthesis
				[stack addObject:op];
			}
			else {
				// Operator or right parenthesis
				Operator *top = [stack lastObject];
				while (stack.count > 0 && (op.type <= top.type || op.type == RIP)) {
					// Pop top of the stack
					[stack removeLastObject];
					if (top.type == LEP) {
						// Complete parenthesis
						break;
					}
					else [postfix addObject:top];
					top = [stack lastObject];
				}
				
				// Add operation to stack (right parenthesis no good here)
				if (op.type != RIP) {
					[stack addObject:op];
				}
			}
		}
		else if ([component isKindOfClass:[NSNumber class]]) {
			// Operand found
			[postfix addObject:component];
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
	
	for (id component in postfix) {
		if ([component isKindOfClass:[NSValue class]]) {
			// Operand
			[stack addObject:component];
		}
		else {
			// Operator
			Operator *operator = component;
			if (operator.type == USU && stack.count > 0) {
				// Unary minus
				NSNumber *first = [stack lastObject];
				[stack removeLastObject];
				[stack addObject:[operator calculate:first second:nil]];
			}
			else if (stack.count >= 2) {
				// Pop operands from stack
				NSNumber *second = [stack lastObject];
				[stack removeLastObject];
				NSNumber *first = [stack lastObject];
				[stack removeLastObject];

				// Calculate result and push to stack
				[stack addObject:[operator calculate:first second:second]];
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
		case USU: return [NSNumber numberWithDouble:[first doubleValue] * -1.0f];
		default: return [NSNumber numberWithDouble:0.0f];
	}
}
@end
