/**
 * Created by Krivo on 06.11.2019.
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getInitData', null, function (formData) {
            var todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
            component.set('v.formData', formData);
            component.set('v.initialized', true);
            setTimeout(
                $A.getCallback(function () {
                    window.print();

                }), 1000
            );

        });
    },
})