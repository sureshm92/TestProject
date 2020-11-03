/**
 * Created by Olga Skrynnikova on 9/10/2020.
 */

({
    doExecute: function (component, event, helper) {
        component.find('spinner').hide();
        var params = event.getParam('arguments');
        console.log('>>> ' + JSON.stringify(params));
        component.set('v.messageText', 'Please refresh the page and try again.');
        component.set('v.titleText', 'Oops, something went wrong.');
        component.set('v.errorText', params.errorText);
        //component.set('v.messageText', params.messageText);
        //component.set('v.titleText', params.titleText);
        component.find('exceptionHandler').show();
    },

    doProcessCollapse: function (component, event, helper) {
        var isCollapsed = component.get('v.isCollapsed');
        if(!isCollapsed){
            //get exception text
        }
    }
});