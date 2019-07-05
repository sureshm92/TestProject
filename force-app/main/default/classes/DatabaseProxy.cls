public inherited sharing class DatabaseProxy {

    public List<SObject> query(String query) {
        return Database.query(query);
    }

    public List<SObject> query(String query, Boolean withoutSharing) {
        if (withoutSharing) {
            return ((DatabaseProxyWithoutSharing) ClassFactory.newInstance(DatabaseProxyWithoutSharing.class)).query(query);
        } else {
            return this.query(query);
        }
    }

    public void updateRecord(SObject record, Boolean withoutSharing) {
        if(withoutSharing) {
            ((DatabaseProxyWithoutSharing) ClassFactory.newInstance(DatabaseProxyWithoutSharing.class)).updateRecord(record);
        } else {
            update record;
        }
    }

    public void updateRecords(List<SObject> records, Boolean withoutSharing) {
        if(withoutSharing) {
            ((DatabaseProxyWithoutSharing) ClassFactory.newInstance(DatabaseProxyWithoutSharing.class)).updateRecords(records);
        } else {
            update records;
        }
    }

    public void upsertRecord(SObject record) {
        upsert record;
    }

    public void upsertRecords(List<SObject> records) {
        upsert records;
    }

    public without sharing class DatabaseProxyWithoutSharing {

        public List<SObject> query(String query) {
            return Database.query(query);
        }

        public void updateRecord(SObject record) {
            update record;
        }

        public void updateRecords(List<SObject> records) {
            update records;
        }
    }
}