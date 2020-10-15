(
    {
        doInit : function (component, event, helper) {
            if (communityService.isInitialized()) {
                communityService.executeAction(component, 'getNoTAMessage', {}, function (returnValue) {
                    component.set("v.noTAMessage", returnValue);
                });
                
                communityService.executeAction(component, 'hasCois', {}, function (returnValue) {
                    component.set("v.hascois", returnValue);
                });

            }

           if (communityService.getCurrentCommunityMode().currentDelegateId){
            component.set('v.isDelegate', true);}
           else{
            component.set('v.isDelegate', false);
            
        }
        },
        
        createArticles : function (component, event, helper) {
                        component.find('spinner').show();

             communityService.executeAction(component, 'createArticlesSubmitted', {
                url: component.get("v.submittedArticlesURL")
            }, function () {
                            component.find('spinner').hide();

               communityService.showToast('success', 'success',$A.get('$Label.c.Article_Submitted'),100);
               window.location.reload(true);
            });

            
        },
        handleUrlValidation : function (component, event, helper) {
            var inputValue = event.getSource().get("v.value");
            console.log('inside url validation-->'+inputValue);
            var urlField=component.find('urlField');
            console.log('inside urlField-->'+urlField);
            var validURLregex = /^(?:http(s)?:\/\/)?[\w.-]+(?:\.[\w\.-]+)+[\w\-\._~:\?#[\]@!\$&\(\)\*\+,;=.]+$/
            var validregex = /^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/mg;
            if(inputValue){
                if (validURLregex.test(inputValue) || validregex.test(inputValue)) {
                 urlField.setCustomValidity(" ");
                 component.set("v.disableSave",false);
              }
            else{
                 component.set("v.disableSave",true);
                 urlField.setCustomValidity($A.get('$Label.c.PP_URL_Error'));
            }
            }
            else{
                 urlField.setCustomValidity(" ");
                 component.set("v.disableSave",true);
            }
                         urlField.reportValidity();

        }
    }
)
