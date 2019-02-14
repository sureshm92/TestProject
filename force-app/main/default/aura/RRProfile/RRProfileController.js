({
    doInit: function (component, event, helper) {
        var action = component.get('c.getUser');
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var retVal = JSON.parse(response.getReturnValue());
                component.set("v.user", retVal.user);
                component.set("v.participantName", retVal.participantName);
            } else {
                communityService.showToast("error", "error", $A.get("$Label.c.TST_Something_went_wrong"));
                communityService.logErrorFromResponse(response);
            }
        });
        $A.enqueueAction(action);
    },
    toggleMenu: function (component, event, helper) {
        component.set("v.showMenu", !component.get("v.showMenu"));
        component.find("settingsMenu").getElement().focus();
        console.log("focused");
    },
    hideMenu: function (component, event, helper) {
        component.set("v.showMenu", false);
    },
    navigateToMyTeam: function (component, event, helper) {
        communityService.navigateToPage('settings?tab=my-team');
        component.set("v.showMenu", false);
    },
    navigateToAccountSettings: function (component, event, helper) {
        communityService.navigateToPage('settings?tab=account-settings');
        component.set("v.showMenu", false);
    },
    doLogout: function (component, event, helper) {
        component.set("v.showMenu", false);
        var action = component.get('c.getLogoutURL');
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                window.location.replace(response.getReturnValue() + "/secur/logout.jsp");
            } else {
                communityService.showToast("error", "error", $A.get("$Label.c.TST_Something_went_wrong"));
                communityService.logErrorFromResponse(response);
            }
        });
        $A.enqueueAction(action);
    }
})