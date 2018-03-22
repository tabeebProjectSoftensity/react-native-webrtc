package com.oney.WebRTCModule;

import org.webrtc.Camera2Capturer;
import org.webrtc.VideoCapturer;

public class VideoSourceContainer {
    private static VideoSourceContainer ourInstance = new VideoSourceContainer();

    public Boolean isCamera2Api = true;

    public Camera2Capturer camera2Capturer;
    public VideoCapturer videoCapturer;

    public static VideoSourceContainer getInstance() {
        return ourInstance;
    }

    private VideoSourceContainer() {
    }
}
