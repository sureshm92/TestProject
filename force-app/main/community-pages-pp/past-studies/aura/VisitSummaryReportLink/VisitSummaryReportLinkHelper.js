/**
 * Created by Leonid Bartenev
 */
({
    generateReport: function (component) {
        const helper = this;
        let reportData = component.get('v.reportData');
        if (reportData.notAvailableMessage) {
            var template = reportData.notAvailableMessage + ' {0}';
            var accUrl = 'account-settings?langloc';
            var urlLabel = $A.get('$Label.c.PP_IRB_Button_Review');

            var toastEvent = $A.get('e.force:showToast');
            toastEvent.setParams({
                type: 'warning',
                mode: 'sticky',
                message: 'This is a required message',
                messageTemplate: template,
                messageTemplateData: [
                    {
                        url: accUrl,
                        label: urlLabel
                    }
                ]
            });
            toastEvent.fire();
            return;
        }
        if (!reportData) return;
        let ie = navigator.userAgent.match(/.NET/g);
        let oldIE = navigator.userAgent.match(/MSIE/g);
        let ieEDGE = navigator.userAgent.match(/Edge/g);
        if (ie || oldIE) {
            helper.getLogoFromIE(component, reportData);
        } else {
            helper.getLogo(component, reportData, ieEDGE);
        }
    },

    getLogo: function (component, reportData, isSave) {
        const helper = this;
        const url = window.location.hostname;
        let filepath = '/' + reportData.communityTemplate + '.png';
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
                                helper.fillData(component, reportData, iqviaLogo, isSave);
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

    getLogoFromIE: function (component, reportData, isSave) {
        const helper = this;
        helper
            .enqueue(component, 'c.getLogoFromStatic', {
                communityname: reportData.communityTemplate
            })
            .then(
                function (iqviaLogo) {
                    helper.fillData(component, reportData, iqviaLogo, isSave);
                },
                function (err) {
                    if (err && err[0].message) {
                        component.set('v.errorMessage', err[0].message);
                    }
                    console.log('error:', err[0].message);
                }
            );
    },

    fillData: function (component, reportData, iqviaLogo, isSave) {
        let helper = this;
        helper.uploadFontForUtf8();
        let languageCode = component.get('v.language');
        var RTL = component.get('v.isRTL');
        var doc = new jsPDF('l', 'pt', 'A4', true);
        let textFooter = $A.get('$Label.c.Report_Visits_Result_Text_Footer');
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
        let splitTextFooter = doc.splitTextToSize(textFooter, 650);
        helper.generateFirstPage(reportData, doc, helper);
        doc.addPage();
        doc.setFontSize(16);
        doc.setTextColor('#000096');
        doc.setFontType('bold');
        if (RTL) {
            doc.text(reportData.participantFullName, 740, 120, {
                align: 'right'
            });
            doc.text(
                $A.get('$Label.c.Report_Enrollment_Date') + ' ' + reportData.enrollmentDate,
                740,
                140,
                { align: 'right' }
            );

            if (!$A.util.isUndefinedOrNull(reportData.participantStatus)) {
                doc.text(
                    $A.get('$Label.c.Report_Participant_Status') +
                        ': ' +
                        reportData.participantStatus,
                    740,
                    160,
                    { align: 'right' }
                );
                doc.text(
                    $A.get('$Label.c.Report_Study_Site') + ': ' + reportData.studySiteName,
                    740,
                    180,
                    { align: 'right' }
                );
            } else {
                doc.text(
                    $A.get('$Label.c.Report_Study_Site') + ': ' + reportData.studySiteName,
                    740,
                    160,
                    { align: 'right' }
                );
            }
        } else {
            doc.text(reportData.participantFullName, 80, 120);
            doc.text(
                $A.get('$Label.c.Report_Enrollment_Date') + ' ' + reportData.enrollmentDate,
                80,
                140
            );

            if (!$A.util.isUndefinedOrNull(reportData.participantStatus)) {
                doc.text(
                    $A.get('$Label.c.Report_Participant_Status') +
                        ': ' +
                        reportData.participantStatus,
                    80,
                    160
                );
                doc.text(
                    $A.get('$Label.c.Report_Study_Site') + ': ' + reportData.studySiteName,
                    80,
                    180
                );
            } else {
                doc.text(
                    $A.get('$Label.c.Report_Study_Site') + ': ' + reportData.studySiteName,
                    80,
                    160
                );
            }
        }
        doc.setFontType('normal');
        numberPageForTable = helper.generateTable(reportData, doc, RTL, languageCode);
        for (let i = 1; i <= doc.internal.getNumberOfPages(); i++) {
            doc.setPage(i);
            helper.addBorder(reportData, doc, iqviaLogo, splitTextFooter, i === 1, RTL);
        }
        if (isSave) {
            window.navigator.msSaveBlob(
                doc.output('blob'),
                $A.get('$Label.c.Report_Document_Name') + '.pdf'
            );
        } else {
            if (component.get('v.initialized') && component.get('v.isMobileApp')) {
                let urlPDF2 = doc.output('datauristring');
                var res = urlPDF2.split(',');
                communityService.navigateToPage('mobile-pdf-viewer?pdfData=' + res[1]);
                return;
            }
            let urlPDF = doc.output('bloburi');
            let urlViewer = $A.get('$Resource.pdfjs_dist') + '/web/viewer.html';
            //window.open(urlViewer + '?file=' + urlPDF + '&fileName=' + encodeURIComponent($A.get('$Label.c.Report_Document_Name')));
            let urlEvent = $A.get('e.force:navigateToURL');
            let absoluteURL = window.location.origin;
            urlEvent.setParams({
                url:
                    absoluteURL +
                    urlViewer +
                    '?file=' +
                    urlPDF +
                    '&fileName=' +
                    encodeURIComponent($A.get('$Label.c.Report_Document_Name'))
            });
            urlEvent.fire();
        }
    },

    generateTable: function (reportData, doc, RTL, languageCode) {
        let helper = this;
        let numberPageForTable = 0;
        let heightY = 160;
        reportData.dataTables.forEach(function (tableResult, ind) {
            doc.setFontType('bold');
            doc.setFontSize(16);
            doc.setTextColor('#545454');
            heightY = helper.validationEndPage(doc, heightY + 50, 100);
            if (RTL) {
                doc.text(tableResult.tableName, 750, heightY, {
                    align: 'right'
                });
            } else {
                doc.text(tableResult.tableName, 90, heightY);
            }
            heightY += doc.internal.getLineHeight();
            tableResult.labsDescription.forEach(function (lab) {
                doc.setFontType('bold');
                doc.setFontSize(11);
                doc.setTextColor('#000000');
                heightY = helper.validationEndPage(doc, heightY + 10, 75);
                if (RTL) {
                    doc.text(lab.nameLabs, 750, heightY, { align: 'right' });
                } else {
                    doc.text(lab.nameLabs, 90, heightY);
                }
                doc.setFontType('normal');
                doc.setFontSize(11);
                doc.setTextColor('#000000');
                let splitTextResult = doc.splitTextToSize(lab.descriptionLab, 720);
                splitTextResult.forEach(function (el, ind) {
                    heightY = helper.validationEndPage(doc, heightY + doc.internal.getLineHeight());
                    if (RTL) {
                        doc.text(el, 750, heightY, { align: 'right' });
                    } else {
                        doc.text(el, 90, heightY);
                    }
                });
                heightY = helper.validationEndPage(doc, heightY + doc.internal.getLineHeight());
            });
            if (RTL) {
				if(languageCode.includes('ar') || languageCode === 'ur'){
					doc.autoTable({
                    theme: 'plain',
                    html: '#tbl' + ind,
                    styles: {
                        cellPadding: 2,
                        halign: 'center',
                        valign: 'middle',
                        lineColor: 0,
                        lineWidth: 1,
                        font: 'Amiri',
                        fontStyle: 'normal',
                        minCellWidth: 63
                    },
                    columnStyles: {
                        0: {
                            cellWidth: 60,
                            cellPadding: 0
                        }
                    },
                    head: {
						font: 'Amiri',
                        fontStyle: 'normal',
                        fontSize: 8,
                        halign: 'center',
                        valign: 'middle'
                    },
                    startY: heightY + 30,
                    margin: {
                        right: 50,
                        left: 10,
                        top: 60,
                        bottom: 60
                    },
                    useCss: true
                });
				}else if (languageCode === 'fa' || languageCode === 'iw') {
					doc.autoTable({
                    theme: 'plain',
                    html: '#tbl' + ind,
                    styles: {
                        cellPadding: 2,
                        halign: 'center',
                        valign: 'middle',
                        lineColor: 0,
                        lineWidth: 1,
                        font: 'Heebo',
                        fontStyle: 'normal',
                        minCellWidth: 63
                    },
                    columnStyles: {
                        0: {
                            cellWidth: 60,
                            cellPadding: 0
                        }
                    },
                    head: {
						font: 'Heebo',
                        fontStyle: 'normal',
                        fontSize: 8,
                        halign: 'center',
                        valign: 'middle'
                    },
                    startY: heightY + 30,
                    margin: {
                        right: 50,
                        left: 10,
                        top: 60,
                        bottom: 60
                    },
                    useCss: true
                });
				}else {
				doc.autoTable({
                    theme: 'plain',
                    html: '#tbl' + ind,
                    styles: {
                        cellPadding: 2,
                        halign: 'center',
                        valign: 'middle',
                        lineColor: 0,
                        lineWidth: 1,
                        font: 'Roboto',
                        fontStyle: 'normal',
                        minCellWidth: 63
                    },
                    columnStyles: {
                        0: {
                            cellWidth: 60,
                            cellPadding: 0
                        }
                    },
                    head: {
						font: 'Roboto',
                        fontStyle: 'normal',
                        fontSize: 8,
                        halign: 'center',
                        valign: 'middle'
                    },
                    startY: heightY + 30,
                    margin: {
                        right: 50,
                        left: 10,
                        top: 60,
                        bottom: 60
                    },
                    useCss: true
                });
				}
            } else {
                doc.autoTable({
                    theme: 'plain',
                    html: '#tbl' + ind,
                    styles: {
                        cellPadding: 2,
                        halign: 'center',
                        valign: 'middle',
                        lineColor: 0,
                        lineWidth: 1,
                        font: 'Roboto-Regular',
                        fontStyle: 'normal',
                        minCellWidth: 63
                    },
                    columnStyles: {
                        0: {
                            cellWidth: 60,
                            cellPadding: 0
                        }
                    },
                    head: {
                        fontStyle: 'normal',
                        fontSize: 8,
                        halign: 'center',
                        valign: 'middle'
                    },
                    startY: heightY + 30,
                    margin: {
                        right: 10,
                        left: 50,
                        top: 60,
                        bottom: 60
                    },
                    useCss: true
                });
            }
            heightY = doc.autoTable.previous.finalY;
        });
        return numberPageForTable;
    },

    addBorder: function (reportData, doc, logo, splitTextFooter, isFirstPage, RTL) {
        const helper = this;
        if (!isFirstPage) {
            doc.setFontSize(10);
            doc.setTextColor('#6e6e6e');
            if (reportData.studyCodeName) {
                if (RTL)
                    doc.text(reportData.studyCodeName, 180, 12, {
                        align: 'right'
                    });
                else doc.text(reportData.studyCodeName, 600, 12);
            }
            if (RTL)
                doc.text(reportData.participantLastName, 180, 24, {
                    align: 'right'
                });
            else doc.text(reportData.participantLastName, 600, 24);
        }
        doc.setDrawColor(216, 216, 216);
        doc.setLineWidth(8);
        if (RTL) {
            doc.line(1, 35, 300, 35);
            doc.line(193, 35, 800, 35);
            doc.line(1, 550, 800, 550);
            doc.line(800, 30.8, 800, 554);
        } else {
            doc.line(35, 35, 35, 550);
            doc.line(30.8, 35, 97, 35);
            doc.line(193, 35, 841, 35);
            doc.line(30.8, 550, 841, 550);
        }
        //TO-DO: Add right border and align table
        //doc.line(808, 35, 808, 550);
        if (logo) {
            if (RTL) {
                doc.addImage(logo, 'PNG', 595, 20, 100, 25);
            } else {
                doc.addImage(logo, 'PNG', 95, 20, 100, 25);
            }
        }
        splitTextFooter.forEach(function (el, ind) {
            doc.setFontSize(8);
            doc.setTextColor('#6e6e6e');
            helper.centeredText(el, 565 + ind * doc.internal.getLineHeight(), doc);
        });
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

    generateFirstPage: function (reportData, doc) {
        const helper = this;
        let heightY = 40;
        if (reportData.profilePicture) {
            doc.addImage(reportData.profilePicture, 'JPEG', 262, 100, 360, 150);
            heightY += 210;
        } else {
            doc.setFontSize(18);
            doc.setTextColor('#000000');
            heightY += 150;
            if (reportData.studyCodeName) {
                let splitStudyCodeName = doc.splitTextToSize(reportData.studyCodeName, 500);
                splitStudyCodeName.forEach(function (el, ind) {
                    helper.centeredText(el, heightY + ind * doc.internal.getLineHeight(), doc);
                });
                heightY += doc.internal.getLineHeight() * splitStudyCodeName.length;
            } else {
                heightY += 100;
            }
        }
        doc.setFontSize(16);
        doc.setTextColor('#000000');
        heightY += 50;
        if (reportData.studyTitle) {
            let splitStudyTitle = doc.splitTextToSize(reportData.studyTitle, 500);
            splitStudyTitle.forEach(function (el, ind) {
                helper.centeredText(el, heightY + ind * doc.internal.getLineHeight(), doc);
            });
            heightY += doc.internal.getLineHeight() * splitStudyTitle.length;
        } else {
            heightY += 100;
        }
        helper.centeredText($A.get('$Label.c.Report_My_Study_Data'), 50 + heightY, doc);
    },

    uploadReportData: function (component, callback) {
        if (component.get('v.reportData')) {
            callback();
            return;
        }
        const peId = component.get('v.peId');
        component.find('spinner').show();
        communityService.executeAction(
            component,
            'getReportDataWrappers',
            {
                peId: peId
            },
            function (reportData) {
                component.find('spinner').hide();
                component.set('v.reportData', reportData);
                var RTL = component.get('v.isRTL');
                if (RTL) {
                    for (i = 0; i < reportData.dataTables.length; i++) {
                        reportData.dataTables[i].tHead = reportData.dataTables[i].tHead.reverse();
                        reportData.dataTables[i].visitResultsWrapper[0] = reportData.dataTables[
                            i
                        ].visitResultsWrapper[0].reverse();
                    }
                }

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
                this.addFont($A.get('$Resource.jsPDF_Fonts') + '/NotoSansCJKjp-Bold.ttf', 'NotoSans-JP', 'bold');
                this.addFont($A.get('$Resource.jsPDF_Fonts') + '/NotoSansCJKjp-Regular.ttf', 'NotoSans-JP', 'normal');
            };
            jsPDFAPI.events.push(['addFonts', callAddFont]);
        })(jsPDF.API);
    }
});