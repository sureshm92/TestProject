({
	toggleHelper : function(component,event) {
        var toggleText = component.find("tooltip");
        var tooltipdiv = document.getElementById("tooltip");
        window.onmousemove = function (event) {                   
            var x = event.clientX,
                y = event.clientY;     
            component.set("v.tooltipTop",(y-100) + 'px');
            component.set("v.tooltipLeft",(x+100) + 'px');
            var dataVal = component.get("v.hovertext");
            if(dataVal!='Delegates' && dataVal!='Account Settings'){
                component.set("v.tooltipTop",(y-15) + 'px');
            }
        };
        
        $A.util.toggleClass(toggleText, "toggle");
    },
    toggleHelperOut : function(component,event) {  
        
        var toggleText = component.find("tooltip");
       $A.util.addClass(toggleText, 'toggle');
        var tooltipdiv = document.getElementById("tooltip");                      
       // $A.util.toggleClass(toggleText, "toggle");
        
    }
})