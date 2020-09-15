/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        var rtl_language = $A.get("$Label.c.RTL_Languages");
        component.set('v.isRTL', rtl_language.includes(communityService.getLanguage()));
    }
})