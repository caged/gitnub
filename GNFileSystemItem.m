//
//  GNFileSystemItem.m
//

#import "GNFileSystemItem.h"


@implementation GNFileSystemItem

static GNFileSystemItem *rootItem = nil;
#define IsALeafNode ((id)-1)

- (id)initWithPath:(NSString *)path parent:(GNFileSystemItem *)obj
{
    if (self = [super init])
    {
        
        relativePath = [[path lastPathComponent] copy];
        parent = obj;
    }
    return self;
}


+ (GNFileSystemItem *)rootItem
{
    if (rootItem == nil)
    {
        rootItem = [[GNFileSystemItem alloc] initWithPath:[GNFileSystemItem repoRoot] parent:nil];
    }
    return rootItem;
}

+ (NSString *)repoRoot {
    return  [[[NSApplication sharedApplication] delegate] repository_location];
}

// - (BOOL)ignoredByGit:(NSString *)fileItem
// {
//     NSString *format;
//     if([[self fullPath] hasSuffix:@"/"])
//         format = @"%@%@";
//     else
//         format = @"%@/%@";
//         
//     NSString *file = [NSString stringWithFormat:format, [self fullPath], fileItem];
//         
//     BOOL ignored = [[[NSApplication sharedApplication] delegate] is_file_ignored:file];
//     return !ignored;
// }

// Creates, caches, and returns the array of children
// Loads children incrementally
- (NSArray *)children
{
    if (children == NULL)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *fullPath = [self fullPath];
        BOOL isDir, valid = [fileManager fileExistsAtPath:fullPath isDirectory:&isDir];

        if (valid && isDir)
        {
            NSArray *array = [fileManager directoryContentsAtPath:fullPath];
            int numChildren = [array count];
            children = [[NSMutableArray alloc] initWithCapacity:numChildren];
            for (NSString *sourceFile in array)
            {
                if([[sourceFile lastPathComponent] hasPrefix:@"."]) {
                    continue;
                }
                
                if([self ignoredByGit:sourceFile]) {
                    continue;
                }
                
                GNFileSystemItem *newChild = [[GNFileSystemItem alloc] initWithPath:sourceFile parent:self];
                [children addObject:newChild];
                [newChild release];
            }
        }
        else
        {
            children = IsALeafNode;
        }
    }
    return children;
}


- (NSImage*)icon
{
    if (image == nil)
    {
        image = [[[NSWorkspace sharedWorkspace] iconForFile: [self fullPath]] retain];
    }

    return image;
}


- (NSDictionary*)attributes
{
    return [NSDictionary dictionaryWithDictionary: [[NSFileManager defaultManager] fileAttributesAtPath: [self fullPath] traverseLink: YES]];
}


- (NSString *)relativePath
{
    return relativePath;
}


- (void)setRelativePath:(NSString *)aString
{
    if (aString != relativePath)
    {
        [relativePath release];
        [relativePath = aString copy];
    }
}


- (NSString *)fullPath
{
    // If no parent, return our own relative path
    if (parent == nil) {
        return [GNFileSystemItem repoRoot];
    }
    // recurse up the hierarchy, prepending each parent’s path
    return [[parent fullPath] stringByAppendingPathComponent:relativePath];
}


- (GNFileSystemItem *)childAtIndex:(int)n
{
    return [[self children] objectAtIndex:n];
}


- (BOOL)isLeafNode
{
    return  [self children] == IsALeafNode;
}

- (int)numberOfChildren
{
    id tmp = [self children];
    return (tmp == IsALeafNode) ? (-1) : [tmp count];
}

- (BOOL)isHeading
{
    return [[self fullPath] isEqualToString:[GNFileSystemItem repoRoot]];
}

- (void)dealloc
{
    [image release];
    if (children != IsALeafNode) [children release];
    [relativePath release];
    [super dealloc];
}

@end
