package com.oney.WebRTCModule;

import org.webrtc.Camera2Capturer;
import org.webrtc.VideoRenderer;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.List;

public class VideoSourceContainer {
    private static VideoSourceContainer ourInstance = new VideoSourceContainer();

    public Camera2Capturer camera2Capturer;

    public static VideoSourceContainer getInstance() {
        return ourInstance;
    }

    private VideoSourceContainer() {
    }
}
