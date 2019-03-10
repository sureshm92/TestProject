/**
 * Created by Leonid Bartenev
 */
({
    doInit: function(component, event, helper){
        component.find('spinner').show();
        communityService.executeAction(component, 'getStudyPicture', {
            studyId: component.get('v.recordId')
        }, function (studyPicture) {
            component.set('v.pictureSrc', studyPicture);
            component.set('v.initialized', true);
            debugger;
            component.find('spinner').hide();
        })
    },

    onDragOver: function(component, event) {
        event.preventDefault();
    },

    onDrop: function(component, event, helper) {
        event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        var files = event.dataTransfer.files;
        if (files.length>1) {
            return alert('You can only upload one profile picture');
        }
        helper.readFile(component, helper, files[0]);
    },

    doRemove: function (component, event, helper) {
        component.set('v.pictureSrc', null);
        helper.upload(component);
    }

})