/* 
    Author: Leonid Bartenev 
*/

d3.funnel = function () {

    var funnelWidth;
    var radius;
    var areaWidth;
    var height;
    var value;
    var yShift;
    var xShift;

    function funnel(data) {
        var sectionHeight = height / data.length;
        var y1 = 0;
        var y2;
        var x1 = radius;
        var x2;
        var initValue = +value(data[0]);
        if (initValue === 0) x1 = 0;
        for(var i = 0; i < data.length; i++){
            var item = data[i];
            y2 = y1 + sectionHeight;
            if( i < (data.length - 1)){
                if(initValue !== 0){
                    x2 = value( data[i + 1]) * radius/ initValue;
                }else{
                    x2 = 0;
                }
            }else{
                x2 = 0;
            }
            //if(x1 === 0) x1 = 1;
            //if(x2 === 0) x2 = 1;
            item.coordinates = [
                {x: x1 + xShift, y: y1 + yShift},
                {x: x2 + xShift, y: y2 + yShift},
                {x: -x2 + xShift, y: y2 + yShift},
                {x: -x1 + xShift, y: y1 + yShift}
            ];
            item.lineCoordinates = [
                {x: xShift, y: y1 + yShift + .5},
                {x: areaWidth - 1, y: y1 + yShift + .5}
            ];
            item.sectionInfoBlock = {
                x: radius + xShift,
                y: y1 + yShift,
                width: areaWidth - (radius + xShift),
                height: sectionHeight
            };
            y1 = y2;
            x1 = x2;
        }
        return data;
    }

    funnel.size = function (fw, fh, aw) {
        areaWidth = aw;
        if(areaWidth <= 450){
            funnelWidth = 0.5 * areaWidth;
            xShift = 0;
            radius = funnelWidth / 2;

        }else{
            funnelWidth = fw;
            radius = funnelWidth / 2;
            xShift = radius;

        }
        yShift = 2;
        height = fh - yShift;
        return funnel;
    };

    funnel.value = function (v) {
        value = v;
        return funnel;
    };

    return funnel;
};