## rr_community_js.js and main.css

`rr_community_js.js` is the base JS framework used across the project. Contains all the JS util methods and loaded as static resource in the aura markups.

1. `isMobileSDK()`
   To detect the mobile publisher branded app using JS userAgent object. Would work for any application made on SalesforceMobileSDK

2. `isCurrentSessionMobileApp()` - depricated
   To detect the mobile publisher branded app using Apex AuthSession. Depricated use `isMobileSDK()` instead.

3. `isMobileOS()`
   To detect if the current device is a mobile. Supports Android™ and Apple™ (iPhone/iPad/iPod) devices.
