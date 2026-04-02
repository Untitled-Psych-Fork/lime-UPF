package;

import lime.tools.HXProject;
import lime.tools.AndroidHelper;
import sys.FileSystem;
import hxp.System;
import hxp.Path;

// Functions specific to Android / Amazon
// Added for Inertia 2025
//

// Build for Amazon with
// lime test android -amazon
//
// We no longer use a tag in the project xml for amazon builds

//
// Testing IAP:
// ------------
// You can remove the test IAP files like this:
// adb shell rm /sdcard/amazon.sdktester.json
//


class AmazonPlatform
{
	// Where the test user json file lives on the Kindle
	static private var testUserJSONPath:String = "/sdcard/amazon.sdktester.json";

	// -------------------------------------------
	// Name: defineAmazonHaxeFlag
	// -------------------------------------------
	static public function defineAmazonHaxeFlag(project:HXProject){
		if (!isTargetAmazonBuild(project)) 
			return;
		
		trace("** Defining amazon haxe flag");

		// This makes the haxe code which uses "#if amazon" work
		project.haxeflags.push("-D");
   	 	project.haxeflags.push("amazon");
	}

	// -------------------------------------------
	// Name: defineAmazonContextFlag
	// -------------------------------------------
	static public function defineAmazonContextFlag(project:HXProject, context:Dynamic){
		if (!isTargetAmazonBuild(project)) 
			return;
		
		trace("** Adding amazon context flag");

		// This makes the java templates which rely on ::DEFINE_AMAZON:: work
		Reflect.setField(context, "DEFINE_AMAZON", "true");
	}

	// -------------------------------------------
	// Name: installAmazon
	// -------------------------------------------
	static public function installAmazon(project:HXProject, deviceID:String){
		if (!isTargetAmazonBuild(project)) 
			return;

		// Remove legacy Amazon tester file if building for Amazon
		clearIAPTestUser(deviceID);
		installIAPTestUser(project, deviceID);
	}

	// -------------------------------------------
	// Name: clearIAPTestUser
	// -------------------------------------------
	static private function clearIAPTestUser(deviceID:String){
		try {
			rm(testUserJSONPath, false, true, deviceID);
			trace("[IAP] Removed Amazon tester file: " + testUserJSONPath);
		} catch (e:Dynamic) {
			trace("[IAP] Could not remove tester file: " + testUserJSONPath + " (" + e + ")");
		}
	}

	// -------------------------------------------
	// Name: installIAPTestUser
	// -------------------------------------------
	static private function installIAPTestUser(project:HXProject, deviceID:String){
		
		var localIAPTestUserFile = Path.combine(projectRoot(project), "optional_assets/amazon/amazon.sdktester.json");

		trace("** Attempting to copy IAP test user JSON to target device, looking for local file: " + localIAPTestUserFile );

		if (!FileSystem.exists(localIAPTestUserFile)) {
			trace("[IAP] Could not get local IAP test user JSON for copying to target Kindle: " + localIAPTestUserFile);
			throw("[IAP] Could not get local IAP test user JSON for copying to target Kindle: " + localIAPTestUserFile);
			return;
		}
	
		try {
			push( localIAPTestUserFile, testUserJSONPath, deviceID);
			trace("[IAP] Pushed legacy tester JSON to " + testUserJSONPath);
		} catch (e:Dynamic) {
			trace("[IAP] Failed to push legacy tester JSON: " + e);
		}
	}

	// -------------------------------------------
	// Name: isTargetAmazonBuild
	// -------------------------------------------
	static inline public function isTargetAmazonBuild(project:HXProject):Bool{
		return project.targetFlags.exists("amazon");
	}

	// -------------------------------------------
	// Name: projectRoot
	// -------------------------------------------
	private static function projectRoot(project:HXProject):String {
		// project.projectFilePath is the absolute path to your project.xml
		if (project.projectFilePath != null && FileSystem.exists(project.projectFilePath)) {
			return Path.directory(project.projectFilePath);
		}
		return Sys.getCwd();
	}

	// --- Simple ADB helpers ------------------------------------------------------

	// -------------------------------------------
	// Name: adbWithDevice
	// -------------------------------------------
	public static function adbWithDevice(args:Array<String>, deviceID:String = null, quiet:Bool = false):Void {
		var finalArgs = args.copy();
		if (deviceID != null && deviceID != "") {
			finalArgs.unshift(deviceID);
			finalArgs.unshift("-s");
			@:privateAccess AndroidHelper.connect(deviceID);
		}
		System.runCommand( @:privateAccess AndroidHelper.adbPath,  @:privateAccess AndroidHelper.adbName, finalArgs, quiet);
	}

	// -------------------------------------------
	// Name: shell
	// -------------------------------------------
	public static function shell(args:Array<String>, deviceID:String = null, quiet:Bool = false):Void {
		adbWithDevice(["shell"].concat(args), deviceID, quiet);
	}

	// -------------------------------------------
	// Name: push
	// -------------------------------------------
	public static function push(localPath:String, remotePath:String, deviceID:String = null):Void {
		adbWithDevice(["push", localPath, remotePath], deviceID);
	}

	// -------------------------------------------
	// Name: rm
	// -------------------------------------------
	public static function rm(remotePath:String, recursive:Bool = false, force:Bool = true, deviceID:String = null):Void {
		var cmd = ["rm"];
		if (recursive) cmd.push("-r");
		if (force) cmd.push("-f");
		cmd.push(remotePath);
		shell(cmd, deviceID);
	}

	// -------------------------------------------
	// Name: mkdirP
	// -------------------------------------------
	public static function mkdirP(remotePath:String, deviceID:String = null):Void {
		shell(["mkdir", "-p", remotePath], deviceID);
	}
}
