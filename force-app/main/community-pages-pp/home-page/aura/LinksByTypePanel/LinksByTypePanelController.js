/**
 * Created by Nargiz Mamedova on 2/26/2020.
 */

({
    doInit: function (component, event, helper) {
        setTimeout(
            $A.getCallback(function () {
                var height = component.find("svb").getElement().clientHeight - 15;
                var linksWrapper = component.get('v.linksWrapper');
                if (linksWrapper.resources.length > 5) {
                    var cmpTarget = component.find('svb');
                    $A.util.addClass(cmpTarget, 'slds-scrollable_y');
                    component.set("v.height", "height:" + height + "px");
                    component.set("v.size", linksWrapper.resources.length);
                }
            })
        );
    }
});