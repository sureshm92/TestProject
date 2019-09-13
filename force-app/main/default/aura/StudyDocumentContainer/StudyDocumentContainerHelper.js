/**
 * Created by Slav on 30.08.2019.
 */

({
    /******************************************************************************************************************/
    /******** castWrappers() ******************************************************************************************/
    /* this function casts List<ResourceService.ResourceWrapper> into List<List<ResourceService.ResourceWrapper>>     */
    /* INPUT: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10] ===> OUTPUT: [[1, 2, 3, 4, 5, 6, 7, 8, 9], [10]]                        */
    /******************************************************************************************************************/
    castWrappers: function (component, wrappers) {
        var pageSize = component.get("v.pageSizeForIconsView");

        var pageList = [];
        var page = [];

        for (var index = 0; index < wrappers.length; index++) {
            if (index % pageSize == 0) {
                if (page && page.length > 0) {
                    pageList.push(page);
                    page = [];
                }
            }
            page.push(wrappers[index]);
        }

        if (page.length > 0) {
            pageList.push(page);
        }

        component.set("v.pageListResourceWrappers", pageList);
        component.set("v.totalPages", pageList.length);
        component.set("v.currentPage", 1);
        component.set("v.currentPageResourceWrappers", component.get("v.pageListResourceWrappers")[component.get("v.currentPage") - 1]);

        this.renderAll(component);
    },


    getDocumentData: function (component, resourceId) {
        var apexMethod = component.get("c.getDocumentData");
        apexMethod.setParams({resourceId: resourceId});

        apexMethod.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var value = response.getReturnValue()
                console.log('SUCCESS: ==========> len = ' + value.length);
                console.log('SUCCESS: ==========> ' + value[0]);
                console.log('SUCCESS: ==========> ' + value[1]);
            } else if (response.getState() === "ERROR") {
                var errors = response.getError();
                console.log('ERROR: ==========> ' + errors[0].message);
            }
        })
        $A.enqueueAction(apexMethod);
    },


    /******************************************************************************************************************/
    /******** renderAll() *********************************************************************************************/
    /* this function fetches PDF files specified in the ResourceWrappers and renders them in the component canvas     */
    /******************************************************************************************************************/
    renderAll: function (component) {
        this.hideSpinner(component);
        return;

        this.showSpinner(component);

        var wrappers = component.get("v.currentPageResourceWrappers");

        if (wrappers == null) {
            component.set("v.errorMessage", 'No documents found to display');
            this.hideSpinner(component);
            return;
        }

        var containers = component.find("container");
        var canvases = component.find("canvas");

        if (containers == null) return;             // no containers found
        if (typeof containers.length == "undefined") {
            // -------------------------------------------------------------------------------------
            // here we have a single container in the component, so we have to convert it into Array
            // -------------------------------------------------------------------------------------
            let container = containers;
            containers = [];
            containers.push(container);

            let canvas = canvases;
            canvases = [];
            canvases.push(canvas);
        }

        var startIndex = canvases.length - wrappers.length;
        var remaining = wrappers.length;
        var helper = this;

        pdfjsLib.disableWorker = true;

        for (let index = startIndex; index < (wrappers.length + startIndex); index++) {
            let wrapper = wrappers[index - startIndex];

            let resource = wrapper.resource;
            let docLink = "/s/resources?resourceType=" + resource.RecordType.DeveloperName + "&id=" + communityService.getUrlParameter('id') + "&resId=" + resource.Id + "&ret=" + communityService.createRetString();
            console.log('======== doc link = ' + docLink);
//communityService.navigateToPage(docLink);

            let apexMethod = component.get("c.getDocumentData");
            apexMethod.setParams({resourceId: resource.Id});

            apexMethod.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    let value = response.getReturnValue()
                    console.log('SUCCESS: ==========> len = ' + value.length);
                    console.log('SUCCESS: ==========> ' + value[0]);
//    console.log('SUCCESS: ==========> '+value[1]);

                    let byteCharacters = atob(value[1]);
                    let byteNumbers = new Array(byteCharacters.length);
                    console.log('AAAAA ----------> 1111');
                    for (let i = 0; i < byteCharacters.length; i++) {
                        byteNumbers[i] = byteCharacters.charCodeAt(i);
                    }
                    console.log('AAAAA ----------> 2222');
//                    let ieEDGE = navigator.userAgent.match(/Edge/g);
//                    let ie = navigator.userAgent.match(/.NET/g);
//                    let oldIE = navigator.userAgent.match(/MSIE/g);
                    let bytes = new Uint8Array(byteNumbers); //use this if data is raw bytes else directly pass resData
                    console.log('AAAAA ----------> 3333');
                    let blob = new window.Blob([bytes], {type: 'application/pdf'});
//                    if (ie || oldIE || ieEDGE) {
//                        window.navigator.msSaveBlob(blob, fileName);
//                    } else {
                    console.log('AAAAA ----------> 4444');
                    let fileURL = URL.createObjectURL(blob);
//                    }

                    console.log('before get ----------> fileURL =  ' + fileURL);

//                        let canvas = canvases[index].getElement();
//                        canvas.src = fileURL;


                } else if (response.getState() === "ERROR") {
                    var errors = response.getError();
                    console.log('ERROR: ==========> ' + errors[0].message);
                }
            })
            $A.enqueueAction(apexMethod);


//          pdfjsLib.getDocument(wrapper.resource.article_external_link__c).promise.then(function(pdf) {
//            pdfjsLib.getDocument(docLink).promise.then(function(pdf) {
//                pdf.getPage(1).then(function(page) {
//                    let canvas = canvases[index].getElement();
//                    let context = canvas.getContext('2d');
//                    let originalViewport = page.getViewport({ scale: 1 });
//                    let scale = canvas.width / originalViewport.width;
//                    let scaledViewport = page.getViewport({ scale: scale });
//
//                    canvases[index].width = scaledViewport.width;
//                    canvases[index].height = scaledViewport.height;
//
//                    page.render({
//                        canvasContext: context,
//                        viewport: scaledViewport
//                    });
//                });
//                if (--remaining <= 0) {
//                    helper.hideSpinner(component);
//                }
//            }).catch(function(error) {
//                console.log('===> [' + error + ']');
//                let canvas = canvases[index].getElement();
//                let context = canvas.getContext('2d');
//                context.font = "30px Arial";
//                context.fillStyle = "lightgrey";
//                context.textAlign = "center";
//                context.fillText(error.message, canvas.width/2, canvas.height/2);
//                if (--remaining <= 0) {
//                    helper.hideSpinner(component);
//                }
//            });
        }
    },

    /******************************************************************************************************************/
    /******** showSpinner() *******************************************************************************************/
    /******************************************************************************************************************/
    showSpinner: function (component) {
        let spinner = component.find('spinner');
        if (spinner) {
            spinner.show();
        }
    },

    /******************************************************************************************************************/
    /******** hideSpinner() *******************************************************************************************/
    /******************************************************************************************************************/
    hideSpinner: function (component) {
        let spinner = component.find('spinner');
        if (spinner) {
            spinner.hide();
        }
    }

});