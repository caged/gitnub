#import <Cocoa/Cocoa.h>

int main (int argc, const char * argv[]) {
    char buf[PATH_MAX];
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // NSArray *myArgs = [[NSProcessInfo processInfo] arguments];
    // NSLog(@"%@", myArgs);

    NSString *path=[[NSString alloc] initWithCString:getcwd(buf, sizeof(buf))];

    [[NSWorkspace sharedWorkspace] openFile:path withApplication:@"GitNub"];

    [path release];
    [pool drain];
    return 0;
}
