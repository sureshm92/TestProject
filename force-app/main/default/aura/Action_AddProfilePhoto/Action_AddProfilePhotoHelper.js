({
    
    MAX_FILE_SIZE: 3000000,

    readFile: function(component, helper, file) {
        if (!file) return;
        if (!file.type.match(/(image.*)/)) {
            communityService.showToast('error', 'error', $A.get('$Label.c.TST_Screenshot_Wrong_Format'));

            return;


        }

       
   
        if (file.size > this.MAX_FILE_SIZE) {
            communityService.showToast('error', 'error', $A.get('$Label.c.PP_File_Size_Exceeded'));

          
            return;


           
        }
    
       
        var self = this;

        var reader = new FileReader();
        reader.onloadend = function() {
            var fileContents = reader.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;

            fileContents = fileContents.substring(dataStart);
        
    	    self.upload(component, file, fileContents);
 
            component.set("v.pictureSrc", fileContents);
        };
        reader.readAsDataURL(file);
    },
     
    upload: function(component, file, base64Data) {
        component.find('spinner').show();
        communityService.executeAction(component, 'saveAttachment', {
            parentId: component.get("v.recordId"),
            fileName: file.name,
            base64Data:encodeURIComponent(base64Data), 
            contentType: file.type
        }, function (returnValue) {
            var attachment = returnValue;
            component.set('v.pictureSrc',attachment);
            component.set("v.message", "Image uploaded");
            component.set("v.pictureSrc",returnValue);
            var appEvent = $A.get("e.c:RefreshProfile");
            appEvent.setParams({
            "refreshFlag" : "true" });
            appEvent.fire();
           // $A.get('e.force:refreshView').fire();
            
            component.find('spinner').hide();
        });
      

    
    }
 
})