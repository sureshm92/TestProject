/**
 * Created by Igor Malyuta on 13.09.2019.
 */

({
    doShowLanguageMenu: function (component, event, helper) {
        var triggerCmp = component.find('trigger');
        if (triggerCmp) {
            var label = event.getSource().get('v.label');

            var wrapper = component.get('v.resourceWrapper');
            var contentId;
            for(var i = 0; i < wrapper.translations.length; i++) {
                var translation = wrapper.translations[i];
                if(translation.languageLabel === label) {
                    contentId = translation.contentId;
                    break;
                }
            }

            var resourceType = wrapper.resource.RecordType.DeveloperName;
            helper.navigate(component, resourceType, contentId);
        }
    },

    doNavigate: function (component, event, helper) {
        var resource = component.get('v.resourceWrapper').resource;
        var resourceType = resource.RecordType.DeveloperName;

        helper.navigate(component, resourceType, resource.Id);
    }
});