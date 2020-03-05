/**
 * Created by Igor Malyuta on 03.03.2020.
 */
const createCustomEvent = function (eventName, detail) {
    let evt;
    if(typeof window.CustomEvent === 'function') {
        evt = new CustomEvent(eventName, detail);
    } else {
        let params = {
            bubbles: false,
            cancelable: false,
            detail: null
        };
        evt = document.createEvent('CustomEvent');
        evt.initCustomEvent(eventName, params.bubbles, params.cancelable, params.detail);
    }

    return evt;
};


export {createCustomEvent}