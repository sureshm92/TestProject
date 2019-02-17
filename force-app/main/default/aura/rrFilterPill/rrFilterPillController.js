({
    toggleButton: function (component, event, helper) {
        var isActive = component.get('v.isActive');
        var thisBtnValue = component.get('v.thisBtnValue');
        var value = component.get('v.value');
        //if value not defined then use isActive attribute (old logic), else use value/btnValue attributes (new logic)
        if(value === 'undefined value'){
            component.set('v.isActive', !isActive);
        }else if(thisBtnValue === value){
            component.set('v.value', null);
        }else{
            component.set('v.value', thisBtnValue);
        }
    }
})