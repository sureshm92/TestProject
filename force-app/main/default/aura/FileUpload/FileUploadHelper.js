({
    handleInit: function(component, fileWrapper){
        component.set('v.fileWrapper', fileWrapper);
        if(fileWrapper['listOfFiles'].length > 0){
            component.set('v.containsAnyFiles', true);
        }
        component.find('spinner').hide();
    }
})