package com.gae.scaffolder.plugin.interfaces;

import android.support.annotation.NonNull;

public interface OnFinishedListener<TResult> {
    void success(@NonNull TResult result);
}
