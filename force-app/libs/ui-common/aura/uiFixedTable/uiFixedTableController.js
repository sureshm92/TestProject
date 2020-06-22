/**
 * Created by Leonid Bartenev
 */
({
    doInit: function(component, event, helper){
        window.setTimeout(
            $A.getCallback(function() {
                let container = component.find('tableContainer');
                if (container && container.getElement()) {
                    let containerWidth = container.getElement().clientWidth;
                    component.set('v.width', containerWidth);
                }
                component.set('v.initialized', true);
            }), 100
        );
        window.addEventListener('resize', $A.getCallback(function() {
            let container = component.find('tableContainer');
            if (container && container.getElement()) {
                let containerWidth = container.getElement().clientWidth;
                component.set('v.width', containerWidth);
            }
        }));
    },

    doScroll: function (component, event, hepler) {
        let scrollLeft = event.currentTarget.scrollLeft;
        component.set('v.scrollLeft', scrollLeft);
    }

})