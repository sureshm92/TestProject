/**
 * Created by Slav on 29.10.2019.
 */

({
        sortData: function (component, fieldName, sortDirection) {
            var data = component.get("v.data");
            var reverse = sortDirection !== 'asc';
            data.sort(this.sortBy(fieldName, reverse))
            component.set("v.data", data);
        },

        sortBy: function (field, reverse, primer) {
            var key = primer ? function(x) {
                    return primer(x[field])
                } : function(x) {
                    return x[field]
                };
            reverse = !reverse ? 1 : -1;
            return function (a, b) {
                return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
            }
        },

//        startCheckDeploy : function(component, event, helper) {
//            var checkerId = window.setInterval(function() { helper.checkDeploy(component, event, helper); }, 3000);
//            component.set('v.checkerId', checkerId);
//        },
//
//        stopCheckDeploy: function(component, event, helper) {
//            window.clearInterval(component.get('v.checkerId'));
//            component.set('v.checkerId', null);
//        },
//
//        checkDeploy: function(component, event, helper) {
//            helper.stopCheckDeploy(component, event, helper);
//            var action = component.get("c.getDeployResult");
//            action.setCallback (this, function(response) {
//                if (response.getState() === "SUCCESS") {
//                    console.log('      SUCCESS -------deploy status '+response.getReturnValue());
//                } else if (response.getState() === "ERROR") {
//                    console.log('      ERROR-------deploy status '+response.getReturnValue());
//                }
//            })
//            $A.enqueueAction(action);
//        }
});