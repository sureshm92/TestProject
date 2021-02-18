({

	loadpdf:function(component,event){
       // alert('loadingg....');
		try{
			var pdfData = component.get('v.pdfData');
          //  alert(pdfData);
			var pdfjsframe = component.find('pdfFrame');
			if(typeof pdfData != 'undefined'){
				pdfjsframe.getElement().contentWindow.postMessage(pdfData,'*');	
               // var str = '<p>Some more <span>text</span> here</p>';
               // alert("data:text/html;charset=utf-8," + escape(str));
              //  pdfjsframe.getElement().contentWindow.postMessage(document.getElementById("sample").select().value,'*');
               // alert('reachedxyz');
               // alert(btoa(str));
               //.contentWindow.document.write("<html><body>Hello world</body></html>");
                // pdfjsframe.getElement().insertAdjacentHTML( 'beforeend', str );
               // pdfjsframe.getElement().innerHTML = str;
            // pdfjsframe.src = "data:text/html;charset=utf-8," + escape(str);
             
                // window.open("data:application/octet-stream;charset=utf-16le;base64,"+pdfData);
                //window.open("data:application/pdf;base64," + pdfData);
                //
                //
                //alert('here finally');
             


//window.open('data:application/pdf;content-disposition:attachment;base64,'+ pdfData, '_system', 'location=yes');
			// sforce.one.navigateToURL('salesforce1://ContentDocument/06954000000JrMFAA0/download');
            }
		}catch(e){
			alert('Error: ' + e.message);
		}
      //   var webViewer = $A.get('$Resource.lcins1_pdfjs') + '/web/viewer.html';
      //  var w = window.open(webViewer+'?file='+pdfData);///resource/lcins1_pdfjs/web/
/**w.addEventListener('load', function () {

  //var res="JVBERi0xLjUK..."; // Base64 String from response shortened

 // var pdfData = base64ToUint8Array(res);
    var raw = atob(pdfData);
    var uint8Array = new Uint8Array(raw.length);
    for(var i = 0; i < raw.length; i++) {
      uint8Array[i] = raw.charCodeAt(i);
    }
     var pdfData1 = uint8Array;
 // w.PDFViewerApplication.open(pdfData1);

 /** function base64ToUint8Array(base64) {
    var raw = atob(base64);
    var uint8Array = new Uint8Array(raw.length);
    for(var i = 0; i < raw.length; i++) {
      uint8Array[i] = raw.charCodeAt(i);
    }
    return uint8Array;
  } **/
/**}, true); **/
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