({
    toggleHelper: function (component, event) {
        var toggleText = component.find('tooltip');
        var tooltipdiv = document.getElementById('tooltip');
        window.onmousemove = function (event) {
            var x = event.clientX,
                y = event.clientY;
            component.set('v.tooltipTop', y - 100 + 'px');
            var dataVal = component.get('v.hovertext');
            if (dataVal == $A.get('$Label.c.Delegates')) {
                component.set('v.tooltipLeft', 265 - dataVal.length * 3 + 'px');
                if (component.get('v.isRTL')) {
                    //component.set('v.tooltipRight', 78-(dataVal.length*3)+'px');
                    component.set('v.tooltipRight', 'unset');
                }
            }
            if (dataVal == $A.get('$Label.c.PP_Account_Settings')) {
                component.set('v.tooltipLeft', 303 - dataVal.length * 3 + 'px');
                if (component.get('v.isRTL')) {
                    //component.set('v.tooltipRight', 36-(dataVal.length*3)+'px');
                    component.set('v.tooltipRight', 'unset');
                }
            }

            if (
                dataVal != $A.get('$Label.c.Delegates') &&
                dataVal != $A.get('$Label.c.PP_Account_Settings')
            ) {
                component.set('v.tooltipTop', y - 30 + 'px');
                component.set('v.tooltipLeft', '18px');
                if (component.get('v.isRTL')) {
                    component.set('v.tooltipRight', '18px');
                }
            }
        };

        $A.util.toggleClass(toggleText, 'toggle');
    },
    toggleHelperOut: function (component, event) {
        var toggleText = component.find('tooltip');
        $A.util.addClass(toggleText, 'toggle');
        var tooltipdiv = document.getElementById('tooltip');
        // $A.util.toggleClass(toggleText, "toggle");
    }
});
