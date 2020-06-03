/**
 * Created by Nargiz Mamedova on 5/18/2020.
 */

({
    changeValue: function (component, event, helper) {
        var actValue = component.find('actValue');
        let wrapper = component.get('v.wrapper'),
            showPercentage = component.get('v.showPercentage');
        let value = component.get('v.value'),
            minValue,
            maxValue;

        if (wrapper.minValue && wrapper.maxValue) {
            minValue = wrapper.minValue;
            maxValue = wrapper.maxValue;
        } else if (wrapper.minValue) {
            minValue = wrapper.minValue;
            if (wrapper.value < wrapper.minValue) maxValue = 1.5 * wrapper.minValue - 0.5 * wrapper.value;
            else maxValue = 2 * wrapper.value - wrapper.minValue;
        } else {
            minValue = 0;
            maxValue = wrapper.maxValue;
        }

        if ((minValue || maxValue) && !wrapper.value) value = 'N/A';

        component.set('v.value', value);
        component.set('v.minValue', minValue);
        component.set('v.maxValue', maxValue);

        if (!showPercentage || value) {
            $A.util.addClass(actValue, 'actual-value-no-expected-range');
        } else helper.alignTrack(component);
    },

    alignTrack: function (component, event, helper) {
        var arrDown = component.find('arrDown');
        let wrapper = component.get('v.wrapper');
        let minValue = component.get('v.minValue');
        let maxValue = component.get('v.maxValue');
        let arrowMargin = (wrapper.value - minValue) * 100 / (maxValue - minValue) - 4;
        let trackWidth;

        $A.util.removeClass(arrDown, 'hidden');
        $A.util.addClass(arrDown, 'arrow-down');

        if (minValue <= wrapper.value && wrapper.value <= maxValue) trackWidth = 100;
        else {
            if (minValue > wrapper.value) {
                trackWidth = (1 - (minValue - wrapper.value) / (maxValue - wrapper.value)) * 100;
                arrowMargin = (100 - trackWidth) / 2;
                component.set('v.trackMargin', 100 - trackWidth);
            } else trackWidth = (maxValue - minValue) * 100 / (wrapper.value - minValue);
            component.set('v.arrowColor', '#d9d9d9')
        }
        component.set('v.trackWidth', trackWidth);

        if (arrowMargin > 2) {
            if (arrowMargin < 96) component.set('v.arrowMargin', arrowMargin);
            else component.set('v.arrowMargin', 96);

            let valueLength = wrapper.value.toString().length;
            if(wrapper.measurement) valueLength += (' ' + wrapper.measurement).length;

            if (valueLength <= arrowMargin && arrowMargin <= 96 - valueLength) {
                component.set('v.valueMargin', arrowMargin - valueLength);
            } else if (arrowMargin > 96 - valueLength) {
                if(wrapper.measurement) component.set('v.valueMargin', 94 - 2*valueLength);
                else component.set('v.valueMargin', 94 - valueLength);
            }
        }
    },
});