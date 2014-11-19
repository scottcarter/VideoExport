//
//  ViewController.swift
//  VideoExport
//
//  Created by Scott Carter on 9/19/14.
//  Copyright (c) 2014 Scott Carter. All rights reserved.
//

import UIKit

import AssetsLibrary
import MediaPlayer
import AVFoundation
import MobileCoreServices



// UIImagePickerController requires both UINavigationControllerDelegate & UIImagePickerControllerDelegate
// protocols.
//
class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    // ==========================================================================
    // Properties
    // ==========================================================================
    //
    // MARK: -
    // MARK: Properties
    
    @IBOutlet weak var movieView: UIView!

    
    // Constraints we can reference for movieView
    // 
    // Note: When we establish constraints we uncheck "Relative to margin" for first and second
    // item of constraint, i.e. we don't make constraint relative to a container margin.
    @IBOutlet weak var topVerticalSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftHorizontalSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightHorizontalSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomVerticalSpaceConstraint: NSLayoutConstraint!
    

    // Reference for our toolbar that we can use to get its height
    //
    @IBOutlet weak var toolbar: UIToolbar!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // An array of our toolbar buttons.   For the device this includes Camera and Library buttons.
    // On the simulator (which doesn't provide camera support) it only includes the Library button.
    var initialToolbarItems: [UIBarButtonItem]!
    
    
    // Property that we use to record height of status bar.
    var statusBarHeight: CGFloat!
    
    
    var imagePickerController: UIImagePickerController!
    
    // From UIImagePickerController, initialized in processLibraryMovie, processCameraMovie
    var videoURL: NSURL!
    
    // Formed from videoURL
    var videoAsset: AVAsset!
    
    var assetsLibrary: ALAssetsLibrary!
    
    var player: MPMoviePlayerController!
    
    
    
    // ==========================================================================
    // Actions
    // ==========================================================================
    //
    // MARK:  -
    // MARK:  Actions
    
    
    // User touched button to show the camera
    func cameraAction() -> Void {
        
        // Pause any currently running playback.
        self.player?.pause()
        
    
        // Note that there is a known issue in iOS 8 that causes a warning whenever
        // UIImagePickerController is used with the Camera:
        //
        // "Snapshotting a view that has not been rendered results in an empty snapshot. 
        //  Ensure your view has been rendered at least once before snapshotting or snapshot 
        //  after screen updates."
        //
        // Reference:
        // http://stackoverflow.com/questions/25884801/ios-8-snapshotting-a-view-that-has-not-been-rendered-results-in-an-empty-snapsho?lq=1
        //
        self.showImagePickerForSourceType(.Camera)
        
    }
    
    
    // User will be selecting a movie from the photo library
    @IBAction func libraryAction(sender: UIBarButtonItem) {
        
        // Pause any currently running playback.
        self.player?.pause()
        
        showImagePickerForSourceType(.PhotoLibrary)
    }
    
    
    // Save asset as MP4 to Camera roll.  This method (and associated button) is available when a movie
    // is loaded from the Library.  The button to save is not available after taking a new
    // movie since new movies are automatically saved to the Camera Roll.
    //
    func saveAction() -> Void {
        
        // Pause any currently running playback.
        self.player?.pause()
        
        // Start activity indicator
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        
        
        // Provide a callback closure to exportAsset() to be executed on successful
        // completion of export and save to Camera Roll.
        var closure: (NSURL) -> Void = {NSURL in  }
        
        
        // We don't wish to reference self strongly inside closure, so specify
        // [unowned self]
        closure = {[unowned self] assetURL in
            // Disable activity indicator
            self.activityIndicator.stopAnimating()
        }
        
        exportAsset(closure)
        
    }
    
    
    // ==========================================================================
    // Initializations
    // ==========================================================================
    //
    // MARK:  -
    // MARK:  Initializations
    
    
    deinit {
        // Stop observing notifications.
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Not currently using this notification.  Here for illustrative purposes.
    func moviePlayerPlaybackDidFinishNotification(notification: NSNotification) -> Void {
        var notif: NSDictionary! = notification.userInfo
        
        // SNLog.info("\(notif)")
    }
    

    // Movie player is about to exit full screen mode.  This is our opportunity to make
    // any frame adjustments.
    func moviePlayerWillExitFullscreenNotification(notification: NSNotification) -> Void {
        
        var notif: NSDictionary! = notification.userInfo
        
        // SNLog.info("\(notif)")
        
        
        // We set the frame for our movie player in viewDidLayoutSubviews, so
        // it isn't strictly necessary to do so here in order to get the size correct.
        //
        // We would however like a smooth transition when exiting fullscreen mode.  Why is this a concern?
        // Consider the case where we enter full screen mode while in Portrait.  The user then
        // rotates to Landscape and then exits full screen mode.  Without any adjustments here,
        // self.movieView will automatically adjust according to the constraints we set and self.player will be
        // updated in viewDidLayoutSubviews - causing a noticeable jump in the transition.
        //
        // To ensure a smooth transition in all cases, we update the frames of our movieView and player in this method
        // accounting for the current orientation, prior to exiting full screen mode
        //
        var currentViewWidth: CGFloat =  self.view.bounds.size.width
        var currentViewHeight: CGFloat = self.view.bounds.size.height
        
        
        let orientation: UIDeviceOrientation = UIDevice.currentDevice().orientation
        
        
        var statusBarHeight: CGFloat
        
        
        if (orientation == .Portrait || orientation == .PortraitUpsideDown) {
            statusBarHeight = self.statusBarHeight // Set in viewDidLayoutSubviews
        }
        else { // Landscape or Face down
            statusBarHeight = 0.0 // Status bar not present in landscape mode (iOS 8)
        }
        
        
        
        // Determine the new dimensions of self.movieView which the movie player will fit into.
        //
        var movieViewWidth: CGFloat = currentViewWidth - self.leftHorizontalSpaceConstraint.constant - self.rightHorizontalSpaceConstraint.constant
        var moviewViewHeight: CGFloat = currentViewHeight - self.topVerticalSpaceConstraint.constant - self.bottomVerticalSpaceConstraint.constant - statusBarHeight - self.toolbar.bounds.size.height
        
        
        
        // Adjust the player's frame.  The origin doesn't change.
        var playerViewRect: CGRect = CGRectMake(0.0, 0.0, movieViewWidth, moviewViewHeight)
        self.player.view.frame = playerViewRect
        
        // Adjust the movieView's frame.  The y coordinate is the height of the status bar.
        var moviewViewRect: CGRect = CGRectMake(0.0, statusBarHeight, movieViewWidth, moviewViewHeight)
        self.movieView.frame = moviewViewRect
        
    }
    

    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    
        // Cleanup the tmp directory on each launch.
        //
        // Reference:
        // http://stackoverflow.com/questions/9196443/how-to-remove-tmp-directory-files-of-an-ios-app
        //
        var fileManager: NSFileManager = NSFileManager.defaultManager()
        var tmpDirectoryContents: [String] = fileManager.contentsOfDirectoryAtPath(NSTemporaryDirectory(), error: nil) as [String]
        
        for file in tmpDirectoryContents {
            //var path: String = NSString(format: "%@%@", NSTemporaryDirectory(),file)
            var path: String = NSTemporaryDirectory() + file
            
            fileManager.removeItemAtPath(path, error: nil)
        }
        
        
        self.assetsLibrary = ALAssetsLibrary()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerPlaybackDidFinishNotification:", name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moviePlayerWillExitFullscreenNotification:", name: MPMoviePlayerWillExitFullscreenNotification, object: nil)
        
        
        // If we are on device, include Camera button
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            
            // Simulator
            
            #else
            
            // Device
            
            let toolbarItems: [UIBarButtonItem] =  self.toolbar.items as [UIBarButtonItem]
            
            // New items to add
            var flexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
            var camera: UIBarButtonItem = UIBarButtonItem(title: "Camera", style: .Plain, target: self, action: "cameraAction")
            
            // Set all toolbar items
            self.toolbar.setItems([flexSpace, camera] + toolbarItems, animated: false)
            
        #endif
        
        
        // Record initial set of toolbar items
        self.initialToolbarItems = self.toolbar.items as [UIBarButtonItem]
        
    }
    
    
    
    
    
