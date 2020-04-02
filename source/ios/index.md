# IOS

## Setup & Configuration

### SDK Integration

#### 1. Load your Xcode project

The first step is to open your current iOS Project. If you don’t have one, you can create a new one using the Xcode Project setup wizard.

#### 2. Adding the CamOnApp SDK Framework

Copy the downloaded CamOnAppSDK.framework into your project. After the CamOnApp SDK Framework was copied into an appropriate location, it can be added using the Linked Frameworks and Libraries panel from your targets General project setting.

#### 3. Configure Build Phases

Add the CamOnAppSDK.framework to the Link Binary with Libraries section like this:

![](/_static/img/ios_setup_1.png)

CamOnApp SDK is distributed with the following archs: armv7, arm64, i386, x86_64. In order to archive your app and upload it to the App Store, the x86 slices of used frameworks need to be removed (otherwise, the app won't be allowed to be uploaded). To accomplish that you will have to create a new Build Phase (under Target -> Build Settings -> New Run Script Phase), and paste the following code into it:

```bash
APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

# This script loops through the frameworks embedded in the application and
# removes unused architectures.
find "$APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
do
FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"

EXTRACTED_ARCHS=()

for ARCH in $ARCHS
do
echo "Extracting $ARCH from $FRAMEWORK_EXECUTABLE_NAME"
lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
done

echo "Merging extracted architectures: ${ARCHS}"
lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
rm "${EXTRACTED_ARCHS[@]}"

echo "Replacing original executable with thinned version"
rm "$FRAMEWORK_EXECUTABLE_PATH"
mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"

done
```

#### 4. Configure Build settings
CamOnApp SDK requires the following configuration within Target's Build Settings:
   * Build Options: Enable Bitcode: No

#### 5. General Settings

In addition to including the CamOnAppSDK.framework in the Build Phases section, make sure it is listed as part of the Embedded Binaries list in the General settings tab for your project:

![](/_static/img/ios_setup_2.png)

#### 6. Vuforia Framework

Repeat steps 2, 3 and 5 in order to include Vuforia.framework (included within our SDK zip bundle).

#### 7. License key setup

You need to have a valid license from CamOnApp in order to complete the setup process. Once obtained, you should edit your app's Info.plist configuration file:
   * Add a new key named “CamOnApp” inside “Information Property List”. The type needs to be “Dictionary”
   * Add the following child keys to it
     * LicenseCloudDb of type "String"
     * LicenseSecretKey of type "String"
     * LicenseUserKey of type "String"

#### 8. Extra changes to Info.plist

One more update needs to be done to the Info.plist file:

   * Add a new key named "App Transport Security Settings" inside “Information Property List”. The type needs to be “Dictionary”
   * Add a child key to it named "Allow Arbitrary Loads" of type "Boolean" and set it to "YES"
   * Add a new key named "NSCameraUsageDescription" inside "Information Propertly List". Set the type as string and provide a reason for using the camera in the application such as "CamOnApp requires the use of the phone's camera"
You should see something like this now:

![](/_static/img/ios_setup_3.png)

#### Supported iOS Devices

CamOnApp SDK is running on devices fulfilling the following requirements:

   * iOS 9.0+
   * iPhone / iPad device family
   * Retina / Non-Retina devices
   * Devices with a capable CPU (armv7, armv7s, arm64)

## Basic Usage

Once configured, the CamOnApp SDK usage is very straightforward:
   * Extend the desired ViewController from COAViewController
   * Override those methods needed to add new/extra functionality (optional)
   * Define a new ActionDelegate and attach it to the ViewController extending COAViewController (optional)

### Extending from COAViewController
```ObjectiveC
  #import <CamOnAppSDK/CamOnAppSDK.h>
  @interface MainViewController : COAViewController
      // Custom interface
  @end
```

### Extending the functionality

COAViewController interface is fully described in the API Section. No method needs to be overriden. Everything will work as expected with the minimum configuration described above.

Some of the features that could be extended/listened to are:

   * Experience Detected
   * Experience Started
   * Etc...

### Defining a custom ActionDelegate

CamOnApp SDK provides a default action delegate (named COADefaultActionDelegate), which provides all the functionality needed for almost every experience callback. As the default action listener implements the COAActionDelegate protocol, there are two options:

   * Create a new class that implements the COAActionDelegate protocol (and implement every method from scratch according to the needs)
   * Create a new class extending COADefaultActionDelegate. This way, only desired methods will have to be overriden.

COADefaultActionDelegate does NOT implement the following methods (they will always have to be implemented):

   * postInFacebook
   * likeFacebookPage
   * postInTwitter
   * followTwitterUser

Once the custom action listener was created (and configured) it will have to be attached to the View Controller:

```ObjectiveC
  - (void) viewDidLoad {
      [super viewDidLoad];
      
      CustomActionDelegate* actionDelegate = [[CustomActionDelegate alloc] initWithViewController:self];
      [self setActionDelegate: actionDelegate];
  }
```

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

   * Add a folder named offline within the Assets group of your project (contents will be provided by the CamOnApp team):

     ![](/_static/img/ios_bundle.png)
     
   * Initialize the bundle data (optional, first run only). Copying and preparing the data to be ready to use by the SDK can take some time (depending on the size of the offline folder itself). That's why there's a method for this called [COAUtils initBundleData]. We recommend to call this method (not mandatory) when the app is being initialized for the first time, otherwise the first time the SDK loads it will take more time than expected.
   * Init the SDK in Bundle Mode by calling: initForBundleMode:
From now on, the SDK will search for known targets installed locally, and once detected, the associated experience will be fired right away.

## Positional Experiences

### Introduction

These are experiences that make it harder to understand the differences between the real and the digital world. Contents are positioned right around the user's location. Here's an ARKit example:
<iframe width="560" height="315" src="https://www.youtube.com/embed/-o7qr1NpeNI" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

### About UX/UI

Positional experiences have a slightly different flow as "normal" experiences. As these experiences need a ground plane where they will be anchored, the user will need to choose where he wants to place them.

For this purpose, CamOnApp's SDK provides an default UI indicating when is a good moment to place an experience (meaning, the user has a ground plane in front of him). If you need to disable this UI in order to provide yours, all you have to do is call disableGroundPlaneHint.

When a positional experience has started, the SDK will trigger the following callbacks:

   * onGroundPlaneFound: there's a ground plane in front of the user. He could tap the screen in order to place the experience.
   * onGroundPlaneLost: the ground plane has been lost. The user will have to find a new one.
   * onAnchorPointCreated: the user has successfuly placed the experience in a ground plane.

## API

### COAViewController

```ObjectiveC
  /**
   Use this constructor to put the simulation in targetless mode:
   - Scanner will not be enabled because experiences do not follow targets
   */
  - (instancetype) initTargetlessMode;

  /**
   Use this constructor to put the simulation in default mode:
   - Cloud recognition is enabled
   - Offline targets are enabled
   */
  - (instancetype) initTargetObjectMode;

  /**
   Use this constructor to put the simulation in bundle mode:
   - Cloud recognition is disabled
   - Offline targets are disabled
   - Targets must be installed manually providing dat/xml/json
   */
  - (instancetype) initTargetObjectBundleMode;

  /**
   Use this constructor to put the simulation in face detection mode
   */
  - (instancetype) initTargetFaceMode;

  /*
   Gets the current device orientation
   */
  - (UIInterfaceOrientation) getCurrentInterfaceOrientation;

  /*
   Indicates if internet connection is available (or not).
   */
  - (BOOL) connectedToInternet;

  /**
   Invoked when internet connectivity has been restored
   */
  - (void) onInternetReachable;

  /**
   Invoked when internet connectivity has been lost
   */
  - (void) onInternetNotReachable;

  /*
   Invoked when the experience started loading
   */
  - (void) onExperienceLoadingStarted;

  /*
   Invoked when the experience ended loading
   */
  - (void) onExperienceLoadingEnded;

  /*
   The detected experience is now running and is being shown to the user.
   This method is always dispatched on the main queue.
   */
  - (void) onExperienceStartedWithInfo:(COAExperienceInfo *)experienceInfo inView:(BOOL)insideView;

  /*
   The execution of the experience has ended. The ViewController is now ready to detect (and execute) a new experience.
   This method is always dispatched on the main queue.
  */
  - (void) onExperienceStopped;

  /*
   The camera has lost (or gained) focus over the target. This method is called every time the focus changes. "inView" will be YES when the target is visible within the camera (NO otherwise).
   This method is always dispatched on the main queue.
   */
  - (void) onExperienceSourceChanged: (BOOL)inView;

  /*
   A new experience has been detected.
   This method is a previous step to onExperienceDetectedWithId and should not affect the main queue.
   */
  - (void) onExperiencePreDetectedWithId:(NSString *)experienceId;

  /*
   A new experience has been detected and a download has been triggered for its contents.
   This method is always dispatched on the main queue.
   */
  - (void) onExperienceDetectedWithId:(NSString *)experienceId;

  /*
   SDK has finished loading, and the camera is now visible. From this moment on, it's safe to
   call any SDK method.
   */
  - (void) onCameraPresented;

  /*
   Informs whether any trackable exists at this time.
   */
  - (BOOL) anyCurrentTrackable;

  /*
   Informs that the last kwnown trackable has been lost.
   */
  - (void) onTrackableLost;

  /*
   Informs that a trackable (of any type) has been found.
   */
  - (void) onTrackableFound;

  /*
   A ground plane has been lost. It's needed in order to place experiences in the ground.
   */
  - (void) onGroundPlaneLost;

  /*
   A ground plane has been found: now the experience can be placed.
   */
  - (void) onGroundPlaneFound;

  /*
   An anchor point has been created: now the experience has been placed successfuly.
   */
  - (void) onAnchorPointCreated;

  /*
   By default, CamOnApp SDK shows a default UI hint for positional experiences.
   This method disables it, in order to provide a custom UI (if needed).
   */
  - (void) disableGroundPlaneHint;

  /*
   Custom events emmited by the experience (via scripting)
   */
  - (void) onCustomEventEmitted: (NSString *) eventName withInfo: (NSString *) eventInfo;

  /*
   Adds custom information to setup the experience (to be used by the scripts inside the experience)
   */
  - (void) setInitialGlobalExperienceData: (NSDictionary *) data;

  /*
   Callback for Custom Scheme
   */
  - (void) onWallpaperReady:(NSString *)wallpaperUri;

  /*
   Indicates whether an experience is currently alive or not.
   */
  - (BOOL) anyExperienceAlive;

  /*
   Indicates whether an experience is currently running or not.
   */
  - (BOOL) anyExperienceRunning;

  /*
   Indicates whether an experience has been detected, even if it's not yet loaded
   */
  - (BOOL) anyExperienceDetected;

  /*
   A new ActionDelegate will be configured for every callback possible within an experience.
   */
  - (void) setActionDelegate: (id) delegate;

  /*
   If enabled, Location permissions will be requested and Location Info will be obtained from LocationManager
   */
  - (void) setGeoLocationEnabled: (BOOL)enabled;

  /*
   Starts the experience matching the given Id.
   This function returns YES if start process ignition was successful, NO otherwise
   */
  - (BOOL) startExperienceWithId: (NSString *) experienceId;

  /*
   Removes the currently running experience
   This function returns YES if remove process ignition was successful, NO otherwise
   */
  - (BOOL) removeCurrentExperience;

  /*
   Removes the currently running experience and leaves scanning mode
   This function returns YES if remove process ignition was successful, NO otherwise
   */
  - (BOOL) removeCurrentExperienceAndLeaveScanningMode;

  /**
   By enabling scanning mode, the SDK will be able to detect targets. Scanning mode is disabled by default.
   */
  - (void) enableScanningMode;

  /**
   Callback called when scanning mode has been enabled.
   */
  - (void) onScanningModeEnabled;

  /**
   Disables scanning mode preventing any target to be detected. This is the default behaviour.
   */
  - (void) disableScanningMode;

  /**
   Callback called when scanning mode has been disabled.
   */
  - (void) onScanningModeDisabled;

  /**
   When scanning mode is enabled, the SDK will try to find known targets for 12 seconds.
   If no target has been found during that time, this callback will be triggered, scanning mode
   will be disabled and it will need to be enabled again (if needed) by calling enableScanningMode().
   */
  - (void) onTargetDetectionTimeoutReached;

  /**
   Invokend when an internal error occurs
   */
  - (void) onErrorWithCode:(COAError) errorCode description:(NSString *)description;

  /*
   Starts a video session recording. Once completed, stopVideoRecording needs to be called.
   */
  - (void) startRecording;

  /*
   Stops the video recording session.
   */
  - (void) stopRecording;

  /*
   This method is called when the recorded movie has been processed and it's ready to play at indicated path
   */
  - (void)onRecordedMovieIsReady:(NSString *)path;

  /*
   This methods allows the SDK to safely close COAViewController (experience flow)
   */
  - (void) safeCloseViewControllerAnimated:(BOOL)animated completion:(void (^ __nullable)(void)) completion;

  /*
   Toggles device's flash torch (if available).
  */
  - (void) toggleFlashTorchMode;

  /*
   Enable/Disable device's flash torch (if available).
  */
  - (void) setFlashTorchMode: (BOOL) on;

  /*
   Indicates whether this device has flash or not.
  */
  - (BOOL) flashIsAvailable;

  /*
   Indicates whether flash is currently active or not.
  */
  - (BOOL) flashIsActive;

  /*
   Call this fuction in flows where you need to go from one MirageViewController to another MirageViewController
   This method makes the necessary deinitialization
  */
  - (void) deinitSDK;
```

### COAUtils

```ObjectiveC
  /*
   Init any bundle data (targets and experiences). If the SDK was initiualized with initTargetObjectBundleMode
   the first time a load of bundle data will be needed. This may take some time (based on how 
   many targets and experieces need to be configured). If this method is not called, it will be handled 
   internally by the SDK the first time it loads (which will make that loading time higher). 
  */
  + (void)initBundleData;

  /*
   Gets the current SDK version.
  */
  + (NSString *)getSDKVersion;
```

### COAActionDelegate

```ObjectiveC
  /*
   A new browser should be opened with the given parameters.
   */
  - (void) openUrlInBrowser: (NSString*) plainUrl withExternalBrowser: (BOOL)inExternalBrowser;

  /*
   A new custom schema should be precessed with the given data.
   */
  - (void) processCustomSchema: (NSString*) customSchema withData: (NSString*)data;

  /*
   A Facebook profile should be opened with the given parameters.
   */
  - (void) openFacebookProfile: (NSString*) profileId;

  /*
   An Instagram profile should be opened with the given parameters.
   */
  - (void) openInstagramProfile: (NSString*) profileId;

  /*
   A Twitter profile should be opened with the given parameters.
   */
  - (void) openTwitterProfile: (NSString*) profileId;

  /*
   A phone call has been requested with the given parameters.
   */
  - (void) callPhoneNumber: (NSString*) phoneNumber;

  /*
   A SMS should be sent with the given parameters.
   */
  - (void) sendSMS: (NSString*) phoneNumber withMessage: (NSString*) message;

  /*
   Adding a new contact to the device contact list has been requested with the given parameters.
   */
  - (void) addContact: (NSString*) firstName lastName: (NSString*)lastName phoneNumber:(NSString*)phoneNumber organization:(NSString*)organization jobTitle:(NSString*)jobTitle email:(NSString*)email twitterProfile:(NSString*)twitterProfile facebookProfile:(NSString*)facebookProfile skypeProfile:(NSString*)skypeProfile;

  /*
   A new Facebook post should be added with the given parameters.
   */
  - (void) postInFacebook: (NSString*) feedMessage name: (NSString*) feedName caption: (NSString*)feedCaption description: (NSString*)feedDescription imageUrl:(NSString*)imageUrl link:(NSString*)feedLink;

  /*
   A new Facebook like should be added to the user's preferences with the given parameters.
   */
  - (void) likeFacebookPage: (NSString*) pageId;

  /*
   A new Twitter wall message should be added with the given parameters.
   */
  - (void) postInTwitter: (NSString*) textToShare imageUrl:(NSString*)imageUrl;

  /*
   A new Twitter follow should be added to the user's preferences with the given parameters.
   */
  - (void) followTwitterUser: (NSString*) userName;

  /*
   An email should be sent with the given parameters.
   */
  - (void) sendEmail: (NSString*) addressTo withSubject: (NSString*)subject body:(NSString*)body;

  /*
   The device store app should be opened with the given app id.
   */
  - (void) openAppInStore: (NSString*) appstoreId googlePlay:(NSString*)googlePlayId;

  /*
   A Whatsapp should be sent with the given parameters.
   */
  - (void) sendWhatsapp: (NSString*) phoneNumber withMessage: (NSString*)message;
```

## Libraries included

The following open source libraries are used within the iOS SDK:

  * Reachability
  * GPUImage
  * Curl
  * LibPng
  * LibZip
  * Lua
  * Crimild
  * JsonCpp
  * RapidXml
  * Sol
  * SQLiteCpp
