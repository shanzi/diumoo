#!/usr/bin/ruby

require 'FileUtils'
require 'rubygems'

begin
   require 'osx/plist'
   rescue LoadError
   error_string = "\n\nYou must install the plist ruby gem in order to use this script. \n gem sources -a http://gems.github.com \n sudo gem install kballard-osx-plist\n"
   raise error_string
end

$xpcExtension = ".xpc"
$serviceName = "GNTPClientService"
$startBaseID = "com.company.application"
$startID = $startBaseID + "." + $serviceName
$startPackage = $startID + $xpcExtension

$entitlementPath = File.join("Contents", "Resources", $serviceName + ".entitlements")

$newPackage = $startPackage

def rename(bundleID)
   if File.exists?($startPackage)
      
      puts("Creating " + $newPackage + " from " + $startPackage)
      
      #remove an existing copy, helpfull for us because we could be building a new XPC to test
      if File.exists?($newPackage)
         FileUtils.rm_r($newPackage)
      end
      
      #make our new XPC
      FileUtils.cp_r($startPackage, $newPackage)
      infoPath = File.join($newPackage, "Contents", "Info.plist")
      
      #fix the Info.plist
      plistData = File.new(infoPath, "r")
      properties = OSX::PropertyList.load(plistData)
      properties['CFBundleIdentifier'] = bundleID
      properties['CFBundleExecutable'] = bundleID
      properties['CFBundleName'] = bundleID
      
      plistOut = File.new(infoPath, "w")
      OSX::PropertyList.dump(plistOut, properties)
      plistOut.close
      
      #Fix the executable
      execDir = File.join($newPackage, "Contents", "MacOS")
      oldExec = File.join(execDir, $startID)
      newExec = File.join(execDir, bundleID)
      File.rename(oldExec, newExec)
   else
      puts("No bundle named " + $startPackage + " found")
   end
end

def resign(identity)
   if File.exists?($newPackage)
      puts("Resigning with identity " + identity)
      system("codesign", "-f", "-s", identity, "--entitlements", File.join($newPackage, $entitlementPath), $newPackage)
      
      #system("codesign", "-dvvvv", "--entitlements", ":-", $newPackage)
      if system("codesign", "-v", $newPackage)
         puts("Code resign valid")
      else
         puts("There was an error with the signature")
      end
   end
end

def main
   #where is the original XPC (it might be beside us, but let the argument tell us)
   #For us in an Extra or Dev tool this is $SRCROOT/../../build/$CONFIGURATION
   startLocation = ARGV[0]
   #What app are we putting this in?
   # ex: $BUILT_PRODUCTS_DIR/$WRAPPER_NAME
   appBase = ARGV[1]
   #use $CODE_SIGNING_IDENTITY
   newSigningIdentity = ARGV[2]
   
   contentsPath = File.join(appBase, "Contents")
   
   infoPath = File.join(contentsPath, "Info.plist");
   
   #get the app's bundle id, this will be our base ID
   plistData = File.new(infoPath, "r")
   properties = OSX::PropertyList.load(plistData)
   bundleID = properties['CFBundleIdentifier']
   
   xpcID = bundleID + "." + $serviceName   
   $newPackage = xpcID + $xpcExtension
   
   #keep things simpler in rename/resign and move to that directory
   #for us this is usefull, for developers, they may not need this
   curDir = Dir.getwd
   Dir.chdir(startLocation)

   rename(xpcID)
   resign(newSigningIdentity)
   
   Dir.chdir(curDir)
   
   xpcsDir = File.join(contentsPath, "XPCServices")  
   xpcOrigin = File.join(startLocation, $newPackage)
   xpcDest = File.join(xpcsDir, $newPackage)
   
   #make <app>/Contents/XPCServices if it doesn't exist
   if !File.exists?(xpcsDir)
      Dir.mkdir(xpcsDir)
   end
   
   #remove an existing copy if it exists
   if File.exists?(xpcDest)
      FileUtils.rm_r(xpcDest)
   end
   FileUtils.cp_r(xpcOrigin, xpcDest)
end

if __FILE__ == $0
   main()
end