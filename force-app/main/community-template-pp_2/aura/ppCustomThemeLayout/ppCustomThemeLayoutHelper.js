({
    init: function (component) {
        let isDummy = communityService.isDummy();
        var rtl_language = $A.get('$Label.c.RTL_Languages');
        component.set('v.isDummy', isDummy);
        if (!isDummy) {
            component.set(
                'v.showModeSwitcher',
                !(
                    communityService.getAllUserModes().length === 1 &&
                    communityService.getAllUserModes()[0].subModes.length <= 1
                )
            );
        }
        component.set('v.currentMode', communityService.getCurrentCommunityMode());
        component.set('v.isRTL', rtl_language.includes(communityService.getLanguage()));
        component.set('v.logoURL', communityService.getTemplateProperty('CommunityLogo'));
        component.set('v.urlPathPrefix', communityService.getCommunityURLPathPrefix());
        component.set('v.isMobileApp', communityService.isMobileSDK());
        component.set('v.isInitialized', true);       
    },

    handleOrientationInit: function (component) {
        component.set('v.innerWidth', window.innerWidth);
        component.set('v.innerHeight', window.innerHeight);  
        if(communityService.getCurrentCommunityName() == 'IQVIA Patient Portal')
        {
            let width = component.get('v.innerWidth');
            let height = component.get('v.innerHeight');  
            let mediaContent = component.get('v.mediaContent');
            let pageName =  false; 
            (communityService.getPageName() == "resource-detail") ? pageName = true : pageName = false;
            if(!$A.util.isUndefined(component.get("v.paddingChange"))){
                ((height < width) && mediaContent && pageName) ? component.set('v.paddingChange', true) : component.set('v.paddingChange', false);
            }
        }
    },
    
    registerOrientationChange: function (component) {
        if(communityService.getCurrentCommunityName() == 'IQVIA Patient Portal')
        {          
            console.log("registering orientation change event");
            window.addEventListener(
                "orientationchange", 
                $A.getCallback(function(event) {
                    // You can use component/helper here...
                    console.log("Orientation Change registered");
                    let mediaContent = component.get('v.mediaContent');
                    let pageName =  false; 
                    (communityService.getPageName() == "resource-detail") ? pageName = true : pageName = false;
                    if(screen.orientation.angle != 0 && mediaContent && pageName){
                        console.log("landscpae");
                        component.set('v.paddingChange', true); 
                        component.set('v.innerWidth', window.innerHeight);
                        component.set('v.innerHeight', window.innerWidth);
                    }
                    else if(screen.orientation.angle == 0 && mediaContent && pageName){
                        console.log("portrait");
                        component.set('v.paddingChange', false);
                        component.set('v.innerWidth', window.innerHeight);
                        component.set('v.innerHeight', window.innerWidth);   
                    }
                })
            );
        }     
    }
});