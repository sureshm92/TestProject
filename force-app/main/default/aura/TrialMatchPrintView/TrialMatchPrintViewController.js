/**
 * Created by Sravani
 */
({
    doInit: function (component, event, helper) {
            let peId = communityService.getUrlParameter('id');
            let intialized;
            communityService.executeAction(component, 'getMatchCTPs', {
                urlid: peId
            }, function (data) {
                component.set('v.trialmatchCTPs', data.trialmatchctps);
                component.set('v.initialized', true);
                intialized=true;
            });
            
            setTimeout(
                $A.getCallback(function () {
                    kendo.drawing
                    .drawDOM("#trialmatchcontent", 
                    { 
                        paperSize: "A4",
                        margin: { top: "1cm", bottom: "1cm", left:"0.6cm" },
                        scale: 0.8,
                        height: 500
                    })
                        .then(function(group){
                            if(intialized){
                                kendo.drawing.pdf.saveAs(group, "TrialMatchDataPrint.pdf");
                            }
                    });
                }), 2000
            );
            window.onfocus = function () { setTimeout(function () { window.close(); }, 1000); }
    }
});