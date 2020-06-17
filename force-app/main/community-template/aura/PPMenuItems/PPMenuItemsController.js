/**
 * Created by Olga Skrynnikova on 6/10/2020.
 */

({
    doOnClick: function (component, event) {
        let onclickEvent = component.getEvent('onclick');
        onclickEvent.setParam('source', event.getSource());
        component.getEvent('onclick').fire();
    },
});