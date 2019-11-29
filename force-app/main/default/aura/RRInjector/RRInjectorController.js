(
    {
        doInit: function(component, event, helper) {

            let action = component.get('c.getComponentName');
            action.setParams({'componentName' : component.get('v.componentName')});
            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    let result = response.getReturnValue();
                    let attributes = component.get('v.body');
                    let componentAttributes = {};
                    for(let attribute of attributes) {
                        componentAttributes[attribute.get('v.name')] = attribute.get('v.isReference')
                            ? attribute.getReference('v.value')
                            : attribute.get('v.value');
                    }
                    helper.createInjectedComponent(component, result, componentAttributes);
                } else if (state === 'ERROR') {
                    let errors = response.getErrors();
                    if (errors && errors[0].message) {
                        console.log('error:', errors[0].message);
                    }
                }
            });
            $A.enqueueAction(action);
        },
    }
)