//    // Replaces willRotateToInterfaceOrientation:duration:
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        let transitionToWide = size.width > size.height
//        
//        SNLog.info("transitionToWide=\(transitionToWide)")
//        
//    }
    
    
    
    override func viewDidLayoutSubviews() {
        
        // SNLog.info("")
        
        // Let's record status bar height for later use.  
        // http://stackoverflow.com/questions/12991935/how-to-programmatically-get-ios-status-bar-height
        //
        // Prior to iOS 8 it didn't change with orientation.
        // For apps targeting iOS 8, the status bar now disappears on a rotate to landscape mode.
        //
        // The height is 20 points, but can also change during an incoming phone call or audio session.
        // After a transition to full screen video, the status bar height is 0.
        //
        // We will capture the height of the status bar while in Portrait orientation on the first 
        // invocation of viewDidLayoutSubviews()  In order to ensure that this is the initial orientation,
        // we will make Portrait the first element in the UISupportedInterfaceOrientations array in Info.plist.
        // Note that according to the docs, when UISupportedInterfaceOrientations is used, any presence of 
        // UIInterfaceOrientation (an alternate way to specify initial orientation) in Info.plist is ignored.
        //
        //
        if self.statusBarHeight == nil {
            let statusBarSize: CGSize = UIApplication.sharedApplication().statusBarFrame.size
            
            // We capture the height as the minimum of statusBarSize.width, statusBarSize.height
            // During orientation changes, the true status bar height isn't always statusBarSize.height.
            // 
            // In this particular case, it would have been safe to just use statusBarSize.height
            self.statusBarHeight = statusBarSize.width < statusBarSize.height ? statusBarSize.width : statusBarSize.height
            
            // SNLog.info("statusBarSize=\(statusBarSize)  self.statusBarHeight=\(self.statusBarHeight)")
        }
        
        // Update our movie player frame in the event that we rotated.
        if(self.player != nil){
            self.player.view.frame  = self.movieView.bounds
        }
        
    }
    
    

    
    // ==========================================================================
    // Protocol methods
    // ==========================================================================
    //
    // MARK:  -
    // MARK:  Protocol methods
    
    // MARK: UIImagePickerControllerDelegate
    
    
    // Completed capturing or selecting movie
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
            let sourceType: UIImagePickerControllerSourceType  = self.imagePickerController.sourceType
            self.imagePickerController = nil
            
            
            // SNLog.info("info = \(info)")
            
            /* Example of info dictionary:
            
            [UIImagePickerControllerMediaType: public.movie,
            UIImagePickerControllerReferenceURL: assets-library://asset/asset.MOV?id=042ED310-0320-403D-A194-6810B953362E&ext=MOV,
            UIImagePickerControllerMediaURL: file:///private/var/mobile/Containers/Data/Application/332AE4BB-0CB4-4CD8-871F-BA31A1BF08EC/tmp/trim.EE23B54E-E440-4F3D-AC4B-D687474DE6D6.MOV]
            */
            
            
            let mediaType: String = info[UIImagePickerControllerMediaType] as NSString
            
            
            // Movie
            if mediaType == kUTTypeMovie as NSString {
                
                // Start activity indicator
                self.activityIndicator.hidden = false
                self.activityIndicator.startAnimating()
                
                // Camera movie
                if sourceType == .Camera {
                    //SNLog.info("Movie type.  Taken by Camera.")
                    
                    // Restore our initial set of Toolbar buttons, which will remove Save button if present.
                    self.restoreInitialButtonItems()
                    
                    self.processCameraMovie(info)
                }
                    
                    // Movie picked from Library   .SavedPhotosAlbum | .PhotoLibrary
                else {
                    //SNLog.info("Movie type.  Picked from Library.")
                    
                    self.addSaveButton() // Add Save button if not present
                    
                    self.processLibraryMovie(info)
                }
                
                return
            }
            
            
            assertionFailure("Unhandled mediaType")
            
            
        }) // dismissViewControllerAnimated(true, completion: { () -> Void in
        
    }

    
    
    // ==========================================================================
    // Class methods
    // ==========================================================================
    //
    // MARK:  -
    // MARK: Class methods
    
    
    // MARK:  General methods
    
    // Main thread
    func playMovie(assetURL: NSURL) -> Void {
        
        // Important to remove previous player from super view if it exists.
        if(self.player != nil){
            self.player.view.removeFromSuperview()
            self.player = nil
        }



        self.player = MPMoviePlayerController(contentURL: assetURL)
        
        self.player.view.frame = self.movieView.bounds  // player's frame must match parent's bounds
        
        self.movieView.addSubview(self.player.view)
        
        
        self.player.scalingMode = .AspectFit
        
        //self.player.fullscreen = true
        
        self.player.play()
        
    }

    
    // Just captured a new movie.  Export as MP4 to Camera Roll and then begin playback.
    func processCameraMovie(movieInfo: NSDictionary) {
    
        // Save this to stored property so that it can later be accessed by exportAsset()
        self.videoURL = movieInfo[UIImagePickerControllerMediaURL] as NSURL
    
        // Must use a stored property for videoAsset or else loadValuesAsynchronouslyForKeys will sometimes not 
        // call its completion handler.
        self.videoAsset = AVURLAsset(URL: self.videoURL, options: nil)
    
        
        // Provide a callback closure to exportAsset() to be executed on successful
        // completion of export and save to Camera Roll.
        var closure: (NSURL) -> Void = {NSURL in  }
        
        // We don't wish to reference self strongly inside closure, so specify
        // [unowned self]
        closure = { [unowned self] assetURL in
            
            // Disable activity indicator
            self.activityIndicator.stopAnimating()
            
            // Automatically start playing movie after export and save to Camera Roll
            self.playMovie(assetURL)
        }

        
        // Load some keys for videoAsset.  Currently only using duration with a
        // newly taken movie - see getVideoComposition() which is called via exportAsset()
        let keysToLoad: [String] = ["commonMetadata","duration", "creationDate"]
        
        self.videoAsset.loadValuesAsynchronouslyForKeys(keysToLoad, completionHandler: { () -> Void in
            
            // Completion handler is not called on the main thread, so we need the following dispatch.
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                self.exportAsset(closure)
            })
        })
        
    
    }
    
    
    
    

    

    // User selected movie from Library.  Load and begin playback.
    func processLibraryMovie(movieInfo: NSDictionary) -> Void {
    
        // URL for asset in Library
        // Ex: assets-library://asset/asset.MOV?id=042ED310-0320-403D-A194-6810B953362E&ext=MOV
        let assetURL: NSURL = movieInfo[UIImagePickerControllerReferenceURL] as NSURL
        
        // URL for .MOV file in file system
        // Ex: file:///private/var/mobile/Containers/Data/Application/332AE4BB-0CB4-4CD8-871F-BA31A1BF08EC/tmp/trim.EE23B54E-E440-4F3D-AC4B-D687474DE6D6.MOV
        //
        // Save this to stored property so that it can later be accessed by exportAsset() in case we save.
        self.videoURL = movieInfo[UIImagePickerControllerMediaURL] as NSURL
        
    
        // SNLog.info("assetURL=\(assetURL)  self.videoURL=\(self.videoURL)")
        
        
        // Failure block for following asset fetch
        let assetFailure = { (assetError: NSError!) -> (Void) in
            SNLog.error("\(assetError)")
            Void()
        }
        
    
        // Get ALAsset from URL.  Perform this in main thread.
        //
        self.assetsLibrary.assetForURL(assetURL, resultBlock: { (asset) -> Void in
            
            // This creation date is when asset was saved to Camera Roll.  It is the preferred means to get this date.
            //
            // Compare to processLibraryMovie_1 where we use videoAsset.creationDate which incorrectly reflects
            // the current date for some movie file types.
            //
            SNLog.info("asset=\(asset)  created: \(asset.valueForProperty(ALAssetPropertyDate))")
            
            
            // The meta data obtained from ALAssetRepresentation here is empty for a movie.
            // In the method processLibraryMovie_1 we show how to correctly get meta data.
            let assetRepresentation: ALAssetRepresentation = asset.defaultRepresentation()
            
            let metaDataDict: NSDictionary = assetRepresentation.metadata()
            // SNLog.info("metaDataDict=\(metaDataDict)")
            
            self.processLibraryMovie_0()
            
        }, failureBlock: assetFailure)
        
    }
    
    
    // Called by processLibraryMovie after we load movie asset.
    func processLibraryMovie_0() -> Void {
        
        // Must use a stored property for videoAsset or else loadValuesAsynchronouslyForKeys will sometimes not
        // call its completion handler.
        self.videoAsset = AVURLAsset(URL: self.videoURL, options: nil)
        
        
        
        // Load the values of any of the specified keys that are not already loaded.
        //
        // Apart from printing info for commonMetadata, duration and creationDate, 
        // we also use duration in getVideoComposition() which is called via exportAsset()
        let keysToLoad: [String] = ["commonMetadata","duration", "creationDate"]
        
        self.videoAsset.loadValuesAsynchronouslyForKeys(keysToLoad, completionHandler: { () -> Void in
            
            // Completion handler is not called on the main thread, so we need the following dispatch.
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                self.processLibraryMovie_1()
            })
        })
        
    }
    
    
    
    // Called by processLibraryMovie_0 after we have loaded specified keys of the video asset.
    //
    func processLibraryMovie_1() {
        
        // All metadata (key, keySpace nil)
        let metadata : [AVMetadataItem] = AVMetadataItem.metadataItemsFromArray(self.videoAsset.commonMetadata, withKey: nil, keySpace: nil) as [AVMetadataItem]
        
    
        SNLog.info("AVAsset metadata = \(metadata)")
        
    
        let durationSeconds: Float64 = CMTimeGetSeconds(self.videoAsset.duration)
        SNLog.info("durationSeconds=\(durationSeconds)")
    
        // This creation date is not preferred.  I noted that with some movie types (.MP4, .AVI) it appears to
        // incorrectly reflect the current date, not the date asset was saved to Camera roll.
        SNLog.info("creationDate=\(self.videoAsset.creationDate)")
       
        // Disable activity indicator
        self.activityIndicator.stopAnimating()
        
        playMovie(self.videoURL)
    }
    
 
    
    
    // Display UIImagePickerController interface to either capture a movie or select an existing one.
    //
    func showImagePickerForSourceType (sourceType: UIImagePickerControllerSourceType) -> Void {
        
        var imagePickerController: UIImagePickerController = UIImagePickerController()
        
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .CurrentContext
        
        
        // Only allowing movies to be taken or selected.
        //
        // Need to unwrap kUTTypeMovie or else a run time error occurs:
        // fatal error: array element cannot be bridged to Objective-C
        //
        // http://stackoverflow.com/questions/24981695/uiimagepickercontroller-and-fatal-error-array-element-cannot-be-bridged-to-obje
        imagePickerController.mediaTypes = [kUTTypeMovie!]
        
        
        if (sourceType == .Camera) {
            
            // Choose front or back facing camera.
            // When showsCameraControls = YES, this can set which camera view appears first. Rear facing camera by default.
            //
            // imagePickerController.cameraDevice = .Front
            
            
            // Default is .Photo
            imagePickerController.cameraCaptureMode = .Video
            
            // imagePickerController.allowsEditing = true  // Default = false
            // imagePickerController.showsCameraControls = false // Default = true
            
            imagePickerController.videoMaximumDuration = 30 // 30 seconds max
            
            
            // Record movie in 640 x 480.  Other options are:
            // .TypeHigh      1920 x 1080 (ratio = 16:9)
            // .TypeMedium    480 x 360 (ratio = 4:3)
            // .TypeLow       192 x 144
            //
            imagePickerController.videoQuality = .Type640x480  // 640 x 480  (ratio = 4:3)
        }
            
        else if(sourceType == .PhotoLibrary) {
            
            // Compress selected movie to 640 x 480 (4:3 source) or 640 x 360 (16:9 source)
            //
            // Note: Compressing a High quality source takes a long time no matter whether Library picker is set
            //       for High, 640x480 or Medium.
            //
            imagePickerController.videoQuality = .Type640x480
        }
            
        else {
            assertionFailure("ERROR with sourceType")
        }
        
        
        self.imagePickerController = imagePickerController
        
        
        presentViewController(self.imagePickerController, animated: true, completion: nil)
        
    }
    
    
    // MARK:  Export related
    
    // We do 2 things here:
    //
    // 1. Flip width/height when the preferred transform has a rotation of 90 or 270 degrees.
    // 2. Adjust resolution to be no greater than 512 x 288 (16:9) or 480 x 360 (4:3).
    //    If not one of these ratios, use square and not greater than 360.
    //    If min dimension is less than 360, use next lower dimension that is a factor of 8.
    //
    func adjustVideoSize(videoSize: CGSize, videoAsset: AVAsset) -> CGSize {
        
        var widthToWrite: CGFloat = videoSize.width
        var heightToWrite: CGFloat = videoSize.height
        
        let isRotated90_270: Bool = isVideoRotated90_270(videoAsset)
        
        // Flip width/height for a 90 or 270 degree rotation.
        if isRotated90_270  {
            widthToWrite = videoSize.height
            heightToWrite = videoSize.width
        }
        
        // Update videoSize
        var newVideoSize = CGSizeMake(widthToWrite, heightToWrite)
        
        
        // Adjust resolution
        //
        newVideoSize = adjustVideoResolution(newVideoSize)
        
        return newVideoSize
    }
    
    
    // Helper for adjustVideoSize:videoAsset:
    //
    func adjustVideoResolution(videoSize: CGSize) ->CGSize {
        
        var width: CGFloat = videoSize.width
        var height: CGFloat = videoSize.height
        
        
        // At this point width and height are proper for an export rotation of 0 degrees
        // (height > width for Portrait)
        //
        // Swap width and height (temporarily) if height > width
        // We want width as larger dimension for our calculations.
        //
        // We will swap back width/height for Portrait at the end of this method after getting new
        // dimensions.
        var portrait: Bool = false
        
        if(height > width){
            portrait = true
            width = videoSize.height
            height = videoSize.width
        }
        
        // Reference:
        //
        // http://download.macromedia.com/flashmediaserver/mobile-encoding-android-v2_7.pdf
        //
        // Initialize arrays of lower dimensions for 16:9 ratio that are evenly divisible by 8
        // AND where that dimension multipled by 16/9 is also evenly divisible by 8.
        // For the largest array element we use 288 since we don't use a dimension larger than 512 x 288
        //
        let lowerDimensionArr_16_9: [CGFloat] = [288.0, 216.0, 144.0, 72.0]
        
        
        
        // Initialize arrays of lower dimensions for 4:3 ratio that are evenly divisible by 8
        // AND where that dimension multipled by 4/3 is also evenly divisible by 8.
        // For the largest array element we use 360 since we don't use a dimension larger than 480 x 360
        //
        // Note: Skipping bad entries in article: 288 x 256 (not 4:3)
        //
        let lowerDimensionArr_4_3: [CGFloat] = [360.0, 336.0, 312.0, 288.0, 264.0, 240.0, 192.0, 168.0, 144.0, 120.0, 96.0, 72.0, 48.0, 24.0]
        
        
        
        // 16:9
        if width == (height * 16.0 / 9.0) {
            SNLog.info("16:9")
            if width >= 512.0 {
                width = 512.0
                height = 288.0
            }
            else {
                // Scale height down to a multiple of 8.  Will already be < 288.0 here.
                height = adjustDownToMultipleOf8(dimension: height, lowerDimensionArr: lowerDimensionArr_16_9)
                width = height * 16.0 / 9.0
            }
        }
            
            // 4:3
        else if width == (height * 4.0 / 3.0) {
            SNLog.info("4:3")
            if(width >= 480.0){
                width = 480.0
                height = 360.0
            }
            else {
                // Scale height down to a multiple of 8.  Will already be < 360.0 here.
                height = adjustDownToMultipleOf8(dimension: height, lowerDimensionArr: lowerDimensionArr_4_3)
                width = height * 4.0 / 3.0
            }
        }
            
            // Not 16:9 (1.77) or 4:3 (1.33)
            //
            // Scale down in order of priority to:
            // 16:9 (with height <= 288),
            // 4:3 (with height <=360),
            // square (with dimension <= 360)
        else {
            SNLog.info("Not 16:9 or 4:3")
            
            if width > (height * 16.0 / 9.0) {
                SNLog.info("Scale down to 16:9")
                height = adjustDownToMultipleOf8(dimension: height, lowerDimensionArr: lowerDimensionArr_16_9)
                width = height * 16.0 / 9.0
            }
            else if width > (height * 4.0 / 3.0) {
                SNLog.info("Scale down to 4:3")
                height = adjustDownToMultipleOf8(dimension: height, lowerDimensionArr: lowerDimensionArr_4_3)
                width = height * 4.0 / 3.0
            }
            else {
                SNLog.info("Scale down to square")
                height = adjustDownToMultipleOf8(dimension: height, lowerDimensionArr: lowerDimensionArr_4_3)
                width = height
            }
        }
        
        
        // Need to swap width/height of new dimensions for Portrait.
        // Prior calculations were done always assuming width > height.
        if portrait {
            return CGSizeMake(height, width)
        }
        else {
            return CGSizeMake(width, height)
        }
        
    }
    
    
    
    // Return a dimension that is less than or equal to maxDimension (first element of lowerDimensionArr)
    // and a member of lowerDimensionArr.
    //
    // If dimension < lowest value element in lowerDimensionArr (last element), then return last element.
    //
    func adjustDownToMultipleOf8(#dimension: CGFloat, lowerDimensionArr: [CGFloat]) -> CGFloat {
        if dimension >= lowerDimensionArr[0] {
            return lowerDimensionArr[0]
        }
        
        for i in 0..<lowerDimensionArr.count {
            if dimension >= lowerDimensionArr[i]  {
                return lowerDimensionArr[i]
            }
        }
        
        
        return lowerDimensionArr.last! // last returns an optional type.  Need to unwrap.
    }
    
    
    

    

    
    
    // Export movie as MP4 to temporary directory, and then save to Camera Roll
    // in folder "VideoExport"
    //
    func exportAsset(callback: (assetURL: NSURL) -> Void) -> Void {
        
        // self.videoURL was previously set when we loaded movie from Library
        let videoAsset: AVAsset = AVURLAsset(URL: self.videoURL, options: nil)
        
        // Temporary output path for MP4 file export before we save to Camera Roll.
        let exportPath: String = NSTemporaryDirectory() + "export.mp4"
        
        SNLog.info("exportPath=\(exportPath)")
        
        // Make sure file doesn't already exist.
        NSFileManager.defaultManager().removeItemAtPath(exportPath, error: nil)
        
        
        let outputURL: NSURL = NSURL(fileURLWithPath: exportPath)!
        
        
        let videoTrack: AVAssetTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo).first as AVAssetTrack
        
        
        
        // The naturalSize should be no greater than 640 x 480 as we selected in
        // showImagePickerForSourceType() for UIImagePickerController
        var videoSize: CGSize = videoTrack.naturalSize
        
        SNLog.info("videoTrack.naturalSize:  size.width = \(videoSize.width) size.height = \(videoSize.height)")
        
        
        // Using SDAVAssetExportSession
        // https://github.com/rs/SDAVAssetExportSession
        //
        let encoder: SDAVAssetExportSession = SDAVAssetExportSession(asset: videoAsset)
        
        
        // Adjust videoSize for dimensions and orientation.
        // We will need to swap width/height for rotations of 90 or 270 degrees and possibly reduce dimensions.
        videoSize = adjustVideoSize(videoSize, videoAsset: videoAsset)
        
        
        let widthToWrite: CGFloat = videoSize.width
        let heightToWrite: CGFloat = videoSize.height
        
        SNLog.info("widthToWrite=\(widthToWrite)  heightToWrite=\(heightToWrite)")
        
        
        // Get a video composition that includes the scaling/cropping needed to fit in videoSize
        encoder.videoComposition = getVideoComposition(videoAsset, videoSize: videoSize)
        
        
        // encoder.audioMix =
        
        encoder.outputFileType = AVFileTypeMPEG4  // MP4 format
        
        encoder.outputURL = outputURL
        
        
        
        // Specific video settings for encoding
        encoder.videoSettings = [
            AVVideoCodecKey: AVVideoCodecH264,
            
            AVVideoWidthKey: widthToWrite,
            AVVideoHeightKey: heightToWrite,
            
            AVVideoCompressionPropertiesKey: [
                
                AVVideoAverageBitRateKey: 725000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264Baseline30,
            ],
        ]
        
        
        // Specific audio settings for encoding
        encoder.audioSettings = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVNumberOfChannelsKey: 1, // Mono
            AVSampleRateKey: 44100,
            AVEncoderBitRateKey: 64000,
        ]
        
        
        
        encoder.shouldOptimizeForNetworkUse = true
        
        
        
        // Add some custom meta data
        //
        
        // Create new data for AVMetadataCommonKeyAuthor illustrating how to add JSON info.
        let jsonDict: Dictionary<String, String> = ["id":"8923367945771", "t":"1400696865"]
        let jsonData:NSData = NSJSONSerialization.dataWithJSONObject(jsonDict, options: .PrettyPrinted, error: nil)!
        let jsonStr: NSString = NSString(data: jsonData, encoding: NSUTF8StringEncoding)!
        
        
        // New AVMutableMetadataItem for added values
        var mi: AVMutableMetadataItem = AVMutableMetadataItem()
        
        // Array for updated Metadata
        var updatedMetadata: [AVMutableMetadataItem] = []
        
        
        // Add our custom key values.   Not all values can be added.  I've identified
        // title, description and author as some keys we can write.
        //
        mi.key = AVMetadataCommonKeyTitle
        mi.keySpace = AVMetadataKeySpaceCommon
        mi.value = "*** My Custom Title ***"
        updatedMetadata.append(mi)
        
        
        mi = AVMutableMetadataItem()
        mi.key = AVMetadataCommonKeyAuthor
        mi.keySpace = AVMetadataKeySpaceCommon
        mi.value = jsonStr  // Our custom JSON data
        updatedMetadata.append(mi)
        
        
        mi = AVMutableMetadataItem()
        mi.key = AVMetadataCommonKeyDescription
        mi.keySpace = AVMetadataKeySpaceCommon
        mi.value = "*** My Custom Description ***"
        updatedMetadata.append(mi)
        
        encoder.metadata = updatedMetadata
        
        
        // Export to temp directory as MP4
        encoder.exportAsynchronouslyWithCompletionHandler { () -> Void in
            if encoder.status == .Completed {
                SNLog.info("Video export succeeded")
                
                
                /*
                Save to a named photo album
                
                References:
                
                iOS5: Saving photos in custom photo album (+category for download)
                http://www.touch-code-magazine.com/ios5-saving-photos-in-custom-photo-album-category-for-download/
                
                Grab code from here!
                https://github.com/Kjuly/ALAssetsLibrary-CustomPhotoAlbum
                
                ALAssetsLibrary+CustomPhotoAlbum.h/.m
                
                See discussion here also:
                http://stackoverflow.com/questions/10954380/save-photos-to-custom-album-in-iphones-photo-library
                
                */

                self.assetsLibrary.saveVideo(outputURL, toAlbum: "VideoExport", completion: { (assetURL, error) -> Void in
                    if error != nil {
                        SNLog.error("saveVideo completion block: \(error)")
                    }
                    else {
                        SNLog.info("Completed saving video")
                        
                        
                        dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                            
                            // https://github.com/TransitApp/SVProgressHUD
                            SVProgressHUD.showSuccessWithStatus("Saved to Camera Roll!")
                            
                            callback(assetURL: assetURL)
                        })
                    }
                    
                    }, failure: { (error) -> Void in
                        SNLog.error("saveVideo failure block: \(error)")
                        Void()
                })
                
            } // encoder.status == .Completed
                
            else if encoder.status == .Cancelled {
                SNLog.info("Video export cancelled")
            }
                
            else {
                SNLog.error("Video export failed with error: \(encoder.error.localizedDescription) (\(encoder.error.code))")
            }
            
            
        } // encoder.exportAsynchronouslyWithCompletionHandler
        
        
    }
    

    
    
    // References:
    //
    // See code samples by Prince, BornCoder
    // http://stackoverflow.com/questions/12136841/avmutablevideocomposition-rotated-video-captured-in-portrait-mode
    //
    func getVideoComposition(asset: AVAsset, videoSize: CGSize) -> AVMutableVideoComposition {
        
        var videoTrack: AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo).first as AVAssetTrack
        
        var videoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        
        var isRotated90_270: Bool = isVideoRotated90_270(asset)
        
        
        // If the aspect ratio of videoSize is different than that of videoTrack.naturalSize
        // (after accounting for possible swap of width/height of videoTrack.naturalSize for 90/270 rotation) than setting
        // the videoComposition.renderSize will crop.
        //
        // If for example our original aspect ratio was non-standard and less than 4:3, 
        // we would force a square - see adjustVideoResolution().   This will cause a crop showing 
        // the upper left portion of the video that fits in the new size.
        videoComposition.renderSize = videoSize
        
        
        // Alternative to using CMTimeMakeWithSeconds
        // videoComposition.frameDuration = CMTimeMake(1, 30)
        
        var seconds: Float64 = Float64(1.0 / videoTrack.nominalFrameRate)
        videoComposition.frameDuration = CMTimeMakeWithSeconds( seconds, 600);
        
        
        SNLog.info("frameDuration value = \(videoComposition.frameDuration.value)  frameDuration timescale = \(videoComposition.frameDuration.timescale)  nominalFrameRate = \(videoTrack.nominalFrameRate)")
        
        
        var videolayerInstruction: AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        
        // We scale width and height by the same amount to avoid distortion
        var scaleFactor: CGFloat!
        
        
        // If we crop to a square, apply a transform in either x or y direction to center video.
        var translationTransform: CGAffineTransform!
        
        
        // Get the original width and height that we would have if the rotation were 0 (or 180) degrees.
        // We derive this from videoTrack.naturalSize
        var originalWidth: CGFloat = isRotated90_270 ? videoTrack.naturalSize.height : videoTrack.naturalSize.width
        var originalHeight: CGFloat = isRotated90_270 ? videoTrack.naturalSize.width : videoTrack.naturalSize.height
        
        // Scale video for Portrait
        //
        if(originalHeight > originalWidth) {
            
            // Does it matter whether we base scaleFactor on width or height?  Yes!
            // If we resize to a square we do not want to scale the width lower than 
            // videoSize.width. We want the original video width content to be fully visible in the new dimensions and
            // the original video height content truncated.
            //
            // Example:  We resize to 360 x 360 from 360 x 640.  We want the scaleFactor to be 360/360 = 1.0
            //           If we instead scaled by 360 (new height)/640 (orig height) = 0.5625 then in the new video
            //           the width has a black border on one side and the height content is fully visible (no truncation).
            //
            scaleFactor = videoSize.width/originalWidth
            
            // If we need to center for Portrait because we are cropping, shift up by half the 
            // height of scaled video.
            translationTransform  = CGAffineTransformMakeTranslation(0, -1.0 * videoSize.height/2.0)
        }
        
        else {
            // For Landscape we want to scale by height.  The reason is similar to why we used width above
            // in choosing a scale factor for Portrait.
            scaleFactor = videoSize.height / originalHeight
            
            // If we need to center for Landscape because we are cropping, shift left by half the 
            // width of scaled video.
            translationTransform  = CGAffineTransformMakeTranslation(-1.0 * videoSize.width/2.0, 0)
        }
        
        
        var scaleFactorTransform: CGAffineTransform = CGAffineTransformMakeScale(scaleFactor,scaleFactor)
        
        
        // If we crop, it is always to a square so test for width = height
        //
        if videoSize.width == videoSize.height {
            // Cropping, so apply translationTransform.  It does not make a difference in which order we apply
            // scaleFactorTransform, translationTransform.
            videolayerInstruction.setTransform(CGAffineTransformConcat(CGAffineTransformConcat(videoTrack.preferredTransform, scaleFactorTransform), translationTransform), atTime: kCMTimeZero)
        }
        else {
            // No cropping.  Do not apply translationTransform.
            videolayerInstruction.setTransform(CGAffineTransformConcat(videoTrack.preferredTransform, scaleFactorTransform), atTime: kCMTimeZero)
        }
        
        
        
        SNLog.info("isRotated90_270=\(isRotated90_270)  videoSize.width=\(videoSize.width)  videoSize.height=\(videoSize.height)  naturalSize.width=\(videoTrack.naturalSize.width)  naturalSize.height=\(videoTrack.naturalSize.height)  scaleFactor=\(scaleFactor)")
        
        
        
        // We need to execute some code in Objective C in order to work around a simulator bug.
        //
        // See http://finalize.com/2014/10/08/xcode-simulator-bug-with-swift-to-objective-c-call-passing-cmtime-structure/
        //
        // In particular we cannot execute the following lines in Swift due to the CMTime bug:
        //
        // videolayerInstruction.setOpacity(0.0, atTime: asset.duration)
        //
        // var inst: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        // inst.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
        //
        
        return VideoComposition.finishVideoComposition(videolayerInstruction, asset: asset, videoComposition: videoComposition)

    }
    

    // Determine if movie is rotated 90 or 270 degrees.
    //
    // Reference:
    // Post by Prince
    // http://stackoverflow.com/questions/12136841/avmutablevideocomposition-rotated-video-captured-in-portrait-mode
    //
    // Unlike the article referenced above, we don't try to distinguish between Portrait or Landscape 
    // here.  To do so would require us to look at the width to height ratio in addition to the 
    // preferred transform.  This determination is not important though.
    //
    // What we really want to know is whether or not we have a 90 or 270 degree rotation which would
    // cause us to swap the width and height during export.
    //
    // It's interesting to note that it is conceivable that we have a source video in Landscape whose
    // width is less than the height with a rotation of 90 or 270 degrees.   When exporting this Landscape
    // movie in this case, we will also want to swap width and height - ie. swapping is not restricted to just
    // Portrait movies, though Portrait may be the common case.
    //
    func isVideoRotated90_270(asset: AVAsset) -> Bool {
        
        
        var isRotated90_270 = false
        
        let tracks: [AVAssetTrack] = asset.tracksWithMediaType(AVMediaTypeVideo) as [AVAssetTrack]
        
        if tracks.count  > 0 {
            
            let videoTrack: AVAssetTrack = tracks[0]
            

            
            // See docs for CGAffineTransformMakeRotation where one can calculate the matrix values a,b,c,d below
            // for varying degrees of rotation.
            

            var t: CGAffineTransform = videoTrack.preferredTransform
            
            // 90 degree rotation (PI / 2 radians)
            //
            if t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0 {
                isRotated90_270 = true
            }
            
            // 270 degree rotation (3 PI / 2 radians)
            //
            if t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0  {
                isRotated90_270 = true
            }
            
            // 0 degree rotation
            // CGAffineTransformIdentity
            // The identity transform.
            //
            if t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0  {
                isRotated90_270 = false
            }
            
            // 180 degree rotation (PI radians)
            //
            if t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0 {
                isRotated90_270 = false
            }
        }
        
        return isRotated90_270
    }

    
    
    // MARK:  Toolbar methods
    
    func addSaveButton() -> Void {
        
        let toolbarItems: [UIBarButtonItem] =  self.toolbar.items as [UIBarButtonItem]
        
        // If we already have more toolbar items than at startup, then this method has already been called
        if toolbarItems.count != self.initialToolbarItems.count {
            return
        }
        
        // New items to add
        var save: UIBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: "saveAction")
        var flexSpace: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        
        // Set all toolbar items
        self.toolbar.setItems(toolbarItems + [save, flexSpace], animated: false)
        
    }
    
    
    func restoreInitialButtonItems() -> Void {
        
        let toolbarItems: [UIBarButtonItem] =  self.toolbar.items as [UIBarButtonItem]
        
        // If we have the same number of toolbar items as at startup, then there it nothing to do.
        if toolbarItems.count == self.initialToolbarItems.count {
            return
        }
        
        
        // Restore initial set of toolbar items
        self.toolbar.setItems(self.initialToolbarItems, animated: false)
        
    }
    
    

}





