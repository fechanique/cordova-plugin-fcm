package com.gae.scaffolder.plugin.interfaces;

import androidx.annotation.NonNull;

public interface OnFinishedListener<TResult> {
    void success(@NonNull TResult result);
}
