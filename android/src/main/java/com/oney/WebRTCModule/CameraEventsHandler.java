package com.oney.WebRTCModule;

import android.content.Intent;
import android.support.v4.content.LocalBroadcastManager;
import android.util.Log;
import android.hardware.Camera;

import org.webrtc.CameraVideoCapturer;

class CameraEventsHandler implements CameraVideoCapturer.CameraEventsHandler {
    private final static String TAG = WebRTCModule.TAG;
    private int cameraID = -1;

    private void sendMessage(int cameraId) {
        Log.d("sender", "Broadcasting message");
        if(WebRTCModule.staticContext != null) {
            Intent intent = new Intent("camera_id_detected");
            // You can also include some extra data.
            Log.v(TAG, "SENT CAMERA ID: " + cameraId);
            intent.putExtra("message", cameraId);
            LocalBroadcastManager.getInstance(WebRTCModule.staticContext).sendBroadcast(intent);
        }
    }

    // Camera error handler - invoked when camera can not be opened
    // or any camera exception happens on camera thread.
    @Override
    public void onCameraError(String errorDescription) {
        Log.d(TAG, String.format("CameraEventsHandler.onCameraError: errorDescription=%s", errorDescription));
    }

    // Called when camera is disconnected.
    @Override
    public void onCameraDisconnected() {
        Log.d(TAG, "CameraEventsHandler.onCameraDisconnected");
    }

    // Invoked when camera stops receiving frames
    @Override
    public void onCameraFreezed(String errorDescription) {
        Log.d(TAG, String.format("CameraEventsHandler.onCameraFreezed: errorDescription=%s", errorDescription));
    }

    // Callback invoked when camera is opening.
    @Override
    public void onCameraOpening(String cameraName) {
        Log.d(TAG, String.format("CameraEventsHandler.onCameraOpening: cameraName=%s", cameraName));
        if (cameraName.contains("front")) {
            // Search for the front facing camera
            int numberOfCameras = Camera.getNumberOfCameras();
            for (int i = 0; i < numberOfCameras; i++) {
                Camera.CameraInfo info = new Camera.CameraInfo();
                Camera.getCameraInfo(i, info);
                if (info.facing == Camera.CameraInfo.CAMERA_FACING_FRONT) {
                    Log.d(TAG, "Camera front found");
                    cameraID = i;
                    break;
                }
            }
        }
        else {
            // Search for the front facing camera
            int numberOfCameras = Camera.getNumberOfCameras();
            for (int i = 0; i < numberOfCameras; i++) {
                Camera.CameraInfo info = new Camera.CameraInfo();
                Camera.getCameraInfo(i, info);
                if (info.facing == Camera.CameraInfo.CAMERA_FACING_BACK) {
                    Log.d(TAG, "Camera back found");
                    cameraID = i;
                    break;
                }
            }
        }
    }

    // Callback invoked when first camera frame is available after camera is opened.
    @Override
    public void onFirstFrameAvailable() {
        Log.d(TAG, "CameraEventsHandler.onFirstFrameAvailable: " + cameraID);
        sendMessage(cameraID);
    }

    // Callback invoked when camera closed.
    @Override
    public void onCameraClosed() {
        Log.d(TAG, "CameraEventsHandler.onFirstFrameAvailable");
    }
}
