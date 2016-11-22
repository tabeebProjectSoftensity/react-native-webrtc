package com.oney.WebRTCModule;

import org.webrtc.VideoCapturerAndroid;

/**
 * Created by mac-219 on 16.11.2016.
 */
public class VideoSourceContainer {
    private static VideoSourceContainer ourInstance = new VideoSourceContainer();

    public VideoCapturerAndroid videoCapturer;

    public static VideoSourceContainer getInstance() {
        return ourInstance;
    }

    private VideoSourceContainer() {
    }
}
