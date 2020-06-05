/**
 * Created by Yehor Dobrovolskyi
 */
({
    doInit: function (component, event, helper) {
       //debugger;
        communityService.executeAction(component, 'getConditionOfInterest', {}, function (returnValue) {
            
        component.set('v.conditionOfInterestList', returnValue);
        
        let copy = JSON.parse(JSON.stringify(component.get('v.conditionOfInterestList')));

        component.set('v.conditionsOfInterestTemp', copy);
        helper.valueChange(component, event, helper);
            });
        
        
    },

    show: function (component, event, helper) {
        helper.valueChange(component, event, helper);
        component.find('searchModal').show();
    },

    hide: function(component, event, helper) {
        component.find('searchModal').hide();
    },

    bulkSearch: function (component, event, helper) {
        var bypass = component.get('v.bypass');
        component.set('v.showmenu',true);
        if (bypass) {
            return;
        } else {
            component.set('v.bypass', true);
            window.setTimeout(
                $A.getCallback(function () {
                    helper.valueChange(component, event, helper);
                }), 500
            );
        }
    },

    handleChange: function (component, event, helper) {
        helper.changeCheckBox(component, event);
    },

    doSave: function (component, event, helper) {
        helper.saveElement(component,event,helper);
    },
    handleRemoveOnly: function (component, event) {
        event.preventDefault();
        var pillName = event.getSource().get('v.name');
        var pills = component.get('v.conditionsOfInterestTemp');
        var selectedList=[];
        for (var i = 0; i < pills.length; i++) {
            if (pillName === pills[i].coi.Therapeutic_Area__r.Name) { 
                selectedList.push(pills[i]);
              pills.splice(i, 1);
              
              break;
            }
          }
          component.set('v.conditionsOfInterestTemp', pills);
        }
    
})