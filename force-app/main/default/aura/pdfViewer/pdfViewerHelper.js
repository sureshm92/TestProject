({

	loadpdf:function(component,event){
     
		try{
			var pdfData = component.get('v.pdfData');
         
			var pdfjsframe = component.find('pdfFrame');
			if(typeof pdfData != 'undefined'){
				pdfjsframe.getElement().contentWindow.postMessage(pdfData,'*');	
             
            }
		}catch(e){
			alert('Error: ' + e.message);
		}
     
	},
    getURLParameterValue: function() {
 
        var querystring = location.search.substr(1);
        var paramValue = {};
        querystring.split("&").forEach(function(part) {
            var param = part.split("=");
            paramValue[param[0]] = decodeURIComponent(param[1]);
        });
  
        console.log('paramValue-' + paramValue);
        return paramValue;
    },
    
    loadContent : function(component,event){
        
        try{
        var pdfData = component.get('v.pdfData');
         var link = document.getElementById("abc");
        alert('set attributeee');
       // link.setAttribute('href', "data:application/pdf;content-disposition:attachment;base64,"+pdfData);
       // window.open("data:application/pdf;content-disposition:attachment;base64,"+pdfData, '_blank');
         //window.location.assign("data:application/pdf;content-disposition:attachment;base64,"+pdfData);
       

        }catch(err) {
  alert(err);
}
        return false;
    }
})