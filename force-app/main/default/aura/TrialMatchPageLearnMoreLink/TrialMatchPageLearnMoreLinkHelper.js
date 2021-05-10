({
    generateLearnMorePDF: function (component) {
        const helper = this;
        let ctpRecord = component.get('v.ctpRecord');
        if (!ctpRecord) return;
        let ie = navigator.userAgent.match(/.NET/g);
        let oldIE = navigator.userAgent.match(/MSIE/g);
        let ieEDGE = navigator.userAgent.match(/Edge/g);
        if (ie || oldIE) {
            helper.getLogoFromIE(component, ctpRecord);
        } else {
            helper.getLogo(component, ctpRecord, ieEDGE);
        }
    },
    getLogo: function (component, ctpRecord, isSave) {
        const helper = this;
        const url = window.location.hostname;
        let filepath = '/' + ctpRecord.CommunityTemplate__c + '.png';
        const resourceRelPath = $A.get('$Resource.ReportBrandingLogos') + filepath;
        const resourceUrl = 'https://'.concat(url).concat(resourceRelPath);
        window
            .fetch(resourceUrl)
            .then(
                $A.getCallback(function (response) {
                    console.log(response);
                    if (!response.ok) {
                        throw new Error('HTTP error, status = '.concat(response.status));
                    }
                    response.blob().then(
                        $A.getCallback(function (data) {
                            let reader = new FileReader();
                            reader.readAsDataURL(data);
                            reader.onloadend = function () {
                                let iqviaLogo = reader.result;
                                helper.fillData(component, ctpRecord, iqviaLogo, isSave);
                            };
                        })
                    );
                })
            )
            .catch(
                $A.getCallback(function (error) {
                    console.error('Fetch Error :-S', error);
                })
            );
    },

    getLogoFromIE: function (component, ctpRecord, isSave) {
        const helper = this;
        helper
            .enqueue(component, 'c.getLogoFromStatic', {
                communityname: ctpRecord.CommunityTemplate__c
            })
            .then(
                function (iqviaLogo) {
                    helper.fillData(component, ctpRecord, iqviaLogo, isSave);
                },
                function (err) {
                    if (err && err[0].message) {
                        component.set('v.errorMessage', err[0].message);
                    }
                    console.log('error:', err[0].message);
                }
            );
    },

    fillData: function (component, ctpRecord, iqviaLogo, isSave) {
        let helper = this;
        helper.uploadFontForUtf8();
        let languageCode = component.get('v.language');
        var doc = new jsPDF('l', 'pt', 'A4', true);
        //let numberPageForTable = 0;
        if (languageCode.includes('ar') || languageCode === 'ur') {
            doc.setFont('Amiri', 'normal'); //Arabic
        } else if (languageCode === 'fa' || languageCode === 'iw') {
            doc.setFont('Heebo', 'normal'); //Hebrew
        } else {
            //Check https://fonts.google.com/specimen/Roboto#glyphs for supported characters
            doc.setFont('Roboto', 'normal');
        }
        doc.setFontSize(8);
        doc.setTextColor('#6e6e6e');
        helper.generateFirstPage(ctpRecord, doc, helper);
        doc.setFontSize(16);
        doc.setTextColor('#000096');
        doc.setFontType('bold');
        doc.setFontType('normal');
        var RTL = component.get('v.isRTL');
        for (let i = 1; i <= doc.internal.getNumberOfPages(); i++) {
            doc.setPage(i);
            helper.addBorder(ctpRecord, doc, iqviaLogo, i === 1, RTL);
        }
        if (isSave) {
            window.navigator.msSaveBlob(
                doc.output('blob'),
                $A.get('$Label.c.Learn_More_Report_Document_Name') + '.pdf'
            );
        } else {
            let urlPDF = doc.output('bloburi');
            let urlViewer = $A.get('$Resource.pdfjs_dist') + '/web/viewer.html';
            window.open(
                urlViewer +
                    '?file=' +
                    urlPDF +
                    '&fileName=' +
                    encodeURIComponent($A.get('$Label.c.Learn_More_Report_Document_Name'))
            );
        }
    },

    addBorder: function (reportData, doc, logo, isFirstPage, RTL) {
        const helper = this;
        doc.setDrawColor(216, 216, 216);
        doc.setLineWidth(8);
        if (RTL) {
            doc.line(1, 35, 300, 35);
            doc.line(193, 35, 790, 35);
            doc.line(1, 550, 790, 550);
            doc.line(790, 30.8, 790, 554);
        } else {
            doc.line(35, 35, 35, 550);
            doc.line(30.8, 35, 97, 35);
            doc.line(193, 35, 841, 35);
            doc.line(30.8, 550, 841, 550);
        }
        if (logo) {
            if (RTL) {
                doc.addImage(logo, 'PNG', 595, 20, 100, 25);
            } else {
                doc.addImage(logo, 'PNG', 95, 20, 100, 25);
            }
        }
    },

    centeredText: function (text, y, doc) {
        var textWidth =
            (doc.getStringUnitWidth(text) * doc.internal.getFontSize()) / doc.internal.scaleFactor;
        var textOffset = (doc.internal.pageSize.width - textWidth) / 2;
        doc.setFillColor(25, 25, 25);
        doc.text(textOffset + 12, y, text);
    },
    validationEndPage: function (doc, heightY, margiBottom) {
        margiBottom = typeof margiBottom !== 'undefined' ? margiBottom : 55;
        if (heightY > doc.internal.pageSize.height - margiBottom) {
            doc.addPage();
            heightY = 80;
        }
        return heightY;
    },
    generateFirstPage: function (ctpRecord, doc) {
        const helper = this;
        let heightY = 40;
        doc.setFontType('bold');
        doc.setFontSize(20);
        doc.setTextColor('#3333ff');
        heightY += 50;
        if (ctpRecord.Study_Code_Name__c) {
            let splitStudyCodeName = doc.splitTextToSize(ctpRecord.Study_Code_Name__c, 500);
            splitStudyCodeName.forEach(function (el, ind) {
                helper.centeredText(el, heightY + ind * doc.internal.getLineHeight(), doc);
            });
            heightY += doc.internal.getLineHeight() * splitStudyCodeName.length;
        } else {
            heightY += 100;
        }
        doc.setFontType('normal');
        //doc.setFont('Roboto-Regular', 'normal');
        doc.setFontSize(12);
        doc.setTextColor('#000000');
        heightY += 35;
        if (ctpRecord.Study_Content__c) {
            let splitStudyTitle = doc.splitTextToSize(ctpRecord.Study_Content__c, 600);
            splitStudyTitle.forEach(function (el, ind) {
                heightY = helper.validationEndPage(doc, heightY + 15, 75);
                helper.centeredText(el, heightY, doc);
            });
        } else {
            heightY += 100;
        }
    },
    uploadReportData: function (component, callback) {
        if (component.get('v.ctpRecord')) {
            callback();
            return;
        }
        const ctpId = component.get('v.ctpId');
        component.find('spinner').show();
        communityService.executeAction(
            component,
            'fetchCTPLearnMoreDetails',
            {
                ctpId: ctpId
            },
            function (ctpRecord) {
                component.find('spinner').hide();
                component.set('v.ctpRecord', ctpRecord);
                callback();
            }
        );
    },
    // add generated (using https://rawgit.com/MrRio/jsPDF/master/fontconverter/fontconverter.html) tff fonts into pdf
    uploadFontForUtf8: function () {
        (function (jsPDFAPI) {
            let callAddFont = function () {
                this.addFont(
                    $A.get('$Resource.jsPDF_Fonts') + '/Roboto-Regular.ttf',
                    'Roboto',
                    'normal'
                );
                this.addFont(
                    $A.get('$Resource.jsPDF_Fonts') + '/Roboto-Bold.ttf',
                    'Roboto',
                    'bold'
                );
                this.addFont(
                    $A.get('$Resource.jsPDF_Fonts') + '/Amiri-Regular.ttf',
                    'Amiri',
                    'normal'
                );
                this.addFont($A.get('$Resource.jsPDF_Fonts') + '/Amiri-Bold.ttf', 'Amiri', 'bold');
                this.addFont(
                    $A.get('$Resource.jsPDF_Fonts') + '/Heebo-Regular.ttf',
                    'Heebo',
                    'normal'
                );
                this.addFont($A.get('$Resource.jsPDF_Fonts') + '/Heebo-Bold.ttf', 'Heebo', 'bold');
            };
            jsPDFAPI.events.push(['addFonts', callAddFont]);
        })(jsPDF.API);
    }
});
