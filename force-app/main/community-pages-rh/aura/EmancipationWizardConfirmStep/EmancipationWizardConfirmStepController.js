/**
 * Created by Aleksey Moseev
 */
({

    doEditParticipant: function (component, event, hepler) {
        component.set('v.currentTab', '1');
    },

    doEditDelegate: function (component, event, hepler) {
        component.set('v.currentTab', '2');
    },

})