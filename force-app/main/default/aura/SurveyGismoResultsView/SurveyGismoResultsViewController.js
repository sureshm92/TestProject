/**
 * Created by Nikita Abrazhevitch on 11-Sep-19.
 */

({
    doInit: function (component, event, helper) {
        component.set('v.decodeResults', null);
        var result = component.get('v.results');
        if (result) {
            if (!result.includes('http')) {
                var data = atob(result);
                data = data.replace('<h1>', '<h1 class="hide-survey-header">');
                component.set('v.decodeResults', data);
            }
        }
    },
});