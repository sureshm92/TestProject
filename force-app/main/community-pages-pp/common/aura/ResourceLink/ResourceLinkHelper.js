/**
 * Created by Leonid Bartenev
 */
({
    viewResource: function (component,resource, languageCode) {
       if (communityService.isMobileSDK()) { 
          /**  communityService.showWarningToast(
                'Warning!',
                $A.get('$Label.c.Pdf_Not_Available'),
                100
            ); **/
            if(resource.RecordType.DeveloperName=='Video') communityService.navigateToPage(url);
            communityService.navigateToPage('pdfdemo?resId=' + resource.Id+'&lang=' + languageCode);
            return;           
       }
         var device = $A.get("$Browser.formFactor");
         if(device=='PHONE' &&  resource.RecordType.DeveloperName=='Study_Document'){
        try{
         communityService.executeAction(component, 'getBase64Resource', {
          resourceId: resource.Id,
          language: languageCode,

        },
          function (returnValue) {         
            let urlEvent = $A.get('e.force:navigateToURL');            
            let byteCharacters = atob(returnValue);
            let byteNumbers = new Array(byteCharacters.length);
            for (let i = 0; i < byteCharacters.length; i++) {
                byteNumbers[i] = byteCharacters.charCodeAt(i);
            }
            let ieEDGE = navigator.userAgent.match(/Edge/g);
            let ie = navigator.userAgent.match(/.NET/g);
            let oldIE = navigator.userAgent.match(/MSIE/g);
            let bytes = new Uint8Array(byteNumbers); //use this if data is raw bytes else directly pass resData
            let blob = new window.Blob([bytes], {type : 'application/pdf'});
            let absoluteURL = window.location.origin;
               if (ie || oldIE || ieEDGE) {
                window.navigator.msSaveBlob(blob, fileName + '.pdf');
            } else {
            let fileURL = URL.createObjectURL(blob);
                 let urlViewer = $A.get('$Resource.pdfjs_dist') + '/web/viewer.html';
            urlEvent.setParams({
                url:
                    absoluteURL +
                    urlViewer +
                    '?file=' +
                    fileURL +
                    '&fileName=' +
                    encodeURIComponent(resource.Title__c)
            });
            urlEvent.fire();
            }      

          });            
           }catch(e)
        {
            alert(e.message);
        }
        }
        else
        {
        var url =
            'resources?resourceType=' + resource.RecordType.DeveloperName + '&resId=' + resource.Id;
        if (languageCode) url += '&lang=' + languageCode;
        url += '&ret=' + communityService.createRetString();   
        communityService.navigateToPage(url); 
        }
    }
    
});