// SYNJSONFormatter.m
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
// THE SOFTWARE


#import "SYNJSONFormatter.h"


static NSString *const SYNJSONFormatterTagKey = @"tag";
static NSString *const SYNJSONFormatterRangeLocationKey = @"location";
static NSString *const SYNJSONFormatterRangeLengthKey = @"length";
static NSString *const SYNJSONFormatterTokenKey = @"token";


@interface SYNJSONFormatter ()

@property (copy) NSString *inputString;

@end


@implementation SYNJSONFormatter

- (void)processor:(SYNProcessor *)processor willProcessInput:(NSString *)inputString
{
    self.inputString = inputString;
}

- (void)processor:(SYNProcessor *)processor processingTag:(NSString *)tag atRange:(NSRange)range
{
    NSString *token = [self.inputString substringWithRange:range];
    NSDictionary *dictionary = @{SYNJSONFormatterTagKey: tag,
                                 SYNJSONFormatterRangeLocationKey: @(range.location),
                                 SYNJSONFormatterRangeLengthKey: @(range.length),
                                 SYNJSONFormatterTokenKey: token};
    NSError *error = nil;
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    if (error) {
        // handle error
    }
    NSString *JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    [processor.outputString appendFormat:@"%@\n", JSONString];
}

@end
