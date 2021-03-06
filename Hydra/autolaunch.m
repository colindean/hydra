#import "hydra.h"

static LSSharedFileListRef shared_file_list() {
    static LSSharedFileListRef list;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        list = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    });
    return list;
}

static hydradoc doc_autolaunch_get = {
    "autolaunch", "get", "api.autolaunch.get() -> bool",
    "Returns whether Hydra launches when you login."
};

int autolaunch_get(lua_State* L) {
    NSURL *appURL = [[[NSBundle mainBundle] bundleURL] fileReferenceURL];
    
    UInt32 seed;
    NSArray *sharedFileListArray = (__bridge_transfer NSArray*)LSSharedFileListCopySnapshot(shared_file_list(), &seed);
    for (id item in sharedFileListArray) {
        LSSharedFileListItemRef sharedFileItem = (__bridge LSSharedFileListItemRef)item;
        CFURLRef url = NULL;
        
        OSStatus result = LSSharedFileListItemResolve(sharedFileItem, 0, &url, NULL);
        if (result == noErr && url != NULL) {
            BOOL foundIt = [appURL isEqual: [(__bridge NSURL*)url fileReferenceURL]];
            
            CFRelease(url);
            
            if (foundIt) {
                lua_pushboolean(L, YES);
                return 1;
            }
        }
    }
    
    lua_pushboolean(L, NO);
    return 1;
}

static hydradoc doc_autolaunch_set = {
    "autolaunch", "set", "api.autolaunch.set(bool)",
    "Sets whether Hydra launches when you login."
};

int autolaunch_set(lua_State* L) {
    BOOL opensAtLogin = lua_toboolean(L, 1);
    
    NSURL *appURL = [[[NSBundle mainBundle] bundleURL] fileReferenceURL];
    
    if (opensAtLogin) {
        LSSharedFileListItemRef result = LSSharedFileListInsertItemURL(shared_file_list(),
                                                                       kLSSharedFileListItemLast,
                                                                       NULL,
                                                                       NULL,
                                                                       (__bridge CFURLRef)appURL,
                                                                       NULL,
                                                                       NULL);
        CFRelease(result);
    }
    else {
        UInt32 seed;
        NSArray *sharedFileListArray = (__bridge_transfer NSArray*)LSSharedFileListCopySnapshot(shared_file_list(), &seed);
        for (id item in sharedFileListArray) {
            LSSharedFileListItemRef sharedFileItem = (__bridge LSSharedFileListItemRef)item;
            CFURLRef url = NULL;
            
            OSStatus result = LSSharedFileListItemResolve(sharedFileItem, 0, &url, NULL);
            if (result == noErr && url != nil) {
                if ([appURL isEqual: [(__bridge NSURL*)url fileReferenceURL]])
                    LSSharedFileListItemRemove(shared_file_list(), sharedFileItem);
                
                CFRelease(url);
            }
        }
    }
    return 0;
}

static const luaL_Reg autolaunchlib[] = {
    {"get", autolaunch_get},
    {"set", autolaunch_set},
    {NULL, NULL}
};

int luaopen_autolaunch(lua_State* L) {
    hydra_add_doc_group(L, "autolaunch", "Functions for controlling whether Hydra launches at login.");
    hydra_add_doc_item(L, &doc_autolaunch_get);
    hydra_add_doc_item(L, &doc_autolaunch_set);
    
    luaL_newlib(L, autolaunchlib);
    return 1;
}
