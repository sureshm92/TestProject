/**
 * Created by Kryvolap on 15.10.2018.
 */
({
    doAfterScriptsLoaded: function (component, event, helper) {
        svg4everybody();
    },
    doInit: function (component, event, helper) {
        if (communityService.getCurrentCommunityMode().currentDelegateId) {
            component.set('v.isDelegate', true);
        } else {
            component.set('v.isDelegate', false);
        }
        var showTour = communityService.showTourOnLogin();
        component.set('v.showTour', showTour);
        var userMode = component.get('v.userMode');
        let isMobileApp = communityService.isMobileSDK();
        component.set('v.isMobileApp',isMobileApp);
        communityService.executeAction(
            component,
            'getInitData',
            {
                userMode: userMode
            },
            function (returnValue) {
                var initData = JSON.parse(returnValue);
                component.set('v.videoLink', initData.videoLink);
                component.set('v.userManual', initData.userManual);
                component.set('v.quickReference', initData.quickReference);
                component.set('v.yearOfBirthPicklistvalues',initData.yearOfBirth);
                component.set('v.usrName',initData.usrName);
                console.log('initData.usrName',initData.usrName);
                component.set('v.currentYOB',initData.currentYearOfBirth);
                component.set('v.currentContactEmail',initData.usrEmail);
                component.set('v.isDuplicate',initData.isDuplicate);
                component.set('v.showUserMatch',initData.showUserEmailMatch);
            }
        );
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
    
    openQuickReference: function (component, event, helper) {
        var quickReference = component.get('v.quickReference');
        if (communityService.isMobileSDK() ) {
            /** communityService.showWarningToast(
                'Warning!',
                $A.get('$Label.c.Pdf_Not_Available'),
                100
            ); **/
            communityService.navigateToPage('mobile-pdf-viewer?resourceName='+quickReference);
            return;
        }
        var webViewer = $A.get('$Resource.pdfjs_dist') + '/web/viewer.html';
        window.open(webViewer + '?file=' + $A.get('$Resource.' + quickReference)+'&fileName=' + $A.get('$Label.c.Quick_Reference_Card'), '_blank');
    },
    
    openGuide: function (component, event, helper) {
        if (communityService.isMobileSDK()) {
            communityService.showWarningToast(
                'Warning!',
                $A.get('$Label.c.Pdf_Not_Available'),
                100
            );
            return;
        }
        var userManual = component.get('v.userManual');
        var webViewer = $A.get('$Resource.pdfjs_dist') + '/web/viewer.html';
        window.open(webViewer + '?file=' + $A.get('$Resource.' + userManual), '_blank');
    },
    
    stopVideo: function (component, event, helper) {
        var video = document.getElementById('video-tour');
        video.pause();
    },
    navigateToAccountSettings:function (component, event, helper) {
        communityService.navigateToPage('account-settings');
    },
    doCheckYearOfBith:function (component, event, helper) {
        component.set('v.showError',false);
        //component.set('v.showValidValue',false);
        var spinner = component.find('spinner');
        spinner.show();
        communityService.executeAction(
            component,
            'validateAgeOfMajority',
            {
                birthYear: component.get('v.yearOfBirth')
            },
            function (returnValue) {
                var isAdultDelegate = returnValue == 'true';
                if(isAdultDelegate){
                    component.set('v.showError',false);
                    component.set('v.disableSave',false);
                }else{
                    //component.set('v.yearOfBirth',null);
                    if(component.get('v.yearOfBirth') !== ''){
                       component.set('v.showError',true);
                    }
                    if(component.get('v.yearOfBirth') === ''){
                       //component.set('v.showValidValue',true); 
                    }
                   component.set('v.disableSave',true);
                }
                
               if((component.get('v.showUserNames') && $A.util.isUndefinedOrNull(component.get('v.userEmail'))) || /*component.get('v.showValidValue')|| */  component.get('v.showError') || ($A.util.isUndefinedOrNull(component.get('v.yearOfBirth')) && !component.get('v.changeUserName'))){
                  component.set('v.disableSave',true);   
                }
                else{
                     component.set('v.disableSave',false);
               }


            } ,         
            null,
            function () {
                spinner.hide();
            }
        );
    },
    doCreateYOBCase:function (component, event, helper) {
        var spinner = component.find('spinner');
        spinner.show(); 
        communityService.executeAction(
            component,
            'createYOBCase',
            {
                yob:component.get('v.yearOfBirth'),
                username:component.get('v.changeUserName'),
                userEmail:component.get('v.userEmail'),
                currentYob:component.get('v.currentYOB'),
                mergeUserNames:component.get('v.isDuplicate'),
                usrList:component.get('v.usernamesTomerge')
                
            },
            function (returnValue) {
                var message =  $A.get('$Label.c.PP_RequestSubmitted');
                communityService.showToast(
                    'Success!',
                    'success',
                    message,
                    100
                );
              communityService.navigateToPage('help');
            } ,         
            null,
            function () {
                spinner.hide();
            }
        );
    },
    setSelectedVal:function (component, event, helper) {
        component.set('v.userEmail',event.getParam("value"));
               if((component.get('v.showUserNames') && $A.util.isUndefinedOrNull(component.get('v.userEmail'))) || component.get('v.showValidValue') || component.get('v.showError') || ($A.util.isUndefinedOrNull(component.get('v.yearOfBirth')) && !component.get('v.changeUserName'))){
                  component.set('v.disableSave',true);   
                }
                else{
                     component.set('v.disableSave',false);
               }

        
    },
    doChangeUserName:function (component, event, helper) {
        var sourceEvt = event.getSource();
        component.set('v.changeUserName',sourceEvt.get('v.checked'));
        var spinner = component.find('spinner');
        if(component.get('v.changeUserName')){
            spinner.show();
        communityService.executeAction(
            component,
            'validateUsername',
            {
            },
            function (returnValue) {
                var usernames = returnValue;
                component.set('v.userNamesList',usernames);
                console.log(usernames);
                var usrList =[];
                for(let key in usernames){
                  usrList.push(usernames[key].value);
                }
                console.log('usrList',usrList);
                component.set('v.usernamesTomerge',usrList);
                if(returnValue.length > 0){
                    component.set('v.showUserNames',true);
                    component.set('v.value',component.get('v.usrName'));
                    component.set('v.userEmail',component.get('v.value'));
                    var duplicateInfoHeader = returnValue.length > 1 ? $A.get('$Label.c.PP_DuplicateUsernames'):$A.get('$Label.c.PP_UsrNameLabel');
                    duplicateInfoHeader = duplicateInfoHeader.replace('##Email',component.get('v.currentContactEmail'));
                    component.set('v.duplicateUsrLabel',duplicateInfoHeader);

                }
               if((component.get('v.showUserNames') && $A.util.isUndefinedOrNull(component.get('v.userEmail'))) || component.get('v.showValidValue') || component.get('v.showError') || ($A.util.isUndefinedOrNull(component.get('v.yearOfBirth')) && !component.get('v.changeUserName'))){
                  component.set('v.disableSave',true);   
                }
                else{
                     component.set('v.disableSave',false);
               }
               
            } ,         
            null,
            function () {
                spinner.hide();
            }
        );
        }
        else{
               if((component.get('v.showUserNames') && $A.util.isUndefinedOrNull(component.get('v.userEmail'))) /*|| component.get('v.showValidValue') */|| component.get('v.showError') || (!(component.get('v.yearOfBirth')) && !component.get('v.changeUserName'))){

                   component.set('v.disableSave',true);   
                }
                else{
                     component.set('v.disableSave',false);
               }

            
           
            component.set('v.showUserNames',false);
        }
        
    }
});