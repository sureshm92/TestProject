/**
 * Created by Sravani
 */
({
    doInit: function (component, event, helper) {
            let peId = communityService.getUrlParameter('id');
            let intialized;
            let pageurl;
            let callouttime;
            let ie = navigator.userAgent.match(/.NET/g);
            let oldIE = navigator.userAgent.match(/MSIE/g);
            if (ie || oldIE ) {
                callouttime = 2000;
            } else {
                callouttime = 1000;
            }
            communityService.executeAction(component, 'getMatchCTPs', {
                urlid: peId
            }, function (data) {
                pageurl = window.location.href;
                component.set('v.trialmatchCTPs', data.trialmatchctps);
                component.set('v.initialized', true);
                intialized=true;
            });
            
            setTimeout(
                $A.getCallback(function () {
                    kendo.drawing
                    .drawDOM("#trialmatchcontent")
                        .then(function(group) {
                            // Render the result as a PDF file
                            return kendo.drawing.exportPDF(group, {
                                paperSize: "A4",
                                margin: { left: "1cm", top: "1cm", right: "1cm", bottom: "1cm" }
                            });
                        })
                        .done(function(data) {
                            // Save the PDF file
                            if(intialized && !isduplicate){
                                kendo.saveAs({
                                    dataURI: data,
                                    fileName: "TrialMatchesData.pdf",
                                    proxyURL: pageurl
                                });
                        } 
                        })
                }), callouttime
            );
            window.onfocus = function () { setTimeout(function () { window.close(); }, 1000); }
    }
});