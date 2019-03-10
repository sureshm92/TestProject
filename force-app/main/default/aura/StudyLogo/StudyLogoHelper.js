/**
 * Created by Leonid Bartenev
 */
({
    readFile: function(component, helper, file) {
        if (!file) return;
        if (!file.type.match(/(image.*)/)) {
            return alert('Image file not supported');
        }
        var reader = new FileReader();
        reader.onloadend = function() {
            var dataURL = reader.result;
            component.set('v.pictureSrc', dataURL);
            helper.upload(component);
        };
        reader.readAsDataURL(file);
    },

    upload: function(component) {
        var pictureSrc = component.get('v.pictureSrc');
        if(pictureSrc && pictureSrc.length > 130000) {
            alert('Image to large for profile picture');
            return;
        }
        component.find('spinner').show();
        communityService.executeAction(component, 'updateProfilePicture',{
            studyId: component.get('v.recordId'),
            pictureSrc: pictureSrc
        }, function () {
        }, null, function () {
            component.find('spinner').hide();
        });
    }
})