(
    {
        doRender : function(component, event, helper) {
            if(!component.get('v.rendered')) {
                helper.changeValue(component, event, helper);
                component.set('v.rendered', true);
            }
        },

        changeValue : function(component, event, helper) {

            /** todo add ability to change value dynamically*/
            helper.changeValue(component, event, helper);
        },
    }
)