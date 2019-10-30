/**
 * Created by Slav on 22.10.2019.
 */

public without sharing class XLF_TweakerRemote {
    public class RuntimeException extends Exception {
    }
    
    @AuraEnabled
    public static List<String> getDocuments () {
        try {
            List<String> documents = new List<String>();
            for (Document doc : [SELECT Name FROM Document]) {
                documents.add(doc.Name);
            }
            return documents;
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static String startTweaking (String docName) {
        try {
            List<Document> documents = [SELECT Name, Type, FolderId, Body FROM Document WHERE Name = :docName];
            if (documents.isEmpty()) {
                return 'false:Document ' + docName + ' was not found';
            }
    
            String docType = documents[0].Type;
            String newName = documents[0].Name.removeEnd(docType) + 'tweaked.' + docType;
            Blob   xlfData = documents[0].Body;
    
            if (docType == 'zip') {
                return 'zip:' + EncodingUtil.base64Encode(xlfData);
            }
            
            if (![SELECT Name FROM Document WHERE Name = :newName].isEmpty()) {
                return 'false:Document \"' + newName + '\" already exists. Perhaps you have already tweaked it.';
            }
    
            XLF_TweakerHelper tweakerHelper = new XLF_TweakerHelper();
            Blob newBody = tweakerHelper.tweakData(xlfData);
            Document updatedDoc = new Document();
            updatedDoc.Body     = newBody;
            updatedDoc.Name     = newName;
            updatedDoc.Type     = docType;
            updatedDoc.FolderId = documents[0].FolderId;
            insert updatedDoc;
    
            return 'true:Document \"' + docName + '\" tweaked successfully';
        } catch (XmlException e) {
            return 'false:PARSING ERROR: Document \"' + docName + '\" is not a valid XML document';
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    @AuraEnabled
    public static String startZipTweaking (String fileName, String body) {
        try {
            String docType = '';
            List<String> nameParts = fileName.split('\\.');
            if (nameParts.size() > 1) {
                docType = nameParts.get(nameParts.size() - 1);
            }
            String newName = fileName.removeEnd(docType) + 'tweaked.' + docType;
            Blob xlfData = Blob.valueOf(body);

            if (![SELECT Name FROM Document WHERE Name = :newName].isEmpty()) {
                return 'false:Document \"' + newName + '\" already exists. Perhaps you have already tweaked it.';
            }

            XLF_TweakerHelper tweakerHelper = new XLF_TweakerHelper();
            Blob newBody = tweakerHelper.tweakData(xlfData);
            Document updatedDoc = new Document();
            updatedDoc.Body     = newBody;
            updatedDoc.Name     = newName;
            updatedDoc.Type     = docType;
            updatedDoc.FolderId = [SELECT FolderId FROM Document LIMIT 1].FolderId;
            insert updatedDoc;

            return 'true:Document \"' + fileName + '\" tweaked successfully';
        } catch (XmlException e) {
            return 'false:PARSING ERROR: File \"' + fileName + '\" is not a valid XML document';
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}