({
    
    onInit: function(component) {
        component.find('spinner').show();
        communityService.executeAction(component, 'getProfilePicture', {
            parentId: component.get('v.recordId')
        }, function (returnValue) {
             var attachment=returnValue;
            component.set('v.pictureSrc',attachment);

            component.find('spinner').hide();
        });
     
    },
     
    onDragOver: function(component, event) {
        event.preventDefault();
    },
 
    onDrop: function(component, event, helper) {
      
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        

       
        helper.readFile(component, helper, file);
    }
})