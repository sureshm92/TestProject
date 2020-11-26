/**
 * Created by Alexey Moseev.
 */
({
    doInit: function (component, event, helper) {
        component.set('v.peList', null);
        window.setTimeout(
            $A.getCallback(function () {
                //helper.totalAwaitingContactedList(component);
                helper.callServerMethod(component, event, helper);
            }),
            150
        );
    },

    showEditParticipantInformation: function (component, event, helper) {
        helper.showEditParticipantInformation(component, event, helper);
    },

    sortRecords: function (component) {
        var peList = component.get('v.peList');
        if (component.get('v.defaultSorting')) {
            peList.sort(function (a, b) {
                var daysAddedA = a.daysAdded;
                var daysAddedB = b.daysAdded;
                if (daysAddedA < daysAddedB) {
                    return -1;
                }
                if (daysAddedA > daysAddedB) {
                    return 1;
                }
                return 0;
            });
            component.set('v.peList', peList);
            component.set('v.defaultSorting', false);
        } else {
            peList.sort(function (a, b) {
                var daysAddedA = a.daysAdded;
                var daysAddedB = b.daysAdded;
                if (daysAddedA > daysAddedB) {
                    return -1;
                }
                if (daysAddedA < daysAddedB) {
                    return 1;
                }
                return 0;
            });
            component.set('v.peList', peList);
            component.set('v.defaultSorting', true);
        }
    }
});
