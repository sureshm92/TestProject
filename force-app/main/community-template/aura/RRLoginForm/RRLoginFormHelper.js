/**
 * Created by Leonid Bartenev
 */
({

    qsToEventMap: {
        'startURL'  : 'e.c:setStartUrl'
    },

    qsToEventMap2: {
        'expid'  : 'e.c:setExpId'
    },

    handleLogin: function (component, event, helper) {
        var username = component.find("username").get("v.value");
        var password = component.find("password").get("v.value");
        var action = component.get("c.login");
        var startUrl = component.get("v.startUrl");

        startUrl = decodeURIComponent(startUrl);

        action.setParams({username: username, password: password, startUrl: startUrl});
        action.setCallback(this, function (a) {
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set("v.errorMessage", rtnValue);
                component.set("v.showError", true);
                component.set("v.paddingTop", 0);
            }
        });
        $A.enqueueAction(action);
    },

    getIsUsernamePasswordEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsUsernamePasswordEnabled");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isUsernamePasswordEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    getIsSelfRegistrationEnabled : function (component, event, helpler) {
        var action = component.get("c.getIsSelfRegistrationEnabled");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.isSelfRegistrationEnabled',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    getCommunityForgotPasswordUrl : function (component, event, helpler) {
        var username = component.find("username").get("v.value");
        var action = component.get("c.getForgotPasswordUrl");
        action.setParams({username: username});
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                try{
                if(rtnValue.includes("**return")){
                    rtnValue = rtnValue.replace("**return","");
                    component.set("v.errorMessage",rtnValue);
                    component.set("v.showError",true);
                }else if(rtnValue.includes("**url")){
                    rtnValue = rtnValue.replace("**url","");
					window.open(rtnValue,'_top');
                    // component.set('v.communityForgotPasswordUrl',rtnValue);
                }
                }catch(e){
                    console.log(e);
                }
                // component.set('v.communityForgotPasswordUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    getCommunitySelfRegisterUrl : function (component, event, helpler) {
        var action = component.get("c.getSelfRegistrationUrl");
        action.setCallback(this, function(a){
            var rtnValue = a.getReturnValue();
            if (rtnValue !== null) {
                component.set('v.communitySelfRegisterUrl',rtnValue);
            }
        });
        $A.enqueueAction(action);
    },

    setBrandingCookie: function (component, event, helpler) {
        var expId = component.get("v.expid");
        if (expId) {
            var action = component.get("c.setExperienceId");
            action.setParams({expId:expId});
            action.setCallback(this, function(a){ });
            $A.enqueueAction(action);
        }
    }
})