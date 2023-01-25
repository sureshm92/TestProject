({
    doInit: function (component, event, helper) {
        component.set('v.notes', '');
        communityService.executeAction(
            component,
            'getNotesdata',
            {
                MediaRecordId: component.get('v.recordId')
            },
            function (returnValue) {
                var resultData = JSON.parse(returnValue);
                component.set('v.NotesData', resultData.CD);
            }
        );
    },
    submitDetails: function (component, event, helper) {
        var dataval = component.get('v.notes');
        if (dataval == '' || dataval == ' ' || dataval == '  ') {
            component.set('v.validated', false);
        } else {
            component.set('v.validated', true);
        }
        if (component.get('v.validated')) {
            communityService.executeAction(
                component,
                'UpdateNotes',
                {
                    MediaRecordId: component.get('v.recordId'),
                    notes: component.get('v.notes')
                },
                function (returnValue) {}
            );
            component.set('v.isOpen', false);
            communityService.reloadPage();
        }
    },
    openModel: function (component, event, helper) {
        component.set('v.isOpen', true);
        component.set('v.notes', '');
    },
    closeModel: function (component, event, helper) {
        component.set('v.isOpen', false);
        component.set('v.notes', '');
    }
});
