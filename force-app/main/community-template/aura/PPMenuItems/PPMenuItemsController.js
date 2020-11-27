/**
 * Created by Olga Skrynnikova on 6/10/2020.
 */

({
    doInit: function (component, event, helper) {
        //helper.toggleHelper(component, event);
    },
    doOnClick: function (component, event) {
        let onclickEvent = component.getEvent('onclick');
        onclickEvent.setParam('source', event.getSource());
        onclickEvent.fire();
    },
    display: function (component, event, helper) {
        window.onblur = function () {
            console.log('Got focus');
            var toggleText = component.find('tooltip');
            $A.util.addClass(toggleText, 'tooltipNotActive');
        };
        /* if(event.getParams().keyCode==18){
          var toggleText = component.find("tooltip");
         $A.util.addClass(toggleText, 'tooltipNotActive');
      }*/
        var dataVal = event.currentTarget.dataset.id;
        component.set('v.hovertext', dataVal);
        var cmpTarget = component.find('tooltip');
        if (dataVal == $A.get('$Label.c.Delegates')) {
            if (component.get('v.isRTL')) {
                $A.util.addClass(cmpTarget, 'tooltipRTL');
                $A.util.removeClass(cmpTarget, 'tooltip');
                $A.util.removeClass(cmpTarget, 'slds-nubbin--top-right');
            } else {
                $A.util.addClass(cmpTarget, 'tooltip');
                $A.util.removeClass(cmpTarget, 'tooltipRTL');
            }
            $A.util.addClass(cmpTarget, 'slds-nubbin--bottom');
            $A.util.removeClass(cmpTarget, 'tooltipAS');
            $A.util.removeClass(cmpTarget, 'tooltipASRTL');
            $A.util.removeClass(cmpTarget, 'tooltipSubTitle');
            $A.util.removeClass(cmpTarget, 'tooltipSubTitleRTL');
            $A.util.removeClass(cmpTarget, 'slds-nubbin--top-left');
            $A.util.removeClass(cmpTarget, 'tooltipNotActive');
        } else if (dataVal == $A.get('$Label.c.PP_Account_Settings')) {
            if (component.get('v.isRTL')) {
                $A.util.addClass(cmpTarget, 'tooltipASRTL');
                $A.util.removeClass(cmpTarget, 'tooltipAS');
                $A.util.removeClass(cmpTarget, 'slds-nubbin--top-right');
            } else {
                $A.util.addClass(cmpTarget, 'tooltipAS');
                $A.util.removeClass(cmpTarget, 'tooltipASRTL');
            }
            $A.util.addClass(cmpTarget, 'slds-nubbin--bottom');
            $A.util.removeClass(cmpTarget, 'tooltip');
            $A.util.removeClass(cmpTarget, 'tooltipRTL');
            $A.util.removeClass(cmpTarget, 'tooltipSubTitle');
            $A.util.removeClass(cmpTarget, 'tooltipSubTitleRTL');
            $A.util.removeClass(cmpTarget, 'slds-nubbin--top-left');
            $A.util.removeClass(cmpTarget, 'tooltipNotActive');
        } else if (dataVal == $A.get('$Label.c.No_active_studies')) {
            $A.util.addClass(cmpTarget, 'tooltipNotActive');
        } else {
            if (component.get('v.isRTL')) {
                $A.util.addClass(cmpTarget, 'slds-nubbin--top-right');
                $A.util.addClass(cmpTarget, 'tooltipSubTitleRTL');
                $A.util.removeClass(cmpTarget, 'tooltipSubTitle');
            } else {
                $A.util.addClass(cmpTarget, 'slds-nubbin--top-left');
                $A.util.addClass(cmpTarget, 'tooltipSubTitle');
                $A.util.removeClass(cmpTarget, 'tooltipSubTitleRTL');
            }
            $A.util.removeClass(cmpTarget, 'tooltip');
            $A.util.removeClass(cmpTarget, 'tooltipAS');
            $A.util.removeClass(cmpTarget, 'tooltipRTL');
            $A.util.removeClass(cmpTarget, 'tooltipASRTL');
            $A.util.removeClass(cmpTarget, 'slds-nubbin--bottom');
            $A.util.removeClass(cmpTarget, 'tooltipNotActive');
        }

        $A.util.addClass(cmpTarget, 'tooltip');
        if (dataVal != $A.get('$Label.c.No_active_studies')) {
            helper.toggleHelper(component, event);
        }
    },
    displayOut: function (component, event, helper) {
        helper.toggleHelperOut(component, event);
    }
});
