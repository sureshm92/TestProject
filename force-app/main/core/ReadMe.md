## rr_community_js.js and main.css

This is the base JS framework used accross the project. Contains all the JS util methods and loaded as static resource in the components. Add the documentation here

1. `isMobileSDK()`
   To detect the mobile publisher branded app using JS userAgent object

2. `isCurrentSessionMobileApp()` - depricated
   To detect the mobile publisher branded app using Apex AuthSession. Depricated use `isMobileSDK()` instead.
