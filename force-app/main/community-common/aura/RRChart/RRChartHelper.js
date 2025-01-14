/**
 * Created by Leonid Bartenev
 */
({
    drawChart: function (component, helper) {
        var chartType = component.get('v.type');
        var chartToDraw = chartType + 'Chart';
        if (chartType === 'pie' || chartType === 'donut') chartToDraw = 'pieDonutChart';
        helper[chartToDraw](component, helper);
        component.set('v.chartRendered', true);
    },
    areaChart: function (component, helper) {
        component.set('v.displayAxis', true);
        var divContainer = d3.select(component.find('chart').getElement());
        var chartWidth = component.get('v.containerWidth');
        var chartHeight = helper.getHeight(chartWidth);
        helper.setyAxisLabelMaxHeight(component, chartHeight);
        var paddingBox = helper.getPaddingBox(chartWidth);

        var leftAxis = component.find('leftAxis').getElement();
        $A.util.removeClass(leftAxis, 'slds-hide');
        var leftAxisLabelWidth = leftAxis.clientHeight; //get height since we rotated
        chartWidth -= leftAxisLabelWidth;

        var svg = divContainer
            .append('svg')
            .attr('width', chartWidth)
            .attr('height', chartHeight)
            .attr('style', 'transform: translateX(' + leftAxisLabelWidth + 'px);');

        var dataWithThreshold = component.get('v.data').slice();
        dataWithThreshold.push({
            y: component.get('v.thresholdValue')
        });

        var xDomain = d3.extent(component.get('v.data'), function (d) {
            return d['x'];
        });

        var yDomain = d3.extent(dataWithThreshold, function (d) {
            return d['y'];
        });

        var xAxisDataType = component.get('v.xAxisDataType');
        var yAxisDataType = component.get('v.yAxisDataType');

        var xScale = xAxisDataType === 'number' ? d3.scaleLinear() : d3.scaleTime();
        xScale = xScale.range([paddingBox.left, chartWidth - paddingBox.right]).domain(xDomain);

        var yScale = yAxisDataType === 'number' ? d3.scaleLinear() : d3.scaleTime();
        yScale = yScale.range([chartHeight - paddingBox.bottom, paddingBox.top]).domain(yDomain);

        var numberValuesFormatFunc = function (d) {
            return helper.abbreviateNumber(d);
        };
        var dateValuesFormatFunc = function (d) {
            return d3.timeFormat('%b %d')(d);
        };

        var xAxis = helper.addBottomAxis(
            xScale,
            0,
            xAxisDataType === 'number' ? numberValuesFormatFunc : dateValuesFormatFunc
        );
        var yAxis = helper.addLeftAxis(
            yScale,
            0,
            yAxisDataType === 'number' ? numberValuesFormatFunc : dateValuesFormatFunc
        );

        var parentGrouping = svg.append('g');

        var area = d3
            .area()
            .x(function (d) {
                return xScale(d.x);
            })
            .y0(function (d) {
                return yScale(d.y);
            })
            .y1(chartHeight - paddingBox.bottom);

        parentGrouping
            .append('path')
            .datum(component.get('v.data'))
            .attr('class', 'sc-lc-area')
            .attr('d', area);

        parentGrouping
            .append('g')
            .attr('transform', 'translate(0,' + (chartHeight - paddingBox.bottom) + ')')
            .attr('class', 'x sc-axis')
            .call(xAxis);

        parentGrouping
            .append('g')
            .attr('transform', 'translate(' + paddingBox.left + ', 0)')
            .attr('class', 'y sc-axis')
            .call(yAxis);

        helper.shouldRotateXAxisLabels(parentGrouping, chartWidth);

        var line = d3
            .line()
            .x(function (d) {
                return xScale(d.x);
            })
            .y(function (d) {
                return yScale(d.y);
            });

        parentGrouping
            .append('path')
            .datum(component.get('v.data'))
            .attr('class', 'sc-line')
            .attr('d', line);

        var focus = parentGrouping.append('g').style('display', 'none');
        focus.append('line').attr('id', 'focusLineX').attr('class', 'sc-lc-focus-line');
        focus.append('line').attr('id', 'focusLineY').attr('class', 'sc-lc-focus-line');

        var thresholdParams = {
            thresholdValue: component.get('v.thresholdValue'),
            thresholdLabel: component.get('v.thresholdLabel'),
            chartWidth: chartWidth,
            parent: parentGrouping,
            lineX1: paddingBox.left,
            lineX2: chartWidth - paddingBox.right,
            lineY1: yScale(component.get('v.thresholdValue')),
            lineY2: yScale(component.get('v.thresholdValue')),
            textAnchor: 'end',
            textX: chartWidth - paddingBox.right,
            textY: yScale(component.get('v.thresholdValue')),
            rotateAngle: 0
        };

        helper.addThreshold(thresholdParams);

        // add inner circles
        var circles = parentGrouping.selectAll('circles').data(component.get('v.data')).enter();

        var getCircleX = function (d) {
            return xScale(d.x);
        };

        var getCircleY = function (d) {
            return yScale(d.y);
        };

        var circleParams = {
            parent: circles,
            circleX: getCircleX,
            circleY: getCircleY,
            radius: 5,
            cssClass: '',
            fill: 'white',
            stroke: '#00a1e0',
            strokeWidth: 2
        };

        var innerCircles = helper.addCircle(circleParams);

        innerCircles.on(
            'mouseover',
            $A.getCallback(function (d) {
                this.style.fill = 'red';
                var x = xScale(d.x);
                var y = yScale(d.y);
                $A.localizationService.formatDate(1474520400000, 'EEEE MMM dd, yyyy hh:mm A');
                focus
                    .select('#focusLineX')
                    .attr('x1', x)
                    .attr('y1', yScale(yDomain[0]))
                    .attr('x2', x)
                    .attr('y2', yScale(yDomain[1]));
                focus
                    .select('#focusLineY')
                    .attr('x1', xScale(xDomain[0]))
                    .attr('y1', y)
                    .attr('x2', xScale(xDomain[1]))
                    .attr('y2', y);

                focus.style('display', null);

                var firstTooltipLine;
                var secondTooltipLine;
                var formatPattern;
                var xDataType = component.get('v.xAxisDataType');
                var yDataType = component.get('v.yAxisDataType');

                if (xDataType === 'number') {
                    firstTooltipLine =
                        '<span class="sc-axis-label">' +
                        component.get('v.xAxisLabel') +
                        ': </span><span class="sc-axis-value">' +
                        helper.abbreviateNumber(d.x) +
                        '</span><br/>';
                } else {
                    formatPattern =
                        xDataType === 'date' ? 'EEEE MMM dd, yyyy' : 'EEEE MMM dd, yyyy hh:mm A';
                    firstTooltipLine =
                        '<span class="sc-axis-value">' +
                        $A.localizationService.formatDate(d.x, formatPattern) +
                        '</span><br/>';
                }

                if (yDataType === 'number') {
                    secondTooltipLine =
                        '<span class="sc-axis-label">' +
                        component.get('v.yAxisLabel') +
                        ': </span><span class="sc-axis-value">' +
                        helper.abbreviateNumber(d.y) +
                        '</span>';
                } else {
                    formatPattern =
                        yDataType === 'date' ? 'EEEE MMM dd, yyyy' : 'EEEE MMM dd, yyyy hh:mm A';
                    secondTooltipLine =
                        '<span class="sc-axis-value">' +
                        $A.localizationService.formatDate(d.y, formatPattern) +
                        '</span>';
                }

                var innerHtml = firstTooltipLine + secondTooltipLine;

                component.set('v.tooltipHtml', innerHtml);
            })
        );

        innerCircles.on(
            'mouseout',
            $A.getCallback(function (d) {
                this.style.fill = 'white';
                focus.style('display', 'none');
                helper.hideTooltip(component);
            })
        );

        innerCircles.on(
            'mousemove',
            $A.getCallback(function (d) {
                var mousePos = d3.mouse(component.find('chartContainer').getElement());

                var tooltipOptions = {
                    x: mousePos[0],
                    y: mousePos[1],
                    chartWidth: chartWidth
                };

                helper.showToolTip(component, tooltipOptions);
            })
        );
    },
    barChart: function (component, helper) {
        component.set('v.displayAxis', true);
        var isVertical = component.get('v.orientation') === 'vertical';
        var numericalAxis = isVertical ? 'y' : 'x';
        var stringAxis = isVertical ? 'x' : 'y';

        var xAxisLabel = component.get('v.xAxisLabel');
        var yAxisLabel = component.get('v.yAxisLabel');

        var divContainer = d3.select(component.find('chart').getElement());
        var chartWidth = component.get('v.containerWidth');
        var chartHeight = helper.getHeight(chartWidth);
        helper.setyAxisLabelMaxHeight(component, chartHeight);
        var paddingBox = helper.getPaddingBox(chartWidth);

        var leftAxis = component.find('leftAxis').getElement();
        $A.util.removeClass(leftAxis, 'slds-hide');
        var leftAxisLabelWidth = leftAxis.clientHeight; //get height since we rotated
        chartWidth -= leftAxisLabelWidth;

        var svg = divContainer
            .append('svg')
            .attr('width', chartWidth)
            .attr('height', chartHeight)
            .attr('style', 'transform: translateX(' + leftAxisLabelWidth + 'px);');

        var numericalDomain;
        var stringDomain;

        var numericalMax = d3.max(
            component.get('v.data').map(function (dataPoint) {
                return dataPoint[numericalAxis];
            })
        );

        numericalDomain = [0, d3.max([component.get('v.thresholdValue'), numericalMax])];

        stringDomain = component.get('v.data').map(function (dataPoint) {
            return dataPoint[stringAxis];
        });

        var numericalScale = d3.scaleLinear().domain(numericalDomain);
        var stringScale = d3.scaleBand().padding(0.1).domain(stringDomain);

        var numericalFormat = function (d) {
            return helper.abbreviateNumber(d);
        };

        var stringFormat = function (d) {
            return d;
        };

        var xScale;
        var yScale;
        var xTickFormatter;
        var yTickFormatter;

        if (isVertical) {
            xScale = stringScale;
            xTickFormatter = stringFormat;

            yScale = numericalScale;
            yTickFormatter = numericalFormat;
        } else {
            xScale = numericalScale;
            xTickFormatter = numericalFormat;

            yScale = stringScale;
            yTickFormatter = stringFormat;
        }

        xScale.range([paddingBox.left, chartWidth - paddingBox.right]);
        yScale.range([chartHeight - paddingBox.bottom, paddingBox.top]);

        var xAxis = helper.addBottomAxis(xScale, 0, xTickFormatter);
        var yAxis = helper.addLeftAxis(yScale, 0, yTickFormatter);

        var g = svg.append('g');

        var barY = function (d) {
            return yScale(d.y);
        };

        var colors = helper.getColors();

        var bars = g
            .selectAll('.sc-bc-bar')
            .data(component.get('v.data'))
            .enter()
            .append('rect')
            .attr('class', 'sc-bc-bar')
            .attr('y', barY)
            .attr('fill', function (d, i) {
                return colors(i);
            });

        if (isVertical) {
            var barX = function (d) {
                return xScale(d.x);
            };

            var barHeight = function (d) {
                return chartHeight - yScale(d.y) - paddingBox.bottom;
            };

            bars.attr('x', barX).attr('width', stringScale.bandwidth).attr('height', barHeight);
        } else {
            var barWidth = function (d) {
                return xScale(d.x) - paddingBox.left;
            };

            bars.attr('x', paddingBox.left)
                .attr('width', barWidth)
                .attr('height', stringScale.bandwidth);
        }

        bars.on(
            'mouseover',
            $A.getCallback(function (dataPoint) {
                var x = dataPoint.x;
                var y = dataPoint.y;

                if (numericalAxis === 'x') {
                    x = helper.abbreviateNumber(x);
                } else {
                    y = helper.abbreviateNumber(y);
                }

                var tooltipHtml =
                    '<span class="sc-axis-label">' +
                    xAxisLabel +
                    ': </span><span class="sc-axis-value">' +
                    x +
                    '</span><br/>' +
                    '<span class="sc-axis-label">' +
                    yAxisLabel +
                    ': </span><span class="sc-axis-value">' +
                    y +
                    '</span>';

                component.set('v.tooltipHtml', tooltipHtml);
            })
        );

        bars.on(
            'mouseout',
            $A.getCallback(function () {
                helper.hideTooltip(component);
            })
        );

        bars.on(
            'mousemove',
            $A.getCallback(function (dataPoint) {
                var mousePos = d3.mouse(component.find('chartContainer').getElement());

                var tooltipOptions = {
                    x: mousePos[0],
                    y: mousePos[1],
                    chartWidth: chartWidth
                };

                helper.showToolTip(component, tooltipOptions);
            })
        );

        var thresholdYPos = yScale(component.get('v.thresholdValue'));
        var thresholdParams = {
            thresholdValue: component.get('v.thresholdValue'),
            thresholdLabel: component.get('v.thresholdLabel'),
            chartWidth: chartWidth,
            parent: g
        };

        if (isVertical) {
            thresholdParams.lineX1 = paddingBox.left;
            thresholdParams.lineX2 = chartWidth - paddingBox.right;
            thresholdParams.lineY1 = thresholdYPos;
            thresholdParams.lineY2 = thresholdYPos;
            thresholdParams.textAnchor = 'end';
            thresholdParams.textX = chartWidth - paddingBox.right;
            thresholdParams.textY = thresholdYPos;
            thresholdParams.rotateAngle = 0;
        } else {
            thresholdParams.lineX1 = xScale(component.get('v.thresholdValue'));
            thresholdParams.lineX2 = xScale(component.get('v.thresholdValue'));
            thresholdParams.lineY1 = paddingBox.top;
            thresholdParams.lineY2 = chartHeight - paddingBox.bottom;
            thresholdParams.textAnchor = 'start';
            thresholdParams.textX = xScale(component.get('v.thresholdValue'));
            thresholdParams.textY = paddingBox.top;
            thresholdParams.rotateAngle = 90;
        }

        helper.addThreshold(thresholdParams);

        g.append('g')
            .attr('transform', 'translate(0,' + (chartHeight - paddingBox.bottom) + ')')
            .attr('class', 'x sc-axis')
            .call(xAxis);

        g.append('g')
            .attr('transform', 'translate(' + paddingBox.left + ', 0)')
            .attr('class', 'y sc-axis')
            .call(yAxis);

        helper.shouldRotateXAxisLabels(g, chartWidth);
    },
    bubbleChart: function (component, helper) {
        component.set('v.displayAxis', true);
        var data = component.get('v.data');
        var divContainer = d3.select(component.find('chart').getElement());
        var chartWidth = component.get('v.containerWidth');
        var chartHeight = helper.getHeight(chartWidth);
        helper.setyAxisLabelMaxHeight(component, chartHeight);
        var paddingBox = helper.getPaddingBox(chartWidth);
        var xAxisLabel = component.get('v.xAxisLabel');
        var yAxisLabel = component.get('v.yAxisLabel');

        var leftAxis = component.find('leftAxis').getElement();
        $A.util.removeClass(leftAxis, 'slds-hide');
        var leftAxisLabelWidth = leftAxis.clientHeight; //get height since we rotated
        chartWidth -= leftAxisLabelWidth;

        var svg = divContainer
            .append('svg')
            .attr('width', chartWidth)
            .attr('height', chartHeight)
            .attr('style', 'transform: translateX(' + leftAxisLabelWidth + 'px);');

        // Circles Calculations
        var sizeMin = 5;
        var sizeMax = Math.max(Math.min(chartWidth, chartHeight) * 0.05, sizeMin);

        var dataWithThreshold = data.slice();
        dataWithThreshold.push({
            y: parseInt(component.get('v.thresholdValue'), 10)
        });

        var xDomain = d3.extent(data, function (dataPoint) {
            return dataPoint.x;
        });

        var yDomain = d3.extent(dataWithThreshold, function (dataPoint) {
            return dataPoint.y;
        });

        var sizeDomain = d3.extent(data, function (dataPoint) {
            return dataPoint.size;
        });

        var dataXMin = xDomain[0];
        var dataXMax = xDomain[1];
        var dataYMin = yDomain[0];
        var dataYMax = yDomain[1];
        var dataSizeMin = sizeDomain[0];
        var dataSizeMax = sizeDomain[1];

        dataSizeMax = dataSizeMin === dataSizeMax ? dataSizeMax + 1 : dataSizeMax;
        dataXMax = dataXMin === dataXMax ? dataXMax + 1 : dataXMax;
        dataYMax = dataYMin === dataYMax ? dataYMax + 1 : dataYMax;

        var xScaleSizeBuffer = function () {
            return Math.abs(
                (sizeMax / (chartWidth - paddingBox.left - paddingBox.right)) *
                    (dataXMax - dataXMin)
            );
        };
        var yScaleSizeBuffer = function () {
            return Math.abs(
                (sizeMax / (chartHeight - paddingBox.bottom - paddingBox.top)) *
                    (dataYMax - dataYMin)
            );
        };

        xDomain = [dataXMin - xScaleSizeBuffer(), dataXMax + xScaleSizeBuffer()];
        yDomain = [dataYMin - yScaleSizeBuffer(), dataYMax + yScaleSizeBuffer()];

        var xAxisDataType = component.get('v.xAxisDataType');
        var yAxisDataType = component.get('v.yAxisDataType');

        var xScale = xAxisDataType === 'number' ? d3.scaleLinear() : d3.scaleTime();
        xScale = xScale.range([paddingBox.left, chartWidth - paddingBox.right]).domain(xDomain);

        var yScale = yAxisDataType === 'number' ? d3.scaleLinear() : d3.scaleTime();
        yScale = yScale.range([chartHeight - paddingBox.bottom, paddingBox.top]).domain(yDomain);

        var numberValuesFormatFunc = function (d) {
            return helper.abbreviateNumber(d);
        };
        var dateValuesFormatFunc = function (d) {
            return d3.timeFormat('%b %d')(d);
        };

        var xAxis = helper.addBottomAxis(
            xScale,
            0,
            xAxisDataType === 'number' ? numberValuesFormatFunc : dateValuesFormatFunc
        );
        var yAxis = helper.addLeftAxis(
            yScale,
            0,
            yAxisDataType === 'number' ? numberValuesFormatFunc : dateValuesFormatFunc
        );

        var g = svg.append('g');

        g.append('g')
            .attr('transform', 'translate(0,' + (chartHeight - paddingBox.bottom) + ')')
            .attr('class', 'x sc-axis')
            .call(xAxis);

        g.append('g')
            .attr('transform', 'translate(' + paddingBox.left + ', 0)')
            .attr('class', 'y sc-axis')
            .call(yAxis);

        helper.shouldRotateXAxisLabels(g, chartWidth);

        var color = helper.getColors();
        var sizeScale = function (size) {
            return Math.abs(
                ((size - dataSizeMin) / (dataSizeMax - dataSizeMin)) * (sizeMax - sizeMin) + sizeMin
            );
        };

        var thresholdParams = {
            thresholdValue: component.get('v.thresholdValue'),
            thresholdLabel: component.get('v.thresholdLabel'),
            chartWidth: chartWidth,
            parent: g,
            lineX1: paddingBox.left,
            lineX2: chartWidth - paddingBox.right,
            lineY1: yScale(component.get('v.thresholdValue')),
            lineY2: yScale(component.get('v.thresholdValue')),
            textAnchor: 'end',
            textX: chartWidth - paddingBox.right,
            textY: yScale(component.get('v.thresholdValue')),
            rotateAngle: 0
        };

        helper.addThreshold(thresholdParams);

        var focus = g.append('g').style('display', 'none');
        focus.append('line').attr('id', 'focusLineX').attr('class', 'sc-lc-focus-line');
        focus.append('line').attr('id', 'focusLineY').attr('class', 'sc-lc-focus-line');

        var circles = g.selectAll('circles').data(data).enter().append('g');

        circles
            .append('circle')
            .attr('cx', function (d) {
                return xScale(d.x);
            })
            .attr('cy', function (d) {
                return yScale(d.y);
            })
            .attr('r', function (d) {
                return sizeScale(d.size);
            })
            .attr('class', 'sc-bc-bubble')
            .style('fill', function (d, i) {
                return d.color ? d.color : color(i);
            })
            .style('stroke', function (d, i) {
                return d.color ? d.color : color(i);
            })
            .style('stroke-width', 2);

        var formatTooltipFirstLine =
            xAxisDataType === 'number'
                ? function (value) {
                      return helper.abbreviateNumber(value);
                  }
                : function (date) {
                      return d3.timeFormat('%b %d')(date);
                  };
        var formatTooltipSecondLine =
            yAxisDataType === 'number'
                ? function (value) {
                      return helper.abbreviateNumber(value);
                  }
                : function (date) {
                      return d3.timeFormat('%b %d')(date);
                  };

        circles.on(
            'mouseover',
            $A.getCallback(function (d) {
                var x = xScale(d.x);
                var y = yScale(d.y);

                focus.style('display', null);

                focus
                    .select('#focusLineX')
                    .attr('x1', x)
                    .attr('y1', yScale(yDomain[0]))
                    .attr('x2', x)
                    .attr('y2', yScale(yDomain[1]));
                focus
                    .select('#focusLineY')
                    .attr('x1', xScale(xDomain[0]))
                    .attr('y1', y)
                    .attr('x2', xScale(xDomain[1]))
                    .attr('y2', y);

                var firstTooltipLine;
                var secondTooltipLine;
                var formatPattern;

                if (xAxisDataType === 'date' || xAxisDataType === 'datetime') {
                    formatPattern =
                        xAxisDataType === 'date'
                            ? 'EEEE MMM dd, yyyy'
                            : 'EEEE MMM dd, yyyy hh:mm A';
                    firstTooltipLine =
                        '<span class="sc-axis-value">' +
                        $A.localizationService.formatDate(d.x, formatPattern) +
                        '</span>';
                } else {
                    firstTooltipLine =
                        '<span class="sc-axis-label">' +
                        component.get('v.xAxisLabel') +
                        ': </span><span class="sc-axis-value">' +
                        helper.abbreviateNumber(d.x) +
                        '</span>';
                }

                if (yAxisDataType === 'date' || yAxisDataType === 'datetime') {
                    formatPattern =
                        yAxisDataType === 'date'
                            ? 'EEEE MMM dd, yyyy'
                            : 'EEEE MMM dd, yyyy hh:mm A';
                    secondTooltipLine =
                        '<br/><span class="sc-axis-value">' +
                        $A.localizationService.formatDate(d.y, formatPattern) +
                        '</span>';
                } else {
                    secondTooltipLine =
                        '<br/><span class="sc-axis-label">' +
                        component.get('v.yAxisLabel') +
                        ': </span><span class="sc-axis-value">' +
                        helper.abbreviateNumber(d.y) +
                        '</span>';
                }

                var tooltipHtml =
                    firstTooltipLine +
                    secondTooltipLine +
                    '<br/><span class="sc-axis-label">' +
                    component.get('v.bubbleSizeLabel') +
                    ': </span><span class="sc-axis-value">' +
                    d.size +
                    '</span>';
                component.set('v.tooltipHtml', tooltipHtml);
            })
        );

        circles.on(
            'mouseout',
            $A.getCallback(function (d) {
                helper.hideTooltip(component);
                focus.style('display', 'none');
            })
        );

        circles.on(
            'mousemove',
            $A.getCallback(function () {
                var mousePos = d3.mouse(component.find('chartContainer').getElement());

                var tooltipOptions = {
                    x: mousePos[0],
                    y: mousePos[1],
                    chartWidth: chartWidth
                };

                helper.showToolTip(component, tooltipOptions);
            })
        );
    },

    totalPassedChart: function (component, helper) {
        component.set('v.displayAxis', false);
        var data = component.get('v.data');
        var divContainer = d3.select(component.find('chart').getElement());
        var width = component.get('v.containerWidth');
        var height = 0.47 * width;
        var maxHeight = 152;
        if (height > maxHeight) height = maxHeight;
        var vPadding = 5;
        var radius = (height - 2 * vPadding) / 2;
        var strokeWidth = 0.135 * radius;

        var total = data.total;
        var passed = data.passed;
        var failed = total - passed;
        var circleLength = radius * 2 * 3.14;
        var percentLength = total !== 0 ? (1 - passed / total) * circleLength : circleLength;

        var numberFontSize = 0.38 * radius;
        var legendFontSIze = 0.22 * radius;
        var xShift = 1.7 * radius;
        var yShift = 0.33 * radius;

        var grayColor = '#D9D9D9';
        var valueColor = '#A34BB7';

        var svg = divContainer
            .append('svg')
            .attr('width', width)
            .attr('height', height)
            .append('g')
            .attr('transform', 'translate(' + width / 2 + ',' + height / 2 + ')');

        var grayCircle = svg
            .append('circle')
            .attr('cx', 0)
            .attr('cy', 0)
            .attr('r', radius)
            .attr('fill', 'none')
            .attr('stroke', grayColor)
            .attr('stroke-width', strokeWidth);

        var valueCircle = svg
            .append('circle')
            .attr('cx', 0)
            .attr('cy', 0)
            .attr('r', radius)
            .attr('fill', 'none')
            .attr('stroke', valueColor)
            .attr('stroke-width', strokeWidth)
            .attr('stroke-dasharray', circleLength)
            .attr('stroke-linecap', 'round')
            .attr('stroke-dashoffset', percentLength)
            .attr('transform', 'rotate(-90)');

        svg.append('text')
            .attr('text-anchor', 'middle')
            .attr('font-size', numberFontSize)
            .attr('x', 0)
            .attr('y', 0)
            .attr('class', 'total-passed-number')
            .text(total);

        svg.append('text')
            .attr('text-anchor', 'middle')
            .attr('font-size', legendFontSIze)
            .attr('x', 0)
            .attr('y', yShift)
            .attr('class', 'total-passed-legend')
            .text('Completions');

        svg.append('text')
            .attr('text-anchor', 'middle')
            .attr('font-size', numberFontSize)
            .attr('x', xShift)
            .attr('y', 0)
            .attr('class', 'total-passed-number')
            .text(passed);

        svg.append('text')
            .attr('text-anchor', 'middle')
            .attr('font-size', legendFontSIze)
            .attr('x', xShift)
            .attr('y', yShift)
            .attr('fill', valueColor)
            .attr('class', 'total-passed-legend')
            .text('Passed');

        svg.append('text')
            .attr('text-anchor', 'middle')
            .attr('font-size', numberFontSize)
            .attr('x', -xShift)
            .attr('y', 0)
            .attr('class', 'total-passed-number')
            .text(failed);

        svg.append('text')
            .attr('text-anchor', 'middle')
            .attr('font-size', legendFontSIze)
            .attr('x', -xShift)
            .attr('y', yShift)
            .attr('class', 'total-passed-legend')
            .text('Failed');
    },

    funnelChart: function (component, helper) {
        try {
            component.set('v.displayAxis', false);
            var dataList = component.get('v.data');
            if (!dataList) return;
            var divContainer = d3.select(component.find('chart').getElement());
            var width = component.get('v.containerWidth');
            var height = 500;
            var funnelWidth = 0.55 * width;
            component.set('v.containerHeight', height + 1);

            var radius = Math.min(width, height) / 2;
            var colors = d3
                .scaleOrdinal()
                .range(['#D8D8D8', '#F5CE00', '#58208a', '#9013FE', '#297DFD', '#00C221']);
            var sectionLineColor = '#D8D8D8';

            var svg = divContainer
                .append('svg')
                .attr('width', width)
                .attr('height', height)
                .append('g');

            var funnel = d3
                .funnel()
                .size(funnelWidth, height, width)
                .value(function (d) {
                    return d.value;
                });

            var line = d3
                .line()
                .x(function (d, i) {
                    return d.x;
                })
                .y(function (d, i) {
                    return d.y;
                });

            var g = svg
                .selectAll('.funnel-group')
                .data(funnel(dataList))
                .enter()
                .append('g')
                .attr('class', 'funnel-group');

            //section lines:
            g.append('path')
                .attr('d', function (d) {
                    return line(d.lineCoordinates);
                })
                .attr('stroke', function (d) {
                    if (d.color) {
                        return d.color;
                    } else {
                        return sectionLineColor;
                    }
                });

            //funnel trapezoids:
            g.append('path')
                .attr('d', function (d) {
                    return line(d.coordinates);
                })
                .attr('fill', function (d) {
                    if (d.color) {
                        return d.color;
                    } else {
                        return colors(d.category);
                    }
                });

            //section legend
            var lineHeight = 18;
            var sectionLegend = g
                .append('g')
                .attr('class', 'fn-section-info')
                .attr('x', function (d) {
                    return d.sectionInfoBlock.x;
                })
                .attr('y', function (d) {
                    return d.sectionInfoBlock.y;
                })
                .attr('width', function (d) {
                    return d.sectionInfoBlock.width;
                })
                .attr('height', function (d) {
                    return d.sectionInfoBlock.height;
                })
                .attr('transform', function (d) {
                    return (
                        'translate(' +
                        (d.sectionInfoBlock.x + 30) +
                        ',' +
                        d.sectionInfoBlock.y +
                        ')'
                    );
                })
                .append('text')
                .text(function (d) {
                    return d.value + ' ' + d.category;
                })
                .attr('dy', lineHeight)
                .attr('class', 'title')

                .each(function (d) {
                    for (var i = 0; i < d.subTotals.length; i++) {
                        var item = d.subTotals[i];
                        d3.select(this.parentNode)
                            .append('text')
                            .text(item.value + ' ' + item.label)
                            .attr('dy', (i + 2) * lineHeight)
                            .attr('class', item.state);
                    }
                });

            /*var sectionInfo = g.append('foreignObject')
                .attr('x', function (d) {
                    return d.sectionInfoBlock.x;
                })
                .attr('y', function (d) {
                    return d.sectionInfoBlock.y;
                })
                .attr('width', function (d) {
                    return d.sectionInfoBlock.width;
                })
                .attr('height', function (d) {
                    return d.sectionInfoBlock.height;
                })
                .append('xhtml:div')
                .attr('class', 'fn-section-info');

            //title
            sectionInfo.append('div')
                .attr('class', 'title')
                .html(function (d) {
                    return  d.value + ' ' + d.category;
                });

            //sub titles
            sectionInfo.append('div')
                .attr('class', 'sub-totals')
                .html(function (d) {
                    var res = '';
                    if(d.subTotals){
                        for(var i = 0; i < d.subTotals.length; i++){
                            var item = d.subTotals[i];
                            res += "<div class='" + item.state + "'>" +item.value + ' ' + item.label + "</div>"
                        }
                        return res;
                    }
                });
             */
        } catch (e) {
            console.log(e);
        }
    },

    pieDonutChart: function (component, helper) {
        component.set('v.displayAxis', false);
        var isDonut = component.get('v.type') === 'donut';

        var dataList = component.get('v.data');
        var total = d3.sum(
            dataList.map(function (d) {
                return d.value;
            })
        );

        var dataListForOutput = dataList;
        if (total === 0) {
            dataListForOutput = [{ segment: 'ziro', value: 1, color: '#ececec', isZiroType: true }];
        }
        var divContainer = d3.select(component.find('chart').getElement());
        var chartWidth = component.get('v.containerWidth');
        var chartHeight = chartWidth * 0.45;
        if (component.get('v.hideLegend')) {
            chartHeight = chartWidth;
        }
        component.set('v.containerHeight', chartHeight + 1);

        var size = chartHeight;
        var radius = size / 2;
        var colors = helper.getColors();

        var svg = divContainer
            .append('svg')
            .attr('width', chartWidth + 1)
            .attr('height', chartHeight + 1);

        var parentGrouping = svg
            .append('g')
            .attr('id', 'parentGroup')
            .attr('transform', 'translate(' + radius + ',' + radius + ')');

        var donutWidth = size * 0.2;
        var innerRadius = radius - donutWidth;
        var innerSquareHalfWidth = Math.sqrt((innerRadius * innerRadius) / 2);
        var arc = d3
            .arc()
            .innerRadius(isDonut ? innerRadius : 0)
            .outerRadius(radius);

        var pie = d3
            .pie()
            .value(function (d) {
                return d.value;
            })
            .sort(null);

        var path = parentGrouping
            .selectAll('g')
            .data(pie(dataListForOutput))
            .enter()
            .append('path')
            .attr('class', 'sc-section')
            .attr('d', arc)
            .attr('fill', function (d, i) {
                if (d.data.segment) {
                    if (d.data.color) {
                        return d.data.color;
                    } else {
                        return colors(d.data.segment);
                    }
                } else {
                    return;
                }
            });

        var arcLabelFontSize = size * 0.08;
        var arcLabel = parentGrouping
            .selectAll('text')
            .data(pie(dataListForOutput))
            .enter()
            .append('text')
            .attr('transform', function (d) {
                return 'translate(' + arc.centroid(d) + ')';
            })
            .attr('text-anchor', 'middle')
            .attr('font-size', arcLabelFontSize)
            .attr('y', arcLabelFontSize * 0.4)
            .attr('fill', '#ffffff')
            .attr('class', 'sc-arc-label')
            .text(function (d) {
                if (!d.data.isZiroType && d.data.value !== 0) {
                    var percent = Math.floor((d.data.value / total) * 100);
                    return percent + '%';
                } else {
                    return '';
                }
            });

        path.on(
            'mouseover',
            $A.getCallback(function (dataPoint) {
                var percent = Math.round((1000 * dataPoint.data.value) / total) / 10;

                var tooltipHtml =
                    '<span class="sc-axis-label">' +
                    component.get('v.segmentLabel') +
                    ': </span><span class="sc-axis-value">' +
                    dataPoint.data.segment +
                    '</span>' +
                    '<span class="sc-axis-label">' +
                    component.get('v.valueLabel') +
                    ': </span><span class="sc-axis-value">' +
                    helper.abbreviateNumber(dataPoint.data.value) +
                    '</span>' +
                    '<span class="sc-pdc-section-percent">' +
                    percent +
                    '% of ' +
                    helper.abbreviateNumber(total) +
                    '</span>';

                component.set('v.tooltipHtml', tooltipHtml);
                parentGrouping.selectAll('.sc-section').classed('sc-not-not-hovered', true);
                d3.select(this).classed('sc-not-not-hovered', false);
            })
        );

        path.on(
            'mouseout',
            $A.getCallback(function (dataPoint) {
                helper.hideTooltip(component);
                parentGrouping.selectAll('.sc-section').classed('sc-not-not-hovered', false);
            })
        );

        path.on(
            'mousemove',
            $A.getCallback(function (dataPoint) {
                if (dataPoint.data.isZiroType) return;
                var mousePos = d3.mouse(component.find('chartContainer').getElement());

                var tooltipOptions = {
                    x: mousePos[0],
                    y: mousePos[1],
                    chartWidth: chartWidth
                };

                helper.showToolTip(component, tooltipOptions);
            })
        );

        var legendCircleRadius = size * 0.05;
        var legendSpacing = size * 0.05;
        var legendGrouping = parentGrouping.append('g');
        var legend = legendGrouping
            .selectAll('.sc-pdc-legend')
            .data(pie(dataList))
            .enter()
            .append('g')
            .attr('class', 'sc-pdc-legend')
            .attr('transform', function (d, i) {
                var legendRectHeight = 2 * legendCircleRadius;
                var legendRectOffset = i * (legendRectHeight + legendSpacing);
                return 'translate(0,' + legendRectOffset + ')';
            });

        var getCircleColor = function (d) {
            if (d.data.segment) {
                if (d.data.color) {
                    return d.data.color;
                } else {
                    return colors(d.data.segment);
                }
            } else {
                return;
            }
        };

        var circleParams = {
            parent: legend,
            circleX: -11,
            circleY: -legendCircleRadius / 2,
            radius: legendCircleRadius,
            cssClass: '',
            fill: getCircleColor,
            stroke: '',
            strokeWidth: 0
        };

        helper.addCircle(circleParams);

        var getLabel = function (d) {
            var label =
                d.data.segment + ' (' + d.data.value + ' ' + component.get('v.valueLabel') + ')';
            /*if(label) {
                return label.length > 15 ? label.slice(0, 12) + '...' : label
            } else {
                return;
            }*/
            return label;
        };

        var labelFontSize = size * 0.08;
        var legendLabelParams = {
            parent: legend,
            cssClass: '',
            rotation: 0,
            x: legendCircleRadius - 6,
            y: 0,
            fontSize: labelFontSize,
            textAnchor: '',
            label: getLabel
        };

        helper.addLabel(legendLabelParams);

        var legendBoundingBox = legendGrouping._groups[0][0].getBBox();
        var legendPaddingSpace = radius * 0.45;
        var legendX = radius + legendPaddingSpace;
        var legendCenterY = legendCircleRadius - legendBoundingBox.height / 2;
        legendGrouping.attr(
            'transform',
            'translate(' + legendX + ', ' + -(radius - 2 * legendCircleRadius) + ')'
        );

        legend.on(
            'mouseover',
            $A.getCallback(function (dataPoint) {
                var percent = Math.round((1000 * dataPoint.data.value) / total) / 10;

                var tooltipHtml =
                    '<span class="sc-axis-label">' +
                    component.get('v.segmentLabel') +
                    ': </span><span class="sc-axis-value">' +
                    dataPoint.data.segment +
                    '</span>' +
                    '<span class="sc-axis-label">' +
                    component.get('v.valueLabel') +
                    ': </span><span class="sc-axis-value">' +
                    helper.abbreviateNumber(dataPoint.data.value) +
                    '</span>' +
                    '<span class="sc-pdc-section-percent">' +
                    percent +
                    '% of ' +
                    helper.abbreviateNumber(total) +
                    '</span>';

                component.set('v.tooltipHtml', tooltipHtml);
            })
        );

        legend.on(
            'mouseout',
            $A.getCallback(function () {
                helper.hideTooltip(component);
            })
        );

        legend.on(
            'mousemove',
            $A.getCallback(function () {
                var mousePos = d3.mouse(component.find('chartContainer').getElement());

                var tooltipOptions = {
                    x: mousePos[0],
                    y: mousePos[1],
                    chartWidth: chartWidth
                };

                helper.showToolTip(component, tooltipOptions);
            })
        );

        if (isDonut && false) {
            var totalFontSize = size * 0.085;
            var totalLineHeight = size * 0.12;
            var totalDonutLabel = parentGrouping
                .append('foreignObject')
                .attr('x', -innerSquareHalfWidth)
                .attr('y', -innerSquareHalfWidth)
                .attr('width', innerSquareHalfWidth * 2)
                .attr('height', innerSquareHalfWidth * 2)
                .attr('font-size', totalFontSize)
                .attr('line-height', totalFontSize)
                .append('xhtml:div')
                .attr('class', 'ch-donut-total')
                .append('div')
                .attr('style', 'line-height: ' + (totalFontSize + 6) + 'px')
                .html(total + '<br/>' + component.get('v.totalLabel'));
        }
    },

    gaugeChart: function (component, helper) {
        component.set('v.displayAxis', false);
        var segmentData = component.get('v.data');
        var gaugeValue = segmentData.gaugeValue;

        var minValue = Number(segmentData.minValue);
        var lowSegmentMax = Number(segmentData.lowSegmentMax);
        var medSegmentMax = Number(segmentData.medSegmentMax);
        var highSegmentMax = Number(segmentData.highSegmentMax);

        var segmentRanges = [minValue, lowSegmentMax, medSegmentMax, highSegmentMax];

        minValue = minValue;
        var maxValue = highSegmentMax;

        var size = component.get('v.containerWidth') * 0.9;
        var minAngle = -90;
        var maxAngle = 90;
        var range = maxAngle - minAngle;
        var arcWidth = size * 0.04;
        var arcInset = size * 0.05;
        var radius = size / 2;
        var pointerHeadLength = Math.round(radius * 0.65);
        var pointerWidth = size * 0.013;
        var pointerTailLength = size * 0.013;
        var arcColors = ['#c23934', '#ffb75d', '#00716b'];
        var divContainer = d3.select(component.find('chart').getElement());
        var chartWidth = component.get('v.containerWidth');
        var chartHeight = helper.getHeight(chartWidth);

        var svg = divContainer
            .append('svg')
            .attr('class', 'gaugeChartSVG')
            .attr('width', chartWidth)
            .attr('height', chartHeight);

        var parentGrouping = svg.append('g');

        function degToRad(deg) {
            return (deg * Math.PI) / 180;
        }

        function centerTranslation() {
            return 'translate(' + radius + ',' + radius + ')';
        }

        // a linear scale that maps domain values to a percent from minValue to maxValue
        var scale = d3.scaleLinear().range([-90, 90]).domain([minValue, maxValue]);

        var sections = {
            0: component.get('v.lowLabel'),
            1: component.get('v.medLabel'),
            2: component.get('v.highLabel')
        };

        var numberOfSections = Object.keys(sections).length;

        function percentToRange(percent, min, max) {
            var ret = (max - min) * percent + min;
            return Math.round(ret * 100) / 100;
        }

        var minMaxValuesDifference = maxValue - minValue;

        var tickData = [
            (lowSegmentMax - minValue) / minMaxValuesDifference,
            (medSegmentMax - lowSegmentMax) / minMaxValuesDifference,
            (highSegmentMax - medSegmentMax) / minMaxValuesDifference
        ];
        var previousSegmentStartAngle;
        var arc = d3
            .arc()
            .innerRadius(radius - arcWidth - arcInset)
            .outerRadius(radius - arcInset)
            .startAngle(function (d, i) {
                if (i === 0) {
                    return degToRad(minAngle);
                } else if (i === 1) {
                    previousSegmentStartAngle = tickData[i - 1] * range;
                    return degToRad(minAngle + previousSegmentStartAngle);
                } else if (i === 2) {
                    previousSegmentStartAngle = (tickData[i - 2] + tickData[i - 1]) * range;
                    return degToRad(minAngle + previousSegmentStartAngle);
                }
            })
            .endAngle(function (d, i) {
                if (i === 0) {
                    var ratio = d * (i + 1);
                    return degToRad(minAngle + ratio * range);
                } else if (i === 1) {
                    var previousSegmentEndAngle = (tickData[i - 1] + tickData[i]) * range;
                    return degToRad(minAngle + previousSegmentEndAngle);
                } else if (i === 2) {
                    return degToRad(maxAngle);
                }
            });

        var arcs = parentGrouping
            .append('g')
            .attr('class', 'arc')
            .attr('transform', centerTranslation);

        var path = arcs
            .selectAll('path')
            .data(tickData)
            .enter()
            .append('path')
            .attr('class', 'sc-section')
            .attr('fill', function (d, i) {
                return arcColors[i];
            })
            .attr('d', arc);

        var labelInset = size * 0.02;
        var labels = parentGrouping
            .append('g')
            .attr('class', 'label')
            .attr('transform', centerTranslation);

        labels
            .selectAll('text')
            .data(segmentRanges)
            .enter()
            .append('text')
            .attr('text-anchor', 'middle')
            .attr('font-size', size * 0.04)
            .attr('transform', function (d) {
                return 'rotate(' + scale(d) + ') translate(0,' + (labelInset - radius) + ')';
            })
            .text(function (d) {
                return helper.abbreviateNumber(d);
            });

        var whiteTicks = parentGrouping
            .append('g')
            .attr('class', 'whiteTicks')
            .attr('transform', centerTranslation);

        var whiteTicksData = [lowSegmentMax, medSegmentMax];

        function whiteTicksTransformFunc(d) {
            return 'rotate(' + (scale(d) - 0.5) + ') translate(0,' + (-radius + arcInset) + ')';
        }

        var whiteTickParams = {
            ticks: whiteTicks,
            shape: 'rect',
            data: whiteTicksData,
            chartWidth: arcWidth * 0.2,
            chartHeight: arcWidth * 1.15,
            fill: 'white',
            transformFunc: whiteTicksTransformFunc
        };

        helper.addTicks(whiteTickParams);

        var innerArcWidth = size * 0.08;
        var innerArcInset = size * 0.095;
        var innerArc = d3
            .arc()
            .innerRadius(radius - innerArcWidth - innerArcInset)
            .outerRadius(radius - innerArcInset)
            .startAngle(degToRad(minAngle))
            .endAngle(degToRad(maxAngle));

        var innerArcs = parentGrouping
            .append('g')
            .attr('class', 'arc777')
            .attr('transform', centerTranslation);

        innerArcs
            .selectAll('path')
            .data(tickData)
            .enter()
            .append('path')
            .attr('fill', '#F4F6F9')
            .attr('d', innerArc);

        var smallTicks = parentGrouping
            .append('g')
            .attr('class', 'smallTicks')
            .attr('transform', centerTranslation);

        var numOfSmallTicks = 12;
        var partition = (maxValue - minValue) / numOfSmallTicks;

        var smallTicksData = [];
        for (var idx = 0; idx <= numOfSmallTicks; idx++) {
            smallTicksData.push(minValue + partition * idx);
        }

        function smallTicksTransformFunc(d) {
            return 'rotate(' + (scale(d) - 0.5) + ') translate(0,' + -radius * 0.81 + ')';
        }
        var smallTickParams = {
            ticks: smallTicks,
            shape: 'rect',
            data: smallTicksData,
            chartWidth: innerArcWidth * 0.078,
            chartHeight: innerArcWidth / 2,
            fill: 'lightgray',
            transformFunc: smallTicksTransformFunc
        };

        helper.addTicks(smallTickParams);

        var lineData = [
            [pointerWidth / 2, 0],
            [0, -pointerHeadLength],
            [-(pointerWidth / 2), 0],
            [0, pointerTailLength],
            [pointerWidth / 2, 0]
        ];

        var outerCircleParams = {
            parent: parentGrouping,
            circleX: radius,
            circleY: radius,
            radius: size * 0.04,
            cssClass: '',
            fill: '#F4F6F9',
            stroke: '#E2E7EF',
            strokeWidth: size * 0.0055
        };

        var innerCircleParams = {
            parent: parentGrouping,
            circleX: radius,
            circleY: radius,
            radius: size * 0.02,
            cssClass: '',
            fill: 'black',
            stroke: '',
            strokeWidth: 0
        };

        helper.addCircle(outerCircleParams);
        helper.addCircle(innerCircleParams);

        var pointerLine = d3.line().curve(d3.curveMonotoneX);
        var pg = parentGrouping
            .append('g')
            .data([lineData])
            .attr('class', 'pointer')
            .attr('transform', centerTranslation);

        var pointer = pg
            .append('path')
            .attr('d', pointerLine)
            .attr('transform', 'rotate(' + minAngle + ')');

        path.on(
            'mouseover',
            $A.getCallback(function (dataPoint, index) {
                if (!$A.util.isEmpty(sections[index])) {
                    var tooltipHtml = '<span class="axisValue">' + sections[index] + '</span>';
                    component.set('v.tooltipHtml', tooltipHtml);
                }
            })
        );

        path.on(
            'mouseout',
            $A.getCallback(function () {
                helper.hideTooltip(component);
            })
        );

        path.on(
            'mousemove',
            $A.getCallback(function (dataPoint, index) {
                if (!$A.util.isEmpty(sections[index])) {
                    var mousePos = d3.mouse(component.find('chartContainer').getElement());

                    var tooltipOptions = {
                        x: mousePos[0],
                        y: mousePos[1]
                    };

                    helper.showToolTip(component, tooltipOptions);
                }
            })
        );

        var textColor = '';
        var labelRange1 = '';
        var labelRange2 = '';

        if (gaugeValue >= minValue && gaugeValue < lowSegmentMax) {
            labelRange1 = minValue;
            labelRange2 = lowSegmentMax;
            textColor = arcColors[0];
        } else if (gaugeValue >= lowSegmentMax && gaugeValue < medSegmentMax) {
            labelRange1 = lowSegmentMax;
            labelRange2 = medSegmentMax;
            textColor = arcColors[1];
        } else {
            labelRange1 = medSegmentMax;
            labelRange2 = highSegmentMax;
            textColor = arcColors[2];
        }

        var rangeText =
            '(' +
            helper.abbreviateNumber(labelRange1) +
            ' to ' +
            helper.abbreviateNumber(labelRange2) +
            ')';

        var gagueTotalLabelParams = {
            parent: parentGrouping,
            cssClass: 'label valueLabel',
            rotation: 0,
            x: radius,
            y: radius + size * 0.13,
            fontSize: size * 0.085,
            textAnchor: 'middle',
            label: gaugeValue,
            fill: textColor
        };

        helper.addLabel(gagueTotalLabelParams);

        var segmentRangeLabelParams = {
            parent: parentGrouping,
            cssClass: 'label valueLabel',
            rotation: 0,
            x: radius,
            y: radius + size * 0.175,
            fontSize: size * 0.035,
            textAnchor: 'middle',
            label: rangeText,
            fill: textColor
        };

        helper.addLabel(segmentRangeLabelParams);

        // if gaugeValue is not between minValue and highSegmentMax, draw the chart but throw an error and don't move the needle
        if (helper.handleGaugeValueErrors(helper, gaugeValue, minValue, highSegmentMax)) return;

        setTimeout(
            $A.getCallback(function () {
                moveTheNeedle(gaugeValue);
            }),
            500
        );

        function moveTheNeedle(value, newConfiguration) {
            function tween(d, c, a) {
                return d3.interpolateString(
                    'rotate(' + minAngle + ', 0, 0)',
                    'rotate(' + scale(value) + ', 0, 0)'
                );
            }

            var transitionMs = 4000;
            pointer
                .transition()
                .duration(transitionMs)
                .ease(d3.easeElasticOut)
                .attrTween('transform', tween);
        }

        var parentGroupingWidth = parentGrouping._groups[0][0].getBBox().width;
        var parentGroupingHeight = parentGrouping._groups[0][0].getBBox().height;
        var centeredX = (chartWidth - parentGroupingWidth) / 2;
        var centeredY = (chartHeight - parentGroupingHeight) / 2;

        parentGrouping.attr('transform', 'translate(' + centeredX + ', ' + centeredY + ')');
    },
    handleSegmentRangesErrors: function (component, event, helper, segmentData) {
        var shouldStopExecution = false;

        function sortNumbers(a, b) {
            return a > b ? 1 : a < b ? -1 : 0;
        }

        var gaugeValue = segmentData.gaugeValue;
        var minValue = Number(segmentData.minValue);
        var lowSegmentMax = Number(segmentData.lowSegmentMax);
        var medSegmentMax = Number(segmentData.medSegmentMax);
        var highSegmentMax = Number(segmentData.highSegmentMax);
        var segmentRanges = [minValue, lowSegmentMax, medSegmentMax, highSegmentMax];
        var sortedSegmentRanges = segmentRanges.map(function (segmentRange) {
            return segmentRange;
        });
        sortedSegmentRanges.sort(sortNumbers);

        segmentRanges.forEach(function (segment, index) {
            if (segment !== sortedSegmentRanges[index]) {
                var error = helper.throwError('Please double check your segment ranges');

                shouldStopExecution = true;
            }
        });

        return shouldStopExecution;
    },
    handleGaugeValueErrors: function (helper, gaugeValue, minValue, highSegmentMax) {
        if (gaugeValue < minValue || gaugeValue > highSegmentMax) {
            var error = helper.throwError('gaugeValue must be between minValue and highSegmentMax');

            return true;
        }
    },
    getWidth: function (basedOnWidth) {
        return basedOnWidth * 0.75;
    },
    getHeight: function (basedOnWidth) {
        return basedOnWidth * 0.66;
    },
    setyAxisLabelMaxHeight: function (component, chartHeight) {
        component.set('v.yAxisLabelMaxHeight', chartHeight * 0.7);
    },
    shouldRotateXAxisLabels: function (parent, chartWidth) {
        var xAxisLabels = parent.selectAll('.x text');
        var numberOfXAxisTicks = xAxisLabels.size();
        var widestXAxisLabel = 0;
        xAxisLabels.each(function () {
            widestXAxisLabel = Math.max(widestXAxisLabel, this.getBBox().width);
        });

        var shouldRotateXAxisLabels = (widestXAxisLabel + 8) * numberOfXAxisTicks > chartWidth;
        if (shouldRotateXAxisLabels) {
            parent
                .selectAll('.x text')
                .style('text-anchor', 'end')
                .attr('dy', '-.55em')
                .attr('transform', 'rotate(-90) translate(-10,0)');
        }
    },
    addCircle: function (circleParams) {
        return circleParams.parent
            .append('circle')
            .attr('cx', circleParams.circleX)
            .attr('cy', circleParams.circleY)
            .attr('r', circleParams.radius)
            .attr('class', circleParams.cssClass)
            .style('fill', circleParams.fill)
            .style('stroke', circleParams.stroke)
            .style('stroke-width', circleParams.strokeWidth);
    },
    addTicks: function (tickParams) {
        tickParams.ticks
            .selectAll(tickParams.shape)
            .data(tickParams.data)
            .enter()
            .append('rect')
            .attr('width', tickParams.chartWidth)
            .attr('height', tickParams.chartHeight)
            .style('fill', tickParams.fill)
            .attr('transform', tickParams.transformFunc);
    },
    addLabel: function (labelParams) {
        var label = labelParams.parent
            .append('text')
            .attr('class', labelParams.cssClass)
            .attr('text-anchor', labelParams.textAnchor)
            .attr('transform', 'rotate(' + labelParams.rotation + ')')
            .attr('x', labelParams.x)
            .attr('y', labelParams.y)
            .attr('font-size', labelParams.fontSize)
            .attr('dy', '0em')
            .text(labelParams.label);

        if (labelParams.fill !== undefined) label.attr('fill', labelParams.fill);
        return label;
    },
    addThreshold: function (thresholdParams) {
        if ($A.util.isEmpty(thresholdParams.thresholdValue)) {
            return;
        }

        var parent = thresholdParams.parent;
        var fontSize = this.determineFontSize(thresholdParams.chartWidth);
        var thresholdLabel = thresholdParams.thresholdLabel;
        var thresholdValue = this.abbreviateNumber(thresholdParams.thresholdValue);
        var thresholdTextPadding = 3;
        var formattedThresholdLabel = '';

        if ($A.util.isEmpty(thresholdLabel)) {
            formattedThresholdLabel = thresholdValue;
        } else {
            formattedThresholdLabel = thresholdLabel + ' (' + thresholdValue + ')';
        }

        parent
            .append('line')
            .attr('x1', thresholdParams.lineX1)
            .attr('y1', thresholdParams.lineY1)
            .attr('x2', thresholdParams.lineX2)
            .attr('y2', thresholdParams.lineY2)
            .attr('class', 'sc-threshold-line');

        var thresholdBackground = parent.append('rect').attr('class', 'sc-threshold-background');

        var thresholdTriangle = parent.append('polygon').attr('class', 'sc-threshold-triangle');

        var thresholdText = parent
            .append('text')
            .attr('font-size', fontSize)
            .text(formattedThresholdLabel)
            .attr('dy', '-0.33em')
            .attr('text-anchor', thresholdParams.textAnchor)
            .attr('class', 'sc-threshold-text');

        var thresholdTextBox = thresholdText._groups[0][0].getBBox();
        var thresholdBackgroundWidth =
            thresholdTextBox.width > 0 ? thresholdTextBox.width + thresholdTextPadding * 2 : 0;
        var thresholdBackgroundHeight =
            thresholdTextBox.height > 0 ? thresholdTextBox.height + thresholdTextPadding * 2 : 0;

        thresholdBackground
            .attr('width', thresholdBackgroundWidth)
            .attr('height', thresholdBackgroundHeight);

        if (thresholdParams.rotateAngle === 0) {
            thresholdText
                .attr(
                    'transform',
                    'translate(' +
                        (thresholdParams.textX - thresholdTextPadding) +
                        ', ' +
                        (thresholdParams.textY +
                            thresholdBackgroundHeight / 2 -
                            thresholdTextPadding) +
                        ') rotate(' +
                        thresholdParams.rotateAngle +
                        ')'
                )
                .attr('dx', '-0.12em');
            thresholdBackground.attr(
                'transform',
                'translate(' +
                    (thresholdParams.textX - thresholdBackgroundWidth) +
                    ', ' +
                    (thresholdParams.textY - thresholdBackgroundHeight / 2) +
                    ') rotate(' +
                    thresholdParams.rotateAngle +
                    ')'
            );
            thresholdTriangle
                .attr(
                    'points',
                    thresholdBackgroundHeight / 2 +
                        ',' +
                        thresholdBackgroundHeight / 2 +
                        ' ' +
                        thresholdBackgroundHeight +
                        ',' +
                        thresholdBackgroundHeight +
                        ' ' +
                        thresholdBackgroundHeight +
                        ',0'
                )
                .attr(
                    'transform',
                    'translate(' +
                        (thresholdParams.textX -
                            thresholdBackgroundWidth -
                            thresholdBackgroundHeight) +
                        ', ' +
                        (thresholdParams.textY - thresholdBackgroundHeight / 2) +
                        ') rotate(' +
                        thresholdParams.rotateAngle +
                        ')'
                );
        } else if (thresholdParams.rotateAngle === 90) {
            thresholdText
                .attr(
                    'transform',
                    'translate(' +
                        (thresholdParams.textX -
                            thresholdBackgroundHeight / 2 +
                            thresholdTextPadding) +
                        ', ' +
                        (thresholdParams.textY + thresholdTextPadding) +
                        ') rotate(' +
                        thresholdParams.rotateAngle +
                        ')'
                )
                .attr('dx', '0.12em');
            thresholdBackground.attr(
                'transform',
                'translate(' +
                    (thresholdParams.textX + thresholdBackgroundHeight / 2) +
                    ', ' +
                    thresholdParams.textY +
                    ') rotate(' +
                    thresholdParams.rotateAngle +
                    ')'
            );
            thresholdTriangle
                .attr(
                    'points',
                    thresholdBackgroundHeight / 2 +
                        ',' +
                        thresholdBackgroundHeight / 2 +
                        ' ' +
                        thresholdBackgroundHeight +
                        ',0 0,0'
                )
                .attr(
                    'transform',
                    'translate(' +
                        (thresholdParams.textX - thresholdBackgroundHeight / 2) +
                        ', ' +
                        (thresholdParams.textY + thresholdBackgroundWidth) +
                        ')'
                );
        }
    },
    addLeftAxis: function (scale, tickSizeOuter, tickFormat) {
        return d3.axisLeft().scale(scale).tickSizeOuter(tickSizeOuter).tickFormat(tickFormat);
    },
    addBottomAxis: function (scale, tickSizeOuter, tickFormat) {
        return d3.axisBottom().scale(scale).tickSizeOuter(tickSizeOuter).tickFormat(tickFormat);
    },
    abbreviateNumber: function (amount) {
        var absAmount = Math.abs(Number(amount));
        var amountNumber = Number(amount);
        var shortenedNumber = amountNumber;
        var abbreviation = '';
        var trillion = Math.pow(10, 12);
        var billion = Math.pow(10, 9);
        var million = Math.pow(10, 6);
        var thousand = Math.pow(10, 3);

        if (absAmount / trillion >= 1) {
            shortenedNumber = amountNumber / trillion;
            abbreviation = 'T';
        } else if (absAmount / billion >= 1) {
            shortenedNumber = amountNumber / billion;
            abbreviation = 'B';
        } else if (absAmount / million >= 1) {
            shortenedNumber = amountNumber / million;
            abbreviation = 'M';
        } else if (absAmount / thousand >= 1) {
            shortenedNumber = amountNumber / thousand;
            abbreviation = 'K';
        }

        return parseFloat(shortenedNumber.toFixed(1)) + abbreviation;
    },
    throwError: function (errorMessage) {
        function ErrorMessage() {
            var temp = Error().apply(this, arguments);
            temp.name = this.name = 'Error Message';
            this.message = temp.message;
            if (Object.defineProperty) {
                /*this.stack = */
                Object.defineProperty(this, 'stack', {
                    get: function () {
                        return temp.stack;
                    },
                    configurable: true
                });
            } else {
                this.stack = temp.stack;
            }
        }

        //inherit prototype using ECMAScript 5 (IE 9+)
        ErrorMessage.prototype = Object.create(Error.prototype, {
            constructor: {
                value: ErrorMessage,
                writable: true,
                configurable: true
            }
        });

        return new ErrorMessage(errorMessage);
    },
    hideTooltip: function (component) {
        component.set('v.tooltipOpacity', 0);
        component.set('v.tooltipDisplay', 'none');
    },
    showToolTip: function (component, tooltipOptions) {
        var tooltipElement = component.find('tooltipContainer').getElement();
        var tooltipElementCopy = component.find('tooltipContainerCopy').getElement();
        var tooltipOffSet = 10;

        var tooltipXPos = tooltipOptions.x + tooltipOffSet;
        var tooltipYPos = tooltipOptions.y + tooltipOffSet;

        /*if ((tooltipElementCopy.clientWidth + tooltipXPos) > tooltipOptions.chartWidth) {
            tooltipXPos -= (tooltipElementCopy.clientWidth + (tooltipOffSet * 2));

            if (tooltipXPos < 0) {
                tooltipXPos = tooltipOptions.x + tooltipOffSet;
            }
        }*/

        component.set('v.tooltipDisplay', 'block');
        component.set('v.tooltipXPos', tooltipXPos);
        component.set('v.tooltipYPos', tooltipYPos);
        component.set('v.tooltipOpacity', 1);
    },
    determineFontSize: function (chartWidth) {
        var fontSize = '.8125rem';

        if (chartWidth < 767) {
            fontSize = '.625rem';
        } else if (chartWidth < 1023) {
            fontSize = '.75rem';
        }

        return fontSize;
    },
    getPaddingBox: function (chartWidth) {
        return {
            top: chartWidth * 0.02,
            left: chartWidth * 0.1,
            bottom: chartWidth * 0.1,
            right: chartWidth * 0.02
        };
    },
    getColors: function () {
        return d3
            .scaleOrdinal()
            .range([
                '#00a4e3',
                '#16325c',
                '#76ded9',
                '#08a69e',
                '#e2cd81',
                '#e49e24',
                '#c03a38',
                '#fdb665',
                '#63b07f',
                '#0d716a',
                '#95caf6',
                '#97e2b3'
            ]);
    }
});
