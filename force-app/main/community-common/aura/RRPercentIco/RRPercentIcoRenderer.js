/**
 * Created by Leonid Bartenev
 */
({
    render: function(component, helper) {
        var classname = component.get("v.class");
        var color = component.get('v.color');
        var value = component.get('v.value');
        var width = component.get('v.diameter');

        var circleWidth = component.get('v.circleWidth');
        var borderWidth = component.get('v.borderWidth');
        var halfWidth = width / 2;
        var radius = halfWidth - (circleWidth / 2);
        var circleLength = radius * 2 * 3.14;
        var percentLength = (value / 100) * circleLength;
        var svgNS = 'http://www.w3.org/2000/svg';

        var svg = document.createElementNS(svgNS, 'svg');
        svg.setAttribute('width', width);
        svg.setAttribute('height', width);
        svg.setAttribute('viewBox', '0 0 ' + width + ' ' + width);
        if (classname) svg.setAttribute('class', classname);


        var circle1 = document.createElementNS(svgNS, 'circle');
        circle1.setAttribute('cx', halfWidth + '');
        circle1.setAttribute('cy', halfWidth + '');
        circle1.setAttribute('r', radius + '');
        circle1.setAttribute('fill', 'none');
        circle1.setAttribute('stroke', color);
        circle1.setAttribute('stroke-width', circleWidth + '');
        svg.appendChild(circle1);

        var circle2 = document.createElementNS(svgNS, 'circle');
        circle2.setAttribute('cx', halfWidth + '');
        circle2.setAttribute('cy', halfWidth + '');
        circle2.setAttribute('r', radius + '');
        circle2.setAttribute('fill', 'none');
        circle2.setAttribute('stroke', 'white');
        circle2.setAttribute('stroke-width', circleWidth - borderWidth * 2 + '');
        circle2.setAttribute('stroke-dasharray', circleLength + '');
        circle2.setAttribute('stroke-dashoffset', -percentLength + '');
        circle2.setAttribute('transform', 'rotate(-90, ' + halfWidth + ', ' + halfWidth + ')');
        svg.appendChild(circle2);

        return svg;
    }

})