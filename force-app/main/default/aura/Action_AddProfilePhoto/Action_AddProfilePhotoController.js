({
    onInit: function (component) {
        component.find('spinner').show();
        communityService.executeAction(
            component,
            'getProfilePicture',
            {
                parentId: component.get('v.recordId'),
                userMode: component.get('v.userMode')
            },
            function (returnValue) {
                var attachment = returnValue;
                component.set('v.pictureSrc', attachment);

                component.find('spinner').hide();
            }
        );
    },

    onDragOver: function (component, event) {
        event.preventDefault();
    },

    onDrop: function (component, event, helper) {
        var fileInput = component.find('file').getElement();
        var file = fileInput.files[0];

        helper.readFile(component, helper, file);
    },
    myFunction: function (component, event, helper) {
        var cmpTarget = component.find('myDropdown');
        var toggleButton = component.get('v.toggleButton');
        toggleButton = !toggleButton;
        component.set('v.toggleButton', toggleButton);

        $A.util.toggleClass(cmpTarget, 'show');
        if (toggleButton) {
            window.addEventListener(
                'click',
                function (event) {
                    if (!event.target.matches('.dropbtn')) {
                        var dropdowns = document.getElementsByClassName('dropdown-content');
                        var i;
                        for (i = 0; i < dropdowns.length; i++) {
                            var openDropdown = dropdowns[i];
                            console.log('open--->' + openDropdown.classList.contains('show'));
                            if (openDropdown.classList.contains('show')) {
                                openDropdown.classList.remove('show');
                                toggleButton = !toggleButton;
                                component.set('v.toggleButton', toggleButton);
                                $A.util.toggleClass(cmpTarget, 'show');
                            }
                        }
                    }
                },
                false
            );
        }
        /*if(toggleButton){
          window.addEventListener("click", function(event) {
       if (!event.target.matches('.dropbtn')) {

    var dropdowns = document.getElementsByClassName("dropdown-content");
    var i;
    for (i = 0; i < dropdowns.length; i++) {
      var openDropdown = dropdowns[i];
		console.log('open--->'+openDropdown.classList.contains('show'));
      if (openDropdown.classList.contains('show')) {
          
         openDropdown.classList.remove('show');

      }
        
    }
  }
    }, false);
            
        }*/
    },
    removeCSS: function (component, event, helper) {
        console.log('inside removeCSS');
        var cmpTarget = component.find('myDropdown');
        console.log('inside myFunction' + cmpTarget);
        // $A.util.removeClass(cmpTarget, 'dropdown-content');
        $A.util.toggleClass(cmpTarget, 'hide');
        //$A.util.addClass(cmpTarget, 'dropbtn');
    },
    removePhoto: function (component, event, helper) {
        communityService.executeAction(
            component,
            'deletePicture',
            {
                parentId: component.get('v.recordId')
            },
            function (returnValue) {
                sessionStorage.setItem('Cookies', 'Accepted');
                window.location.reload(true);
            }
        );
        sessionStorage.setItem('Cookies', 'Accepted');
        window.location.reload(true);
    }
});
