//
//  main.m
//  InfixCalculator
//
//  Created by Karl Persson on 2014-07-25.
//  Copyright (c) 2014 Karl Persson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Calculator.h"

int main(int argc, const char * argv[])
{
	NSLog(@"Ready");
	
	// Initialize input
	NSFileHandle *input = [NSFileHandle fileHandleWithStandardInput];
	
	// Run
	while (true) {
		NSData *data = [input availableData];
		
		if (data) {
			NSString *calculation = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			
			// Calculate
			NSLog(@"= %@", [[Calculator calculate:calculation] stringValue]);
		}
		
	}
	
    return 0;
}
