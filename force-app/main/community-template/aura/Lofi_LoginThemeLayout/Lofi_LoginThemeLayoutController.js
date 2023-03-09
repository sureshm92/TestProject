({
    doInit: function (component, event, helper) {
        let rtl_language = $A.get('$Label.c.RTL_Languages');
        let paramLanguage = communityService.getUrlParameter('language');
        let communityType = component.get('v.communityType'); 
        // Enqueue Action
        console.log('>>communityType>>'+JSON.stringify(communityType));
        var action = component.get("c.getCPRALink");
        action.setParams({ strCommunityType : communityType });
        action.setCallback(this, function(response) {
            console.log('>>>responseback>>'+response.getReturnValue());
            if(response.getReturnValue())
            {
                var getReturnValueMD = response.getReturnValue();
                component.set('v.isCPRAavailable',true);
                component.set('v.cssClassName','slds-col slds-size_1-of-4'); 
                component.set('v.cssClassNameMobile','slds-col slds-p-left--medium slds-p-right--medium slds-size_1-of-4'); 
                var labelReference = $A.getReference("$Label.c." + getReturnValueMD.CPRA_Label__c);
 
                component.set('v.CPRAlabel', labelReference); 
                component.set('v.CPRALinkToredirect',getReturnValueMD.Link_to_redirect__c); 
            }
            else {
                component.set('v.isCPRAavailable',false);
                component.set('v.cssClassName','slds-col slds-size_1-of-3'); 
                component.set('v.cssClassNameMobile','slds-col slds-size_1-of-3'); 
            }
            
        });
        $A.enqueueAction(action);
        let isMobileApp = communityService.isMobileSDK();
        let windowUrl = window.location.href;
        let bodyText =
            communityType !== 'Janssen'
                ? $A.get('$Label.c.Cookies_Info_Text')
                : $A.get('$Label.c.Cookies_Info_Text_Janssen');
        let privacyPolicyLinkText =
            communityType !== 'Janssen'
                ? $A.get('$Label.c.Footer_Link_Privacy_Policy')
                : $A.get('$Label.c.Footer_Link_Privacy_Policy_Janssen');
        component.set('v.isRTL', rtl_language.includes(paramLanguage));
        if ((isMobileApp || communityService.isMobileOS())) {
            component.set('v.isMobileView', true);
        }
        component.set('v.isMobileApp', isMobileApp);
        bodyText = bodyText.replace('##cookiesURL', $A.get('$Label.c.Link_Cookies'));
        component.set('v.cookieText', bodyText);

        //For OS and Browser 150%
        if (window.innerHeight <= 410 && !(isMobileApp || communityService.isMobileOS())) {
            component.set('v.isMobileView', true);
        }
        component.resize = $A.getCallback(function () {
            if (component.isValid()) {
                if (window.innerHeight <= 410 && !(isMobileApp || communityService.isMobileOS())) {
                    component.set('v.isMobileView', true);
                } else {
                    component.set('v.isMobileView', isMobileApp || communityService.isMobileOS());
                }
            } else {
                window.removeEventListener('resize', component.resize);
            }
        });
        window.addEventListener('resize', component.resize);
    },
    selectedRecords: function (component, event, helper) {
        component.set('v.showPpPopup', true);
    },
    closePpPopup: function (component, event, helper) {
        component.set('v.showPpPopup', false);
    },
    onLinkClick: function (component) {

        let communityName = component.get('v.communityType');
        var link = component.get('v.CPRALinkToredirect');
        var urlEvent = $A.get('e.force:navigateToURL');
        urlEvent.setParams({
            url: link
        });
        urlEvent.fire();
    }
});