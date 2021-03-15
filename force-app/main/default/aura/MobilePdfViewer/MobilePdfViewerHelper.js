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
    }
})