# Android

## Setup & Configuration

### SDK Integration

#### Android Studio

  * Open your existing project (or create a new one)
  * Create the libs folder under app (if not already there)
  * Copy the CamOnApp SDK (CamOnApp.aar) to the libs folder
  * In the next screen, select CamOnAppSDK.aar from your computer
  * Once added, go to the app's build.gradle and make sure it starts like this:

```
    dependencies {
        implementation fileTree(dir: 'libs', include: ['*.jar','*.aar'])
    }
```
### Android Manifest: required changes

The rest of the Setup Guide is independent of whether you set up the project with Eclipse or Android Studio. Add the following permissions to your AndroidManifest.xml:

```html
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourpackage"
    android:versionCode="1"
    android:versionName="@string/app_version" >
 
    <uses-feature android:glEsVersion="0x00020000" android:required="true" />
    <uses-feature android:name="android.hardware.camera" />
	<uses-feature android:name="android.hardware.telephony" android:required="false" />
	<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
	<uses-feature android:name="android.hardware.camera.flash" android:required="false" />

    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.CALL_PHONE" />
    <uses-permission android:name="android.permission.READ_LOGS" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.GET_ACCOUNTS" />
    
    <supports-gl-texture android:name="GL_OES_compressed_ETC1_RGB8_texture" />
    <supports-gl-texture android:name="GL_OES_compressed_paletted_texture" />

    ...

</manifest>
```

The activity extending CamOnAppActivity must override "configChanges" and "screenOrientation":

```html
<activity
	android:name="com.yourpackage.MainActivity"
 	android:configChanges="orientation|keyboardHidden"
 	android:screenOrientation="portrait" >
</activity>
```

### License Setup

In order to get a valid license key, you should request it to the CamOnApp Team (see http://www.camonapp.com). Once obtained, the AndroidManifest.xml should be updated like this:

```html
<?xml version="1.0" encoding="utf-8"?>
<manifest ... >
	...

	<application ... >
		...

		<!-- Activity using CamOnAppFragment -->
		<activity ... >
			<meta-data
                android:name="com.camonapp.LicenseUserKey"
                android:value="@string/camonapp_license_user_key" />
            <meta-data
                android:name="com.camonapp.LicenseSecretKey"
                android:value="@string/camonapp_license_secret_key" />
            <meta-data
                android:name="com.camonapp.LicenseRealKey"
                android:value="@string/camonapp_license_real_key" />
        </activity>

    </application>

</manifest>
```
### Supported Android Devices

CamOnApp SDK is running on devices fulfilling the following requirements:

  * Android 5.0+ (API Level 21+)
  * Compass
  * Accelerometer
  * Medium resolution devices (mdpi)
  * Rear-facing camera
  * OpenGL 2.0

## Basic Usage

Once CamOnApp SDK has been configured, its usage is very straightforward. All you have to do is:

  * Extend the desired Activity from CamOnAppActivity
  * Override those methods needed to add new/extra functionality (optional)
  *  Define a new ActionListener for adhoc behaviour (optional)

### Extending from CamOnAppActivity

```Java
public class CameraActivity extends CamOnAppActivity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        createView();
        ...
    }

    private void createView() {
        // Root view is defined within CamOnAppActivity
        ViewGroup parentView = findViewById(android.R.id.content);

        RelativeLayout layout = (RelativeLayout) getLayoutInflater().inflate(R.layout.activity_main, null);

        RelativeLayout.LayoutParams layoutParams = new RelativeLayout.LayoutParams(RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT);
        layoutParams.addRule(RelativeLayout.ALIGN_PARENT_TOP, RelativeLayout.TRUE);
        layoutParams.addRule(RelativeLayout.CENTER_HORIZONTAL, RelativeLayout.TRUE);
        layout.setLayoutParams(layoutParams);

        // Your root view needs to be added to CamOnApp's root view
        parentView.addView(layout);

        // Now you can use the view hierarchy as usual
        View view = findViewById(R.id.your_view_id);
        ...
    }
}
```

### Extending the functionality

CamOnAppActivity methods are fully described in the API Section. No method needs to be overriden. Everything will work as expected with the minimum configuration described above.

Some of the features that could extended/listened to are:
   * Experience Detected
   * Experience Started
   * Etc...

### Defining a custom ActionListener
CamOnApp SDK provides a default action listener (named CamOnAppDefaultActionListener), which provides all the functionality needed for almost every experience callback. As the default action listener implements the CamOnAppActionListener interface, there are two options:

   * Create a new class that implements the CamOnAppActionListener interface (and implement every method from scratch according to the needs)
   * Create a new class extending CamOnAppDefaultActionListener. This way, only desired methods will have to be overriden

CamOnAppDefaultActionListener does NOT implement the following methods (they will always have to be implemented):

   * onPostInFacebook
   * onLikeFacebookPage
   * onPostInTwitter
   * onTwitterFollow

Once the custom action listener was created (and configured) it will have to be attached to the activity by calling setActionListener.

### A note about devices running Android 6.0+

In previous Android versions, app's permissions were granted automatically. Since Android 6.0, each app itself has to handle permissions requests' and their logic. As CamOnApp uses the device's camera, if the user hasn't allowed the camera permission explicitly, the camera feed won't be shown, and a black screen will appear instead.

Here's the official link about how permissions need to be handled.

## Experience Lifecycle

The SDK can be initialized in 4 different modes:

   * Targetless: scanner and target detection are disabled. There only way to start a experience is by id (with startExperienceWithId(ID)).
   * TargetObject: scanner and target detection are enabled. Experiences can be either started by target detection or by id.
   * TargetObjectBundle: same as TargetOnject, but in bundle mode. In this mode, no internet connection is required (experiences and target need to be within the assets folder).
   * TargetFace: similar to TargetObject, where the only possible target is a human face.
Once initialized, there are two ways of starting a new experience:

   * By target detection (image, cylinder, object)
   * By experience-id (manually)

In both cases, the lifecycle triggered by the SDK will be the following (in order):

   * onExperienceDetected: experience has been detected and loading process has been started
   * onExperienceStarted: experience load has finished and it has been shown to the user
   * onExperienceStopped: experience has been unloaded and is no longer visible to the user

## Bundle Mode 

Bundle Mode should be used when no internet connection is needed. In this case, the target detection and the experience contents live within the app (in the assets folder).

The setup for bundle mode require the following steps:

   * Add a file named offline.zip (provided by the CamOnApp team) within assets/to_copy folder of your app 
   * Initialize the bundle data (first time only). Unzipping and preparing the data to be ready to use by the SDK can take some time (depending on the size of offline.zip itself). That's why there's a method for this called CamOnAppUtils.initBundleData(context). We recommend to call this method (not mandatory) when the app is being initialized for the first time, otherwise the first time the SDK loads it will take more time than expected.
   * Configure the SDK target mode as CamOnAppTargetMode.TARGET_OBJECT_BUNDLE:

```Java
@Override
protected void onCreate(Bundle savedInstanceState) {
	super.onCreate(savedInstanceState);

	setTargetMode(CamOnAppTargetMode.TARGET_OBJECT_BUNDLE);
	...
}
```

From now on, the SDK will search for known targets installed locally, and once detected, the associated experience will be fired right away.

## Positional Experiences

### Introduction

These are experiences that make it harder to understand the differences between the real and the digital world. Contents are positioned right around the user's location. Here's an ARCore example create by Google:

<iframe width="560" height="315" src="https://www.youtube.com/embed/7SwZUNDsWaM" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

### About UX/UI

Positional experiences have a slightly different flow as "normal" experiences. As these experiences need a ground plane where they will be anchored, the user will need to choose where he wants to place them.

For this purpose, CamOnApp's SDK provides an default UI indicating when is a good moment to place an experience (meaning, the user has a ground plane in front of him). If you need to disable this UI in order to provide yours, all you have to do is call disableGroundPlaneHint().

When a positional experience has started, the SDK will trigger the following callbacks:

   * onGroundPlaneFound: there's a ground plane in front of the user. He could tap the screen in order to place the experience.
   * onGroundPlaneLost: the ground plane has been lost. The user will have to find a new one.
   * onAnchorPointCreated: the user has successfuly placed the experience in a ground plane.

### Enabling ARCore

CamOnApp's SDK can place positional experiences in devices without ARCore / without ARCore installed. However, we do recommend to suggest to your users to install ARCore when that's a possibility.

ARCore runs in a limited number of devices for the moment (here the list).

In order to boost the user experience and enable ARCore, the following steps need to be done:
   * Add the ARCore dependency to your app's Gradle file:
   ```
    dependencies {
        implementation 'com.google.ar:core:1.4.0'
        ...
    }
   ```
   * Check if the device supports ARCore and it's not installed. In that case, start the installation flow within the app:
   ```Java
    if (CamOnAppUtils.isARCoreSupported(this) && !CamOnAppUtils.isARCoreInstalled(this)) {
        CamOnAppUtils.checkARCoreAvailability(this, new CamOnAppUtils.ARCoreAvailabilityCallback() {
            @Override
            public void unsupported() {
                Log.i("ARCore", "ARCore is not supported");
            }

            @Override
            public void installed() {
                Log.i("ARCore", "ARCore already installed");
            }

            @Override
            public void installRequested() {
                Log.i("ARCore", "ARCore install has been requested");
            }

            @Override
            public void userDeclinesInstallation() {
                Log.i("ARCore", "ARCore installation has been declined by user");
            }

            @Override
            public void deviceNotCompatible() {
                Log.i("ARCore", "ARCore is not compatib le with this device");
            }

            @Override
            public void unknownError() {
                Log.i("ARCore", "ARCore unknown error has occurred");
            }
        });
    }
   ```
## API

### CamOnAppActivity

```Java
/**
 * SDK has finished loading, and the camera is now visible. From this moment on, it's safe to
 * call any SDK method.
 * */
public void onCameraPresented();

/**
 * Indicated whether the SDK has been initialized or not.
 * */
public boolean cameraInitialized();

/**
 * A new ActionDelegate will be configured for every callback possible within an experience.
 * */
public void setActionListener(CamOnAppActionListener actionListener);

/**
 * Overrides current TargetMode. Default TargetMode is CamOnAppTargetMode.TARGET_OBJECT.
 * */
public void setTargetMode(int mode);

/**
 * Gets current TargetMode. Possible values defined within CamOnAppTargetMode.
 * */
public int getTargetMode();

/**
 * By enabling scanning mode, the SDK will be able to detect targets. Scanning mode is disabled by default.
 */
public void enableScanningMode();

/**
 * Disables scanning mode preventing any target to be detected. This is the default behaviour.
 */
public void disableScanningMode();

/**
 * When scanning mode is enabled, the SDK will try to find known targets for 12 seconds.
 * If no target has been found during that time, this callback will be triggered, scanning mode
 * will be disabled and it will need to be enabled again (if needed) by calling enableScanningMode().
 * */
public void onTargetDetectionTimeoutReached();

/**
 * Callback called when scanning mode has been disabled.
 * */
public void onScanningModeDisabled();

/**
 * Callback called when scanning mode has been enabled.
 * */
public void onScanningModeEnabled();

/**
 * A new experience has been detected and a download has been triggered for its contents.
 * You should override this method if a dialog needs to be shown to the user once the
 * experience has been detected.
 * @param experienceId Detected experience id
 * */
public void onExperienceDetected(String experienceId);

/**
 * The detected experience is now running and is being shown to the user.
 * @param info Information about running experience
 * @param insideView Indicated whether the experience is running inside the target (or not)
 * */
public void onExperienceStarted(COAExperienceInfo info, boolean insideView);

/**
 * The execution of the experience has ended. The Activity is
 * now ready to detect (and execute) a new experience.
 * */
public void onExperienceStopped();

/**
 * The camera has lost (or gained) focus over the target. This method is called
 * every time the focus changes.
 * @param inView The experience's target is within the camera view
 * */
public void onExperienceSourceChanged(boolean inView);

/**
 * Starts an experience matching the provided Id.
 * @param experienceId
 */
public boolean startExperienceWithId(String experienceId);

/**
 * Indicates whether an experience is currently running or not.
 * */
public boolean anyExperienceRunning();

/**
 * Indicates if there's any experiencie detected, even if it's not yet started.
 */
public boolean anyExperienceDetected();

/**
 * Informs whether any trackable exists at this time.
 * */
public boolean anyCurrentTrackable();

/**
 * Removes the current experience (if any).
 */
public void removeCurrentExperience();

/**
 * Removes the current experience (if any) and leaves scanning mode (avoids a new target detection).
 */
public void removeCurrentExperienceAndLeaveScanningMode();

/**
 * Switches the camera from back to front (or otherwise).
 * */
public void switchCamera();

/**
 * When scanning mode is enabled, a scan overlay will be shown by default as a UI helper
 * indicating that a scanning is in progress. This method enables/disables that UI.
 * */
public void setShowScanOverlay(boolean show);

/**
 * When a experience is loading, a loading image will be shown together with a progress indicator.
 * This method enables/disables that loading UI.
 * */
public void setShowLoadingScene(boolean show);

/**
 * Informs that the last kwnown trackable has been lost.
 * */
public void onTrackableLost();

/**
 * Informs that a trackable (of any type) has been found.
 * */
public void onTrackableFound();

/**
 * By default, CamOnApp SDK shows a default UI hint for positional experiences.
 * This method disables it, in order to provide a custom UI (if needed).
 * */
public void disableGroundPlaneHint();

/**
 * A ground plane has been lost. It's needed in order to place experiences in the ground.
 * */
public void onGroundPlaneLost();

/**
 * A ground plane has been found: now the experience can be placed.
 * */
public void onGroundPlaneFound();

/**
 * An anchor point has been created: now the experience has been placed successfuly.
 * */
public void onAnchorPointCreated();

/**
 * Requests a new screenshot to be made to what the user is experimenting.
 * The screenshot will contain the camera + AR contents.
 * As this is an asynchronous process, the callback onScreenshotReady will have to be
 * implemented as well.
 * */
public void requestScreenshot();

/**
 * Called when the screenshot is ready.
 * @param screenshot The resulting screenshot as a bitmap
 * */
public void onScreenshotReady(Bitmap screenshot);

/**
 * Starts a video session recording. Once completed, stopVideoRecording needs to be called.
 * @param listener A callback for each possible status during the recording lifecycle:
 *                 recordingStarted, recordingStopped, recordingProcessing, recordingFailed
 * */
public void startVideoRecording(MediaRecorder.MediaRecorderListener listener, float scale);

/**
 * Stops the video recording session.
 * */
public void stopVideoRecording();

/**
 * Indicates whether there's a recording session in progress or not.
 * */
public boolean isVideoRecording();

/**
 * Indicates if geolocation experiences are enabled or not
 * */
public boolean isGeolocationEnabled();

/**
 * If enabled, experiences will be shown based on user's geolocation
 * */
public void setGeolocationEnabled(boolean enabled);

/**
 * Indicates if internet connection is available (or not).
 */
public boolean isInternetAvailable();

/**
 * Invoked when internet connection is lost.
 */
public void onInternetNotReachable();

/**
 * Invoked when internet connection has been recovered.
 */
public void onInternetReachable();

/**
 * Enable/Disable device's flash torch (if available).
 * */
public void setFlashTorchMode(boolean on);

/**
 * Invoked when an error occurs and needs to be handled by the application.
 */
public void onError(COAError error);
```

### CamOnAppTargetMode

```Java
// TargetObject mode: default mode. Detects objects and images from a known database of targets
public static final int TARGET_OBJECT

// TargetObjectBundle mode: similar behaviour as TargetObject, but in bundle mode: no internet required at all
public static final int TARGET_OBJECT_BUNDLE

// Targetless mode: start experiences without target detection. Mainly used for 360 & positional experiences
public static final int TARGETLESS

// TargetFace mode: face detection only
public static final int TARGET_FACE
```
### CamOnAppUtils

```Java
/**
 * Init any bundle data (targets and experiences). If the SDK is loaded in TARGET_OBJECT_BUNDLE
 * the first time a load of bundle data will be needed. This may take some time (based on how 
 * many targets and experieces need to be configured). If this method is not called, it will be handled 
 * internally by the SDK the first time it loads (which will make that loading time higher). 
 * */
public static void initBundleData(Context context);

/**
 * Indicates whether the current device supports ARCore
 * */
public static boolean isARCoreSupported(Activity activity);

/**
 * Indicates whether ARCore app is installed in the current device.
 * */
public static boolean isARCoreInstalled(Activity activity);

/**
 * If ARCore is supported and not installed in the current device, it will start the installation
 * flow by asking the user in a series of system provided dialogs.
 * */
public static void checkARCoreAvailability(final Activity activity, final ARCoreAvailabilityCallback callback);
```

### CamOnAppActionListener

```Java
/**
 * A new browser should be opened with the given parameters.
 * */
void onOpenUrlInBrowser(String plainUrl, boolean inExternalBrowser);

/**
 * A new custom schema should be processed with the given data.
 * */
void onProcessCustomSchema(String customSchema, String data);

/**
 * A Facebook profile should be opened with the given parameters.
 * */
void onOpenFacebookProfile(String profileId);

/**
 * A Twitter profile should be opened with the given parameters.
 * */
void onOpenTwitterProfile(String profileId);

/**
 * An Instagram profile should be opened with the given parameters.
 * */
void onOpenInstagramProfile(String profileId);

/**
 * A phone call has been requested with the given parameters.
 * */
void onCallPhoneNumber(String phoneNumber);

/**
 * A SMS should be sent with the given parameters.
 * */
void onSendSMS(String phoneNumber, String message);

/**
 * A Whatsapp should be sent with the given parameters.
 * */
void onSendWhatsapp(String phoneNumber, String message);

/**
 * An email should be sent with the given parameters.
 * */
void onSendEmail(String toAddress, String subject, String body);

/**
 * Adding a new contact to the device contact list has been requested with the given parameters.
 * */
void onAddContact(String firstName, String lastname, String phoneNumber, String organization, String jobTitle, String email, String twitterProfile, String facebookProfile, String skypeProfile);

/**
 * A new Facebook post should be added with the given parameters.
 * */
void onPostInFacebook(String feedMessage, String feedName, String feedCaption, String feedDescription, String feedImageUrl, String feedLink);

/**
 * A new Twitter wall message should be added with the given parameters.
 * */
void onPostInTwitter(String textToShare, String imageUrl);

/**
 * A new Facebook like should be added to the user's preferences with the given parameters.
 * */
void onLikeFacebookPage(String pageId);

/**
 * A new Twitter follow should be added to the user's preferences with the given parameters.
 * */
void onTwitterFollow(String userName);

/**
 * The device store app should be opened with the given app id.
 * */
void onOpenAppStore(String googlePlayId, String appStoreId);

/**
 * An action needs to be done in file in path
 * */
void onProcessFile(String path, String action);
```
