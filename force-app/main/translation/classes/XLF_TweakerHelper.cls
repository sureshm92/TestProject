/**
 * Created by Slav on 23.10.2019.
 */

public class XLF_TweakerHelper {
    @TestVisible private List<String> whitePatterns;
    @TestVisible private List<String> blackPatterns;

    /**
     * constructor
     */
    public XLF_TweakerHelper() {
        whitePatterns = new List<String>();
        blackPatterns = new List<String>();
        for (XLF_White_List__mdt whiteList : [
            SELECT Pattern__c
            FROM XLF_White_List__mdt
            WHERE Active__c = TRUE
        ]) {
            whitePatterns.add(whiteList.Pattern__c);
        }
        for (XLF_Black_List__mdt blackList : [
            SELECT Pattern__c
            FROM XLF_Black_List__mdt
            WHERE Active__c = TRUE
        ]) {
            blackPatterns.add(blackList.Pattern__c);
        }
    }

    /**
     * tweakData()
     *
     * @param data
     *
     * @return
     */
    public Blob tweakData(Blob data) {
        Dom.Document doc = new Dom.Document();
        doc.load(data.toString());
        Dom.XmlNode rootNode = doc.getRootElement();

        XmlStreamWriter newDoc = new XmlStreamWriter();
        newDoc.writeStartDocument('UTF-8', '1.0');
        newDoc.writeCharacters('\n');
        newDoc.writeStartElement(null, 'xliff', null);
        newDoc.writeAttribute(null, null, 'version', rootNode.getAttribute('version', null));

        //--------------------------------------------------------------//
        // parse document body and remove unwanted elements             //
        //--------------------------------------------------------------//
        for (Dom.XmlNode fileElement : rootNode.getChildElements()) {
            if (fileElement.getName() != 'file')
                continue;
            newDoc.writeCharacters('\n    ');
            newDoc.writeStartElement(null, 'file', null);
            newDoc.writeAttribute(
                null,
                null,
                'original',
                fileElement.getAttribute('original', null)
            );
            newDoc.writeAttribute(
                null,
                null,
                'source-language',
                fileElement.getAttribute('source-language', null)
            );
            newDoc.writeAttribute(
                null,
                null,
                'target-language',
                fileElement.getAttribute('target-language', null)
            );
            newDoc.writeAttribute(
                null,
                null,
                'datatype',
                fileElement.getAttribute('datatype', null)
            );

            for (Dom.XmlNode bodyElement : fileElement.getChildElements()) {
                if (bodyElement.getName() != 'body')
                    continue;
                newDoc.writeCharacters('\n        ');
                newDoc.writeStartElement(null, 'body', null);

                for (Dom.XmlNode transElement : bodyElement.getChildElements()) {
                    if (transElement.getName() != 'trans-unit')
                        continue;
                    String id = transElement.getAttribute('id', null);

                    // -----------------------------------------------------------------------------------
                    // in this code block we check current element for matches against WhiteList patterns
                    // -----------------------------------------------------------------------------------
                    Boolean whiteMatchFound = false;
                    for (String whitePattern : whitePatterns) {
                        Boolean checkPartialMatch = false;
                        if (whitePattern.endsWith('*')) {
                            checkPartialMatch = true;
                            whitePattern = whitePattern.removeEnd('*');
                        }

                        if (checkPartialMatch) {
                            if (id.startsWithIgnoreCase(whitePattern)) {
                                whiteMatchFound = true;
                            }
                        } else {
                            if (id.equalsIgnoreCase(whitePattern)) {
                                whiteMatchFound = true;
                            }
                        }

                        if (whiteMatchFound)
                            break;
                    }

                    // ------------------------------------------------------------------
                    // if file element doesn't have any matches in the WhiteList patterns
                    // then skip it and go to next element
                    // ------------------------------------------------------------------
                    if (!whiteMatchFound) {
                        continue;
                    }

                    // ----------------------------------------------------------------------------------
                    // in this code block we check current element for matches against BlackList patterns
                    // ----------------------------------------------------------------------------------
                    Boolean blackMatchFound = false;
                    for (String blackPattern : blackPatterns) {
                        Boolean checkPartialMatch = false;
                        if (blackPattern.endsWith('*')) {
                            checkPartialMatch = true;
                            blackPattern = blackPattern.removeEnd('*');
                        }

                        if (checkPartialMatch) {
                            if (id.startsWithIgnoreCase(blackPattern)) {
                                blackMatchFound = true;
                            }
                        } else {
                            if (id.equalsIgnoreCase(blackPattern)) {
                                blackMatchFound = true;
                            }
                        }

                        if (blackMatchFound)
                            break;
                    }

                    // -----------------------------------------------------
                    // if file element matches any pattern in the BlackList
                    // then skip it and go to next element
                    // -----------------------------------------------------
                    if (blackMatchFound) {
                        continue;
                    }

                    newDoc.writeCharacters('\n            ');
                    newDoc.writeStartElement(null, 'trans-unit', null);
                    newDoc.writeAttribute(null, null, 'id', id);
                    newDoc.writeAttribute(
                        null,
                        null,
                        'maxwidth',
                        transElement.getAttribute('maxwidth', null)
                    );
                    newDoc.writeAttribute(
                        null,
                        null,
                        'size-unit',
                        transElement.getAttribute('size-unit', null)
                    );

                    Dom.XmlNode sourceElement = transElement.getChildElement('source', null);
                    Dom.XmlNode targetElement = transElement.getChildElement('target', null);

                    newDoc.writeCharacters('\n                ');
                    newDoc.writeStartElement(null, 'source', null);
                    newDoc.writeCharacters(sourceElement.getText());
                    newDoc.writeEndElement(); // end of 'source'

                    newDoc.writeCharacters('\n                ');
                    newDoc.writeStartElement(null, 'target', null);
                    if (targetElement != null) {
                        newDoc.writeCharacters(sourceElement.getText());
                    } else {
                        newDoc.writeCharacters(id);
                    }
                    newDoc.writeEndElement(); // end of 'target'

                    newDoc.writeCharacters('\n            ');
                    newDoc.writeEndElement(); // end of 'trans-unit'
                }
                newDoc.writeCharacters('\n        ');
                newDoc.writeEndElement(); // end of 'body'
            }
            newDoc.writeCharacters('\n    ');
            newDoc.writeEndElement(); // end of 'file'
        }

        newDoc.writeCharacters('\n');
        newDoc.writeEndElement(); // end of 'exliff'
        newDoc.writeEndDocument();
        String docString = newDoc.getXmlString();
        newDoc.close();

        return Blob.valueOf(docString);
    }
}