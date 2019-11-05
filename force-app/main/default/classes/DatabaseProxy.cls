public inherited sharing class DatabaseProxy {

    public List<SObject> query(String query) {
        System.debug('QUERY: ' + query);
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
        if (withoutSharing) {
            ((DatabaseProxyWithoutSharing) ClassFactory.newInstance(DatabaseProxyWithoutSharing.class)).updateRecord(record);
        } else {
            update record;
        }
    }

    public void updateRecords(List<SObject> records, Boolean withoutSharing) {
        if (withoutSharing) {
            ((DatabaseProxyWithoutSharing) ClassFactory.newInstance(DatabaseProxyWithoutSharing.class)).updateRecords(records);
        } else {
            update records;
        }
    }

    public void upsertRecord(SObject record, Boolean withoutSharing) {
        if (withoutSharing) {
            ((DatabaseProxyWithoutSharing) ClassFactory.newInstance(DatabaseProxyWithoutSharing.class)).upsertRecord(record);
        } else {
            upsert record;
        }
    }

    public void upsertRecords(List<SObject> records, Boolean withoutSharing) {
        if (withoutSharing) {
            ((DatabaseProxyWithoutSharing) ClassFactory.newInstance(DatabaseProxyWithoutSharing.class)).upsertRecords(records);
        } else {
            upsert records;
        }
    }

    public void deleteRecord(SObject record, Boolean withoutSharing) {
        if (withoutSharing) {
            ((DatabaseProxyWithoutSharing) ClassFactory.newInstance(DatabaseProxyWithoutSharing.class)).deleteRecord(record);
        } else {
            delete record;
        }
    }

    public void deleteRecords(List<SObject> records, Boolean withoutSharing) {
        if (withoutSharing) {
            ((DatabaseProxyWithoutSharing) ClassFactory.newInstance(DatabaseProxyWithoutSharing.class)).deleteRecords(records);
        } else {
            delete records;
        }
    }

    private without sharing class DatabaseProxyWithoutSharing {

        private List<SObject> query(String query) {
            return Database.query(query);
        }

        private void updateRecord(SObject record) {
            update record;
        }

        private void updateRecords(List<SObject> records) {
            update records;
        }

        private void upsertRecord(SObject record) {
            upsert record;
        }

        private void upsertRecords(List<SObject> records) {
            upsert records;
        }

        private void deleteRecord(SObject record) {
            delete record;
        }

        private void deleteRecords(List<SObject> records) {
            delete records;
        }
    }
}