package com.gae.scaffolder.plugin;

import android.content.Context;
import android.util.Log;

import me.leolin.shortcutbadger.ShortcutBadgeException;
import me.leolin.shortcutbadger.ShortcutBadger;

/**
 * Created by ArindamN on 04/04/2017.
 */
public class BadgeHelper {
    private static String TAG = "FCM_BADGE_HELPER";
    public final static String CONST_BADGE_KEY = "badge";

    public static void setBadgeCount(String badge, Context ctx){
        try {
            //String badge = (String) remoteMessage.get("badge");
            int badgeCount = 0;
            if(badge!=null && !badge.isEmpty()){
                badgeCount = tryParseInt(badge);
            }
            if(badgeCount>0)
            {
                ShortcutBadger. applyCountOrThrow(ctx, badgeCount);
                Log.d(TAG, "showBadge worked!");
            }

        } catch (ShortcutBadgeException e) {
            Log.e(TAG, "showBadge failed: " + e.getMessage());
        }
    }
    static int tryParseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
