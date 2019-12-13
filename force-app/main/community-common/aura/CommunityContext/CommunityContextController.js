/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        component.set('v.isArabic', communityService.getLanguage() === 'ar');
    }
})