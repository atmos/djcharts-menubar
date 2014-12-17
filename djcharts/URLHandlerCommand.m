#import "URLHandlerCommand.h"

@implementation URLHandlerCommand

- (id)performDefaultImplementation {
    NSString *urlString = [self directParameter];
    NSLog(@"url = %@", urlString);

    NSArray *values = [urlString componentsSeparatedByString :@"/"];

    NSLog(@"values = %@", values);
    return nil;
}

@end
