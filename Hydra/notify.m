#import "hydra.h"

// you hate us Apple, don't you
@interface PHNotificationDelegate : NSObject <NSUserNotificationCenterDelegate>
@property lua_State* L;
@end

@implementation PHNotificationDelegate

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    NSString* tag = [[notification userInfo] objectForKey:@"tag"];
    
    lua_State*L = self.L;
    
    lua_getglobal(L, "api");
    lua_getfield(L, -1, "notify");
    lua_getfield(L, -1, "_clicked");
    
    if (lua_isfunction(L, -1)) {
        lua_pushstring(L, [tag UTF8String]);
        if (lua_pcall(L, 1, 0, 0))
            hydra_handle_error(L);
        lua_pop(L, 3);
    }
    else {
        lua_pop(L, 2);
    }
    
    [center removeDeliveredNotification:notification];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification { return YES; }

@end

static hydradoc doc_notify_show = {
    "notify", "show", "api.notify.show(title, subtitle, text, tag)",
    "Show an Apple notification. Tag is a unique string that identifies this notification, and will be passed to api.notify.clicked() if the notification is clicked. None of the strings are optional, though they may each be blank."
};

int notify_show(lua_State* L) {
    NSUserNotificationCenter* userNotificationCenter = [NSUserNotificationCenter defaultUserNotificationCenter]; // I'm starting to get the feeling you really do
    
    static PHNotificationDelegate* delegate;
    if (!delegate) {
        delegate = [[PHNotificationDelegate alloc] init];
        delegate.L = L;
        userNotificationCenter.delegate = delegate;
    }
    
    NSUserNotification* note = [[NSUserNotification alloc] init];
    note.title = [NSString stringWithUTF8String: lua_tostring(L, 1)];
    note.subtitle = [NSString stringWithUTF8String: lua_tostring(L, 2)];
    note.informativeText = [NSString stringWithUTF8String: lua_tostring(L, 3)];
    note.userInfo = @{@"tag": [NSString stringWithUTF8String: lua_tostring(L, 4)]};
    
    [userNotificationCenter deliverNotification:note];
    
    return 0;
}

static const luaL_Reg notifylib[] = {
    {"show", notify_show},
    {NULL, NULL}
};

int luaopen_notify(lua_State* L) {
    hydra_add_doc_group(L, "notify", "Apple's built-in notifications system.");
    hydra_add_doc_item(L, &doc_notify_show);
    
    luaL_newlib(L, notifylib);
    return 1;
}
