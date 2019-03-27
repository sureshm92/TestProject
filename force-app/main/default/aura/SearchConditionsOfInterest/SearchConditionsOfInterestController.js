/**
 * Created by Yehor Dobrovolskyi
 */
({
    doInit: function(component, event, helper) {
        component.find('searchModal').show();
    },

    bulkSearch: function(component, event, helper) {
        var bypass = component.get('v.bypass');
        if(bypass){
            return;
        }else{
            component.set('v.bypass',true);
            window.setTimeout(
                $A.getCallback(function() {
                    helper.valueChange(component, event, helper);
                }), 500
            );
        }
    },

})