/**
 * Created by Nargiz Mamedova on 5/18/2020.
 */

({
    doRender : function(component, event, helper) {
        if(!component.get('v.rendered')) {
            helper.changeValue(component, event, helper);
            component.set('v.rendered', true);
        }
    },
});