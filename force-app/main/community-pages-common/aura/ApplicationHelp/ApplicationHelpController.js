/**
 * Created by Kryvolap on 15.10.2018.
 */
({
    doAfterScriptsLoaded: function (component, event, helper) {
        svg4everybody();
    },
    doInit: function (component, event, helper) {
        var showTour = communityService.showTourOnLogin();
        component.set('v.showTour', showTour);
        var userMode = component.get('v.userMode');
        
        communityService.executeAction(component, 'getInitData', {
            userMode: userMode
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            component.set('v.videoLink', initData.videoLink);
            component.set('v.userManual', initData.userManual);
            component.set('v.quickReference', initData.quickReference);

        });
        let isMobileApp = communityService.isCurrentSessionMobileApp();
        let pdfName = $A.get("$Label.c.Participant_quick_reference");
        component.set("v.isMobApp",isMobileApp);
        communityService.executeAction(component, 'getPdfDonload', {
            titleName: pdfName
        }, function (returnValue) {
            component.set("v.pdfUrl", returnValue);
        }, null, function () {
            //component.set('v.showSpinner', false);
        })
    },

    showVideo: function (component, event, helper) {
        component.find('videoModal').show();
    },

    setTour: function (component, event, helper) {
        var showOnLogin = component.get('v.showTour');
        var action = component.find('switchShowOnLoginModeAction');
        action.execute(showOnLogin);
    },

    showTour: function (component, event, helper) {
        communityService.showTour();
    },

    OpenQuickReference: function (component, event, helper) {
        if(component.get("v.isMobApp")){
            var recId = component.get("v.pdfUrl");
            var urls = window.location.origin+'/sfc/servlet.shepherd/document/download/'+recId;            
            let urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({url: urls});
            urlEvent.fire();
        }else{
            var quickReference = component.get('v.quickReference');
            var navUrl = $A.get('$Resource.' + quickReference);
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": window.location.origin + navUrl
            });
            urlEvent.fire();
        }        
    },

    OpenGuide: function (component, event, helper) {
        var userManual = component.get('v.userManual');
        window.open($A.get('$Resource.' + userManual), '_blank');
    },

    stopVideo: function (component, event, helper) {
        var video = document.getElementById('video-tour');
        video.pause();
    }

})