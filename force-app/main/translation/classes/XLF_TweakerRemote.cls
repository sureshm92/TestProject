/**
 * Created by Slav on 22.10.2019.
 */

public without sharing class XLF_TweakerRemote {
    public class RuntimeException extends Exception {
    }

    @AuraEnabled
    public static XLF_RemoteActionResult getDocuments() {
        try {
            List<String> documents = new List<String>();
            for (Document doc : [SELECT Name FROM Document]) {
                documents.add(doc.Name);
            }
            return new XLF_RemoteActionResult(true, null, null, null, documents);
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static XLF_RemoteActionResult getDocId(String docName) {
        try {
            List<Document> documents = [SELECT Id FROM Document WHERE Name = :docName];
            if (documents.isEmpty()) {
                return new XLF_RemoteActionResult(
                    false,
                    null,
                    'Document \"' +
                    docName +
                    '\" was not found',
                    null,
                    null
                );
            } else {
                return new XLF_RemoteActionResult(true, documents[0].Id, null, null, null);
            }
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static XLF_RemoteActionResult startTweaking(String docName) {
        try {
            List<Document> documents = [
                SELECT Name, Type, FolderId, Body
                FROM Document
                WHERE Name = :docName
            ];
            if (documents.isEmpty()) {
                return new XLF_RemoteActionResult(
                    false,
                    null,
                    'Document \"' +
                    docName +
                    '\" was not found',
                    null,
                    null
                );
            }

            String docType = documents[0].Type;
            String newName = documents[0].Name.removeEnd(docType);
            if (!newName.endsWith('.'))
                newName += '.';
            newName += 'tweaked.' + docType;
            Blob xlfData = documents[0].Body;

            if (docType == 'zip') {
                return new XLF_RemoteActionResult(true,null,  null,EncodingUtil.base64Encode(xlfData),  null               );
            }

            if (![SELECT Name FROM Document WHERE Name = :newName].isEmpty()) {
                return new XLF_RemoteActionResult(
                    false,
                    null,
                    'Document \"' +
                    newName +
                    '\" already exists. Perhaps you have already tweaked it.',
                    null,
                    null
                );
            }

            XLF_TweakerHelper tweakerHelper = new XLF_TweakerHelper();
            Blob newBody = tweakerHelper.tweakData(xlfData);
            Document updatedDoc = new Document();
            updatedDoc.Body = newBody;
            updatedDoc.Name = newName;
            updatedDoc.Type = docType;
            updatedDoc.FolderId = documents[0].FolderId;
            insert updatedDoc;

            return new XLF_RemoteActionResult(
                true,
                null,
                'Document \"' +
                docName +
                '\" tweaked successfully',
                null,
                null
            );
        } catch (XmlException e) {
            return new XLF_RemoteActionResult(false,null,'PARSING ERROR: Document \"' +docName +'\" is not a valid XML document',null,null );
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static XLF_RemoteActionResult startZipTweaking(String fileName, String body) {
        try {
            String docType = '';
            List<String> nameParts = fileName.split('\\.');
            if (nameParts.size() > 1) {
                docType = nameParts.get(nameParts.size() - 1);
            }
            String newName = fileName.removeEnd(docType) + 'tweaked.' + docType;
            Blob xlfData = Blob.valueOf(body);

            if (![SELECT Name FROM Document WHERE Name = :newName].isEmpty()) {
                return new XLF_RemoteActionResult(
                    false,
                    null,
                    'Document \"' +
                    newName +
                    '\" already exists. Perhaps you have already tweaked it.',
                    null,
                    null
                );
            }

            XLF_TweakerHelper tweakerHelper = new XLF_TweakerHelper();
            Blob newBody = tweakerHelper.tweakData(xlfData);
            Document updatedDoc = new Document();
            updatedDoc.Body = newBody;
            updatedDoc.Name = newName;
            updatedDoc.AuthorId = UserInfo.getUserId();
            updatedDoc.Type = docType;
            updatedDoc.FolderId = [SELECT FolderId FROM Document LIMIT 1].FolderId;
            insert updatedDoc;

            return new XLF_RemoteActionResult(
                true,
                null,
                'Document \"' +
                fileName +
                '\" tweaked successfully',
                null,
                null
            );
        } catch (XmlException e) {
            return new XLF_RemoteActionResult(false,null,'PARSING ERROR: Document \"' +fileName +'\" is not a valid XML document',null,null );
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}