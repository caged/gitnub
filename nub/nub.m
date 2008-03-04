#import <Foundation/Foundation.h>

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    // NSArray *myArgs = [[NSProcessInfo processInfo] arguments];
    // NSLog(@"%@", myArgs);    
    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/Applications/GitNub.app/Contents/MacOS/GitNub"];
    [task launch];
    [task waitUntilExit];
    
    [pool drain];
    return 0;
}
