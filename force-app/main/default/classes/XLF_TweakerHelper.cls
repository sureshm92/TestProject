/**
 * Created by Slav on 23.10.2019.
 */

public class XLF_TweakerHelper {
    private List<String> whitePatterns;
    private List<String> blackPatterns;
    
    /**
     * constructor
     */
    public XLF_TweakerHelper () {
        whitePatterns = new List<String>();
        blackPatterns = new List<String>();
        for (XLF_White_List__mdt whiteList : [SELECT Pattern__c FROM XLF_White_List__mdt WHERE Active__c = TRUE]) {
            whitePatterns.add(whiteList.Pattern__c);
        }
        for (XLF_Black_List__mdt blackList : [SELECT Pattern__c FROM XLF_Black_List__mdt WHERE Active__c = TRUE]) {
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
    public Blob tweakData (Blob data) {
        Dom.Document doc = new Dom.Document();
        doc.load(data.toString());
        Dom.XmlNode rootNode = doc.getRootElement();
    
        //--------------------------------------------------------------//
        // parse document body and remove unwanted elements             //
        //--------------------------------------------------------------//
        for (Dom.XmlNode fileElement : rootNode.getChildElements()) {
            if (fileElement.getName() != 'file') continue;
            for (Dom.XmlNode bodyElement : fileElement.getChildElements()) {
                if (bodyElement.getName() != 'body') continue;
                for (Dom.XmlNode transElement : bodyElement.getChildElements()) {
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
                        
                        if (whiteMatchFound) break;
                    }
    
                    // ------------------------------------------------------------------
                    // if file element doesn't have any matches in the WhiteList patterns
                    // then remove it from file and go to next element
                    // ------------------------------------------------------------------
                    if (!whiteMatchFound) {
                        for (Dom.XmlNode child : transElement.getChildren()) {
                            transElement.removeChild(child);
                        }
                        bodyElement.removeChild(transElement);
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
        
                        if (blackMatchFound) break;
                    }
    
                    // -----------------------------------------------------
                    // if file element matches any pattern in the BlackList
                    // then remove it from file and go to next element
                    // -----------------------------------------------------
                    if (blackMatchFound) {
                        for (Dom.XmlNode child : transElement.getChildren()) {
                            transElement.removeChild(child);
                        }
                        bodyElement.removeChild(transElement);
                        continue;
                    }
                }
            }
        }
    
        String docString = doc.toXmlString();
        while (docString.contains(' \n')) {
            docString = docString.replace(' \n', '\n');
        }
        while (docString.contains('\n\n')) {
            docString = docString.replace('\n\n', '\n');
        }
        return Blob.valueOf(docString);
    }
}