({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        var cmpTarget = component.find('borderLine');
        if(component.get("v.isArabic")){
        	$A.util.addClass(cmpTarget, 'h-right-col');
            $A.util.removeClass(cmpTarget, 'h-left-col');
        }else{
            $A.util.addClass(cmpTarget, 'h-left-col');
            $A.util.removeClass(cmpTarget, 'h-right-col');
        }
        if(!communityService.isDummy()) {
            component.set('v.userMode', communityService.getUserMode());
            communityService.executeAction(component, 'getHelpText', null, function (response) {
                component.set('v.helpText', response);
                component.set('v.isInitialized', true);
            });
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    }
});