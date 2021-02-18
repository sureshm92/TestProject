({
    
   
	loadpdf : function(component, event, helper) {
      //  alert('kkkkd');
      	var pdfjsframe = component.find('pdfFrame');
      //  alert(document.getElementById("pp").src);
      
        
        var idParamValue = helper.getURLParameterValue().pdfData;
       
        var resId = helper.getURLParameterValue().resId;
        
        var lang = helper.getURLParameterValue().lang;
        
      
        if(typeof idParamValue !== "undefined" ){
            
            component.set("v.wel","slds-hide");
           component.set("v.isResourceVisible","true");
             var ss= idParamValue.split(' ').join('+');
             component.set("v.pdfData",ss);
           
		helper.loadpdf(component,event);
        }
        else
        {
            if(typeof resId  !== "undefined" ){
                 component.set("v.wel","slds-hide");
      //   alert('resId'+resId+',lang'+lang);
             communityService.executeAction(component, 'getBase64Resource', {
            resourceId: resId,
            language: lang,
           
        },
          function (returnValue) {
           
               component.set("v.pdfData",returnValue);
              helper.loadpdf(component,event);
             
            }                                 );
                }
            else
            {
                 component.set("v.isResourceVisible","false");
              //  alert('hello111333');
                 
                try{
              //   component.set("v.isQuickReferenceVisible","true");
                 var resourceName = helper.getURLParameterValue().resourceName;
                
                   var webViewer = $A.get('$Resource.pdfjs_dist') + '/web/viewer.html';
       // window.open(webViewer + '?file=' + $A.get('$Resource.' + quickReference), '_blank');
           var iframe = document.getElementById("frame"); 
           iframe.src=$A.get('$Resource.pdfjs_dist') + '/web/viewer.html'+'?file='+ $A.get('$Resource.' + resourceName);
           //var stt=$A.get('$Resource.pdfjs_dist') + '/web/viewer.html'+'?file='+ $A.get('$Resource.' + resourceName);
          // component.set("v.url",stt);
                    //iframe.onload = null();
                    
                 //   alert('pppp');
                //alert(document.getElementById("pp").src);
                component.set("v.blr","slds-hide");
                }
                catch(err) {
                    alert(err.message);
                }
            }
        }
      
	},
    handleApplicationEvent : function(cmp, event) {
        alert('handled');
        var message = event.getParam("message");
          cmp.set("v.pdfData",message);
        // set the handler attributes based on event data
       
    },
    
    doSomething : function(component,event, helper) {
      alert('do something23');
        window.open('https://sandbox-fun-agility-8167-dev-ed-1771a7e7140.cs40.force.com/sfc/servlet.shepherd/document/download/06954000000JrMFAA0');
               // var link = document.getElementById("abc");
       // helper.loadContent(component,event);
     //   communityService.navigateToPage('demq');
     //   link.setAttribute('href', "http://facebook.com");
//return false;
/**var pdfData = component.get('v.pdfData');
         var link = document.getElementById("abc");
        alert('set attribut');
        link.setAttribute('href', "data:application/pdf;content-disposition:attachment;base64,"+pdfData);
       window.open("data:application/pdf;content-disposition:attachment;base64,"+pdfData);
        return false;
**/
    } ,
    
    
    backToPreviousPage : function(cmp, event) {
        
window.history.back();        
    }
})