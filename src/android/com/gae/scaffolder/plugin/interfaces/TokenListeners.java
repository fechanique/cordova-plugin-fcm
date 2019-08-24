package com.gae.scaffolder.plugin.interfaces;

public interface TokenListeners<TSuccess, TError> extends OnFinishedListener<TSuccess> {
    void error(TError message);
}
