({
    createPieCharts: function (component, event, helper) {
        this.createPie(component, event, helper, '.pieID--categories');
    },
    createPie: function (component, event, helper, id) {

        var listData = [],
            listTotal = 0,
            offset = 0,
            pieElement = id + " .pie-chart__pie",
            color = [
                component.get("v.primaryColor"),
                component.get("v.secondaryColor")
            ];

        listData.push(Number(component.get("v.percent")));
        listData.push(100 - Number(component.get("v.percent")));

        for (var i = 0; i < listData.length; i++) {
            listTotal += listData[i];
        }

        for (i = 0; i < listData.length; i++) {
            var size = this.sliceSize(listData[i], listTotal);
            this.iterateSlices(id, size, pieElement, offset, i, 0, color[i]);
            offset += size;
        }
    },
    addSlice: function (id, sliceSize, pieElement, offset, sliceID, color) {

        $(pieElement).append("<div class='slice " + sliceID + "'><span></span></div>");
        // var offset = offset - 1;
        var thisOffset = 0;
        if(offset){
            thisOffset= offset - 1;
        }
        var sizeRotation = -179 + sliceSize;

        $(id + " ." + sliceID).css({
            "transform": "rotate(" + thisOffset + "deg) translate3d(0,0,0)"
        });

        $(id + " ." + sliceID + " span").css({
            "transform": "rotate(" + sizeRotation + "deg) translate3d(0,0,0)",
            "background-color": color
        });
    },
    iterateSlices: function (id, sliceSize, pieElement, offset, dataCount, sliceCount, color) {

        var maxSize = 179,
            sliceID = "s" + dataCount + "-" + sliceCount;

        if (sliceSize <= maxSize) {
            this.addSlice(id, sliceSize, pieElement, offset, sliceID, color);
        } else {
            this.addSlice(id, maxSize, pieElement, offset, sliceID, color);
            this.iterateSlices(id, sliceSize - maxSize, pieElement, offset + maxSize, dataCount, sliceCount + 1, color);
        }
    },
    sliceSize: function (dataNum, dataTotal) {
        return (dataNum / dataTotal) * 360;
    }
})