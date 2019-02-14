/**
 * Created by Leonid Bartenev
 */
({
    FILE_SIZE_LIMIT: 2000000,
    FILE_TOTAL_SIZE_LIMIT: 10000000,

    handleFileSelection: function (component, files) {
        for(var i = 0; i < files.length; i++){
            this.setFile(component, files[i]);
        }
    },

    setFile: function (component, file)  {
        if (file.size > this.FILE_SIZE_LIMIT) {
            communityService.showErrorToast('Error', $A.get("$Label.c.TST_Screenshot_size_limit_2MB_exceeded"));
            return;
        }
        var fr = new FileReader();
        var helper = this;
        fr.onloadend = $A.getCallback(function() {
            var fileContents = fr.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            var fileContent = fileContents.substring(dataStart);
            component.set('v.placeholder', file.name);
            component.set('v.fileContent', fileContent);
        });
        fr.readAsDataURL(file);
    }

})