// SYNTerminalFormatter.m
//
// Copyright (c) 2013 Stephen Celis (<stephen@stephencelis.com>)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "SYNTerminalFormatter.h"


static NSString *const dimEscape = @"\033[0;2m";
static NSString *const brightEscape = @"\033[0;1m";
static NSString *const resetEscape = @"\033[0m";


@interface SYNTerminalFormatter ()

@property NSUInteger offset;

@end


@implementation SYNTerminalFormatter

- (void)processor:(SYNProcessor *)processor willProcessInput:(NSString *)inputString
{
    processor.outputString = [inputString mutableCopy];
    [processor.outputString insertString:dimEscape atIndex:0];
    self.offset += [dimEscape length];
}

- (void)processor:(SYNProcessor *)processor processingTag:(NSString *)tag atRange:(NSRange)range
{
    [processor.outputString insertString:brightEscape atIndex:range.location + self.offset];
    self.offset += [brightEscape length];
    [processor.outputString insertString:dimEscape atIndex:range.location + range.length + self.offset];
    self.offset += [dimEscape length];
}

- (void)processorDidProcess:(SYNProcessor *)processor
{
    [processor.outputString insertString:resetEscape atIndex:[processor.outputString length]];
}

@end
