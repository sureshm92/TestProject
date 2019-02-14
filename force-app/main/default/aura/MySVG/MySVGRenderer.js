/**
 * Created by Leonid Bartenev
 */
({
    render: function(component, helper) {
        var classname = component.get("v.class");
        var xlinkhref = component.get("v.xlinkHref");
        var ariaHidden = component.get("v.ariaHidden");
        var id = component.get('v.id');
        var color = component.get('v.color');

        var svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        if (id) {
            svg.setAttribute('id', id);
        }

        if (classname) {
            svg.setAttribute('class', classname);
        }

        if(color) {
            svg.setAttribute('style', 'fill: ' + color);
        }

        if (ariaHidden) {
            svg.setAttribute('aria-hidden', ariaHidden);
        }

        if (xlinkhref) {
            var use = document.createElementNS('http://www.w3.org/2000/svg', 'use');
            use.setAttribute('xmlns:xlink', 'http://www.w3.org/1999/xlink');
            use.setAttributeNS('http://www.w3.org/1999/xlink', 'xlink:href', xlinkhref);
            svg.appendChild(use);
        }

        var scriptEl = document.createElement('script');
        scriptEl.innerHTML = 'svg4everybody();';
        svg.appendChild(scriptEl);


        return svg;
    }
})