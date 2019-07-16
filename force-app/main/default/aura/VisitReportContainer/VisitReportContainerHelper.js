/**
 * Created by Yehor Dobrovolskyi
 */
({

    onGenerateData: function (component, helper, reportData) {
        helper.onGenerateReport(component, helper);
    },

    onGenerateReport: function (component, helper) {
        let testLargeText = 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, \n' +
            'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc,  \n' +
            'as nec odio et ante tin';
        var doc = new jsPDF('p', 'pt', 'A4', true);
        let reportData = component.get('v.reportData');
        const url = new URL(window.location.href);
        const resourceRelPath = $A.get('$Resource.PH_Default_Image') + '/IQVIA.png';
        const resourceUrl = `${url.origin}${resourceRelPath}`;
        window.fetch(resourceUrl)
            .then($A.getCallback((response) => {
                console.log(response);
                if (!response.ok) {
                    throw new Error(`HTTP error, status = ${response.status}`);
                }
                response.blob()
                    .then($A.getCallback((data) => {
                        let reader = new FileReader();
                        reader.readAsDataURL(data);
                        reader.onloadend = function () {
                            let iqviaLogo = reader.result;
                            let heightY = 40;
                            // helper.addBorder(reportData, doc, iqviaLogo, true);

                            //                                                         Generate first Page
                            helper.generateFirstPage(reportData, doc, helper);
                            // doc.text(reportData.studyCodeName, 20, 350);

                            //                                                       Generate page with Data
                            doc.addPage();
                            heightY = 40;
                            // helper.addBorder(reportData, doc, iqviaLogo);
                            doc.setFontSize(16);
                            doc.setTextColor('#000096');
                            doc.setFontType('bold');
                            doc.text(reportData.participantFullName, 80, 120);
                            doc.text(reportData.enrollmentDate, 80, 140);
                            doc.text(reportData.studySiteName, 80, 160);
                            doc.setFontType('normal');
                            heightY = 160;

                            reportData.dataTables.forEach(function (tableResult, ind) {
                                doc.setFontType('normal');
                                doc.setFontSize(16);
                                doc.setTextColor('#757575');
                                heightY = heightY + 50;

                                heightY = helper.validationEndPage(doc, heightY);
                                helper.centeredText(tableResult.tableName, heightY, doc);
                                heightY = doc.internal.getLineHeight() + heightY;

                                doc.setFontSize(11);
                                doc.setTextColor('#000000');
                                let splitTextResult = doc.splitTextToSize(tableResult.textResult, 500);
                                // let splitTextResult = doc.splitTextToSize(testLargeText, 490);
                                heightY = heightY + 30;
                                heightY = helper.validationEndPage(doc, heightY);
                                splitTextResult.forEach(function (el, ind) {
                                    heightY = heightY + doc.internal.getLineHeight();
                                    heightY = helper.validationEndPage(doc, heightY);
                                    doc.text(el, 80, heightY, {
                                        renderingMode: 'fillThenStroke'
                                    });
                                });
                                heightY = heightY + doc.internal.getLineHeight();
                                // doc.text(splitTextResult, 80, heightY);
                                // heightY = heightY + doc.internal.getLineHeight() * splitTextResult.length;
                                heightY = helper.validationEndPage(doc, heightY);

                                doc.autoTable({
                                    html: '#tbl' + ind,
                                    styles: {cellPadding: 0.5, fontSize: 10},
                                    startY: heightY + 30,
                                    margin: {
                                        right: 20,
                                        left: 60,
                                        top: 60,
                                        bottom: 60
                                    },
                                    useCss: true,
                                });
                                heightY = doc.autoTable.previous.finalY
                            });

                            for (let i = 1; i <= doc.internal.getNumberOfPages(); i++) {
                                doc.setPage(i);
                                helper.addBorder(reportData, doc, iqviaLogo, i === 1);
                            }

                            doc.save(component.get('v.documentName') + '.pdf');
                            //todo uncomment
                            // reportData = {};
                            // component.set('v.reportData', reportData);
                        };
                    }));
            }))
            .catch($A.getCallback((error) => {
                console.error('Fetch Error :-S', error);
            }));
    },

    addBorder: function (reportData, doc, logo, isFirstPage) {
        let textFooter = 'This data is being provided as part of your participation in a clinical research study. It is for research purposes only. Values are only available for vitals recorded for the visit date displayed. If you have questions or concerns about this data, please contact the Principal Investigator at your study center.';

        if (!isFirstPage) {
            doc.setFontSize(10);
            doc.setTextColor('#6e6e6e');
            doc.text(reportData.studyCodeName, 400, 12);
            doc.text(reportData.participantLastName, 400, 24);
        }
        doc.setDrawColor(0, 0, 100);
        doc.setLineWidth(8);
        doc.line(35, 35, 35, 795);
        doc.line(30.8, 35, 97, 35);
        doc.line(193, 35, 595, 35);
        doc.line(30.8, 795, 595, 795);
        doc.addImage(logo, 'PNG', 100, 12, 90, 35);
        doc.setFontSize(8);
        doc.setTextColor('#6e6e6e');
        let textOption = {
            align: 'center',
            maxWidth: '300'
        };
        let splitTitle = doc.splitTextToSize(textFooter, 420);
        let helperT = this;
        splitTitle.forEach(function (el, ind) {
            helperT.centeredText(el, (812 + ind * 9), doc);
        });
    },

    centeredText: function (text, y, doc) {
        var textWidth = doc.getStringUnitWidth(text) * doc.internal.getFontSize() / doc.internal.scaleFactor;
        var textOffset = (doc.internal.pageSize.width - textWidth) / 2;
        doc.setFillColor(25, 25, 25);
        doc.text(textOffset + 12, y, text);
    },

    validationEndPage: function (doc, heightY) {
        if (heightY > doc.internal.pageSize.height - 60) {
            doc.addPage();
            heightY = 80;
        }
        return heightY;
    },

    generateFirstPage: function (reportData, doc, helper) {
        let heightY = 40;
        if (reportData.profilePicture) {
            doc.addImage(reportData.profilePicture, 'JPEG', 130, 150, 360, 150);
        } else {
            doc.setFontSize(18);
            doc.setTextColor('#000000');
            let splitStudyCodeName = doc.splitTextToSize(reportData.studyCodeName, 500);
            splitStudyCodeName.forEach(function (el, ind) {
                helper.centeredText(el, (150 + heightY + ind * doc.internal.getLineHeight()), doc);
            });
            heightY = doc.internal.getLineHeight() * splitStudyCodeName.length;

        }
        doc.setFontSize(16);
        doc.setTextColor('#000000');
        let splitStudyTitle = doc.splitTextToSize(reportData.studyTitle, 500);
        splitStudyTitle.forEach(function (el, ind) {
            helper.centeredText(el, (350 + heightY + ind * doc.internal.getLineHeight()), doc);
        });
        heightY = doc.internal.getLineHeight() * splitStudyTitle.length;
        helper.centeredText('Report_My_Study_Data', 500 + heightY, doc);
    }
});