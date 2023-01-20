/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if (sessionStorage.getItem('isExecute') == null) {
            sessionStorage.setItem('isExecute', 'true');
        }
        if (communityService.isInitialized()) {
            component.set('v.communityServ', communityService);
            communityService.executeAction(
                component,
                'checkStudyMessage',
                null,
                function (returnValue) {
                    component.set('v.hasMessage', returnValue);
                    helper.init(component);
                }
            );
            setTimeout(
                $A.getCallback(function () {
                    //helper.init(component);
                }),
                1000
            );
        } else {
            communityService.initialize(component);
        }

          // Retrieve session id
        var action = component.get('c.getSessionId');
        action.setCallback(this, function (response) {
            var key = JSON.parse(JSON.stringify(response.getReturnValue()));
            if(response.getState() === 'SUCCESS'){
                var res = key['sessionId'].split(",")[1];
                component.set("v.sessionId",res);
                component.set("v.contactId", key['userId']);
                if (component.get('v.sessionId') != null){
                    helper.connectCometd(component,event);
                    helper.getSendResult(component,event);
                }
            }else{
                console.error(response);
            }
        });
        $A.enqueueAction(action);
        component.set('v.resetBell',true);
    },

    doRefresh: function (component, event, helper) {
        window.location.reload();
        helper.init(component);
        if (component.get('v.communityName') !== 'IQVIA Patient Portal') {
            component.find('navigation').refresh();
            component.find('navigationMobile').refresh();
            component.find('alerts').refresh();
        }
        else{
            component.find('ppMenu')?.forceRefresh();
            component.find('ppFooter')?.forceRefresh();
            component.find('ppAlerts')?.forceRefresh();
        }
    },

    switchSideMenu: function (component) {
        component.set('v.showSideMenu', !component.get('v.showSideMenu'));
    },

    doGoHome: function () {
        communityService.navigateToPage('');
    },
    doNavigate: function (component, event) {
        var page = event.getParam('page');
        communityService.navigateToPage(page);
    },
    verifyIncentive: function (component, event) {
        let isPartOfincentive = event.getParam('parOfIncentiveProgram');
        component.set('v.isIncentive',isPartOfincentive);
    },
    //Added as per REF-1343 by Vikrant Sharma for Help icon adjacent to User Profile for PI and HCP
    onClickHelp: function () {
        communityService.navigateToPage('help');
    },
    onClickBell: function(component){
        if((!component.get('v.isBellEnabled') && component.get('v.isBellClosed')) ||
            (!component.get('v.isBellEnabled') && !component.get('v.isBellClosed'))){
        	component.set('v.isBellEnabled', true);
        } else {
            component.set('v.isBellEnabled', false);
            component.set('v.isBellClosed', false);
         }
    },

    onBlurBell: function(component){
       if(!component.get('v.isBellEnabled') && component.get('v.isBellClosed')) {
            component.set('v.isBellEnabled', true);
        } else {
        	component.set('v.isBellEnabled', false);
            component.set('v.isBellClosed', false);
        }
   },

    handleClick: function (component, event, helper) {
        var showHide = component.get('v.isPPonPhone');
        if (showHide == false) {
            component.set('v.isPPonPhone', true);
        } else {
            component.set('v.isPPonPhone', false);
        }
    },
    closePPMobileMenu: function (component, event, helper) {
        if (component.get('v.isPPonPhone')) {
            component.set('v.isPPonPhone', false);
        }
    },
    lazyLoading : function(component, event, helper) {
        var scrollTop = event.getParam('scrollTop');
        var offsetHeight = event.getParam('offsetHeight');
        var scrollHeight = event.getParam('scrollHeight');
        if (
            offsetHeight + scrollTop + 10 >=
           scrollHeight
          ) {
            helper.loadMoreNotifications(component);
          }
    },
    onClickSite: function (component, event) {
        if (!component.get('v.isSitecal')) {
            component.set('v.isSitecal', true);
        } else {
            component.set('v.isSitecal', false);
        }
    },
    updateReadMark : function(component, event, helper) {
        var notificationId = event.getParam('notificationId');
        component.set("v.unreadSendResultId", notificationId); 
    
        var notificationIndex = event.getParam('notificationIndex');
        var refreshBell = event.getParam('refBell');
        if(refreshBell == true){
        component.set('v.resetBell',false);
        component.set('v.isBellEnabled', false);
        component.set('v.isBellClosed', false);
        component.set('v.resetBell',true);
        }else{ 
             helper.updateReadtoUnRead(component, notificationIndex);
        }

    },

    closeSendResult: function(component, event, helper) {
        var closeSendResId = event.getParam('closeSendResId');
        component.set("v.closeSendResultId", closeSendResId);

        var closeSendResIndex = event.getParam('closeSendResIndex');
        helper.removeSendResult(component, closeSendResIndex);
    },
    closeBell: function(component, event) { 
        //let overlayCmp = component.find("overlay");
        //overlayCmp.closeBellOverlay();
        component.set('v.resetBell',false);
        component.set('v.isBellEnabled', false);
        component.set('v.isBellClosed', false);
        component.set('v.resetBell',true);
    },
});