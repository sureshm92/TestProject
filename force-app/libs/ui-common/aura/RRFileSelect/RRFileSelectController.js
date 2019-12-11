/**
 * Created by Leonid Bartenev
 */
({
    onFileSelect: function (component, event, helper) {
        var files = event.target.files;
        helper.handleFileSelection(component, files);
    },

    onDragOver: function (component, event, helper) {
        event.preventDefault();
    },

    onDrop: function (component, event, helper) {
        event.stopPropagation();
        event.preventDefault();
        event.dataTransfer.dropEffect = 'copy';
        var files = event.dataTransfer.files;
        helper.handleFileSelection(component, files);
    },

    doReset: function (component, event, helper) {
        component.set('v.placeholder', 'Or drop here');
        component.set('v.fileContent', null);
        document.getElementById(component.get('v.selectorId') + '_input').value = "";
    }

})