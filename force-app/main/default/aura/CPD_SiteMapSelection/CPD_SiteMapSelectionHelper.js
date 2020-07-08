({
    callApexMethod: function (component) {
        var action = component.get("c.getsiteDistanceCalculation");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.distaceStudySites', JSON.parse(response.getReturnValue()));
                component.set('v.loaded', false);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        alert(errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },

    waitAccountCheckResult: function (component, iteration) {
        var helper = this;
        if (iteration === 15) {
            helper.callApexMethod(component);
            return;
        }
        else {
            var action = component.get("c.getTmpAccount");
            action.setCallback(this, function (response) {
                var result = response.getReturnValue();
                console.log(JSON.stringify(result));
                //console.log(result.BillingGeocodeAccuracy);
                if (result.BillingGeocodeAccuracy == 'undefined' || result.BillingGeocodeAccuracy == null || result.BillingGeocodeAccuracy == 'unknown') {
                    window.setTimeout(
                        $A.getCallback(function () {
                            console.log('***iteration' + iteration);
                            helper.waitAccountCheckResult(component, iteration + 1);
                        }), 500
                    );
                }
                else {
                    // console.log('within');
                    this.callApexMethod(component);
                    return;
                }
            });
            $A.enqueueAction(action);
        }
    },

    buttonactive : function (component, event) {
        var arr = [];
        arr = component.find("main").getElement().childNodes;
        console.log(event.target);
        for (var cmp in component.find("main").getElement().childNodes) {
            $A.util.removeClass(arr[cmp], "selectedRow");
        }
        var targetElement = event.target;
        $A.util.addClass(targetElement, "selectedRow");
    

       /* var header = document.getElementById("myDIV");
        var btns = header.getElementsByClassName("btn");
        for (var i = 0; i < btns.length; i++) {
            btns[i].addEventListener("click", function () {
                var current = document.getElementsByClassName("active");
                current[0].className = current[0].className.replace(" active", "");
                this.className += " active";
            });
        }*/
    }

})