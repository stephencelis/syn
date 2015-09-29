// SYNProcessor.m
//
// Copyright © 2013–2015 Stephen Celis (<stephen@stephencelis.com>)
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


#import "SYNProcessor.h"
#import "SYNANSIFormatter.h"
#import "SYNTableFormatter.h"
#import "SYNJSONFormatter.h"


NSString *const SYNANSIFormat = @"ansi";
NSString *const SYNTableFormat = @"table";
NSString *const SYNJSONFormat = @"json";


@interface SYNProcessor ()

@property id <SYNFormatter>formatter;
@property NSFileHandle *output;

@end


@implementation SYNProcessor

- (id)initWithFormat:(NSString *)format output:(NSFileHandle *)output
{
    if (self = [super init]) {
        if ([format isEqualToString:SYNANSIFormat]) {
            self.formatter = [SYNANSIFormatter new];
        } else if ([format isEqualToString:SYNJSONFormat]) {
            self.formatter = [SYNJSONFormatter new];
        } else if ([format isEqualToString:SYNTableFormat]) {
            self.formatter = [SYNTableFormatter new];
        } else {
            return nil;
        }
        self.output = output;
    }
    return self;
}

- (void)process:(NSString *)inputString tags:(NSSet *)tags;
{
    NSLinguisticTaggerOptions options = NSLinguisticTaggerOmitWhitespace | NSLinguisticTaggerOmitPunctuation | NSLinguisticTaggerJoinNames;
    NSLinguisticTagger *tagger = [[NSLinguisticTagger alloc] initWithTagSchemes:[NSLinguisticTagger availableTagSchemesForLanguage:[[NSLocale preferredLanguages] firstObject]] options:options];

    NSString *normalizedString = [[inputString stringByReplacingOccurrencesOfString:@"\n\n" withString:@". "] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];

    tagger.string = normalizedString;

    if ([self.formatter respondsToSelector:@selector(processor:willProcessInput:)]) {
        [self.formatter processor:self willProcessInput:inputString];
    }

    [tagger enumerateTagsInRange:NSMakeRange(0, [inputString length]) scheme:NSLinguisticTagSchemeNameTypeOrLexicalClass options:options usingBlock:^(NSString *tag, NSRange tokenRange, NSRange sentenceRange, BOOL *stop) {
        if ([tags containsObject:tag]) {
            NSString *token = [normalizedString substringWithRange:tokenRange];
            [self.formatter processor:self processingTag:tag atRange:tokenRange token:token];
        }
    }];

    if ([self.formatter respondsToSelector:@selector(processorDidProcess:)]) {
        [self.formatter processorDidProcess:self];
    }
}

- (void)puts:(NSString *)string, ...
{
    va_list args;
    va_start(args, string);
    string = [[NSString alloc] initWithFormat:[string stringByAppendingString:@"\n"] arguments:args];
    va_end(args);
    [self write:string];
}

- (void)write:(NSString *)string
{
    [self.output writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
