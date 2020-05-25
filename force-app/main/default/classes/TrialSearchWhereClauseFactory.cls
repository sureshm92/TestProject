/**
 * Created by Vitalii Aheienko on 9/13/2019.
 * Updated by Sravani Dasari on 5/14/2020 
 */

public with sharing class TrialSearchWhereClauseFactory {

    //ORS status
    public static final String ACTIVELY_ENROLLING = 'Actively Enrolling';
    public static final String ON_HOLD = 'On Hold';

    //CTMS status
    public static final String ENROLLING = 'Enrolling';
    public static final String OPEN_TO_ENROLLMENT = 'Open to Enrollment';
    public static final String PLANNING = 'Planning';
    public static final String IN_DEVELOPMENT = 'In Development';

    public static final List<String> ORS_STATUS_ENROLLING = new List<String>{
            ACTIVELY_ENROLLING,
            ON_HOLD
    };

    public static final List<String> CTMS_RECRUITMENT = new List<String>{
            ENROLLING,
            OPEN_TO_ENROLLMENT,
            PLANNING,
            IN_DEVELOPMENT
    };

    public static final List<String> CTMS_RECRUITMENT_ENROLLING = new List<String>{
            ENROLLING,
            OPEN_TO_ENROLLMENT
    };

    public static final List<String> CTMS_ON_HOLD = new List<String>{
            PLANNING,
            IN_DEVELOPMENT
    };


    public WhereClause getInstance(List<Id> taIds, Boolean isEnrolling, Boolean isNotYetEnrolling, Set<Id> userQCareSSIds) {
        WhereClause idFilteredClause = new IdFilteredWhereClause(taIds);
        WhereClause enrolledIdFilteredClause = this.getEnrollingExtendedWhereClause(idFilteredClause, isEnrolling, isNotYetEnrolling);
        if (userQCareSSIds != null && !userQCareSSIds.isEmpty()) {
            WhereClause qCareEnrolledidFilteredClause = new QCareWhereClauseDecorator(enrolledIdFilteredClause, userQCareSSIds);
            return qCareEnrolledidFilteredClause;
        }

        return enrolledIdFilteredClause;
    }
    // Added by Sravani Dasari for Trial Match PEH-2031
    public WhereClause getInstance(List<Id> taIds, String objfield, Boolean isEnrolling, Boolean isNotYetEnrolling, Set<Id> userQCareSSIds) {
        WhereClause idFilteredClause = new IdFilteredWhereClause(taIds,objfield);
        WhereClause enrolledIdFilteredClause = this.getEnrollingExtendedWhereClause(idFilteredClause, isEnrolling, isNotYetEnrolling);
        if (userQCareSSIds != null && !userQCareSSIds.isEmpty()) {
            WhereClause qCareEnrolledidFilteredClause = new QCareWhereClauseDecorator(enrolledIdFilteredClause, userQCareSSIds);
            return qCareEnrolledidFilteredClause;
        }

        return enrolledIdFilteredClause;
    }
	//Ended by Sravani Dasari
    private WhereClause getEnrollingExtendedWhereClause(WhereClause clause, Boolean isEnrolling, Boolean isNotYetEnrolling) {
        if (isEnrolling && isNotYetEnrolling) {
            return new EnrollingNotEnrollingWhereClauseDecorator(clause);
        } else if (isEnrolling) {
            return new EnrollingWhereClauseDecorator(clause);
        } else if (isNotYetEnrolling) {
            return new NotEnrollingWhereClauseDecorator(clause);
        }
        return new WhereClauseDecorator(clause);
    }


    public interface WhereClause {
        String getWhereClause();
    }

    public virtual class WhereClauseDecorator implements WhereClause {
        private WhereClause clause;

        public WhereClauseDecorator(WhereClause clause) {
            this.clause = clause;
        }

        public virtual String getWhereClause() {
            return clause != null ? clause.getWhereClause() : '';
        }
    }

    public class IdFilteredWhereClause implements WhereClause {

        List<Id> taIds;
		String whereField; // Added by Sravani Dasari for Trial Match PEH-2031
        
        public IdFilteredWhereClause(List<Id> taIds) {
            this.taIds = taIds;
            whereField = 'Therapeutic_Area__c';
        }
		// Added by Sravani Dasari for Trial Match PEH-2031
        public IdFilteredWhereClause(List<Id> taIds, String objType) {
            this.taIds = taIds;
			if(objType!=null)
			 whereField= objType;
		}
        //Ended by Sravani
        public String getWhereClause() {
            Boolean emptyTaIds = taIds == null || taIds.isEmpty();
            return emptyTaIds ? '' : 'WHERE '+ whereField +' IN (' + CollectionUtil.joinByComa(CollectionUtil.wrapInApostrophes(taIds)) + ') ';
        }

    }

    public class QCareWhereClauseDecorator extends WhereClauseDecorator {

        private List<Id> qCareSSIds;

        public QCareWhereClauseDecorator(WhereClause clause, Set<Id> qCareSSIds) {
            super(clause);
            this.qCareSSIds = new List<Id>(qCareSSIds);
        }

        public override String getWhereClause() {
            return (String.isBlank(clause.getWhereClause()) ? 'WHERE' : clause.getWhereClause() + 'AND') +
                    ' Id IN (SELECT Clinical_Trial_Profile__c FROM Study_Site__c WHERE Id IN (' + CollectionUtil.joinByComa(CollectionUtil.wrapInApostrophes(qCareSSIds)) + ')) ';
        }
    }

    public class EnrollingWhereClauseDecorator extends WhereClauseDecorator {

        public EnrollingWhereClauseDecorator(WhereClause clause) {
            super(clause);
        }

        public override String getWhereClause() {
            return (String.isBlank(clause.getWhereClause()) ? 'WHERE' : clause.getWhereClause() + 'AND') +
                    ' (Override_Recruitment_Status__c = ' + '\'' + ACTIVELY_ENROLLING + '\' ' +
                    'OR Override_Recruitment_Status__c IN (' + CollectionUtil.joinByComa(CollectionUtil.wrapInApostrophes(CTMS_RECRUITMENT_ENROLLING)) + ')) ';
        }
    }

    public class NotEnrollingWhereClauseDecorator extends WhereClauseDecorator {

        public NotEnrollingWhereClauseDecorator(WhereClause clause) {
            super(clause);
        }

        public override String getWhereClause() {
            return (String.isBlank(clause.getWhereClause()) ? 'WHERE' : clause.getWhereClause() + 'AND') +
                    ' (Override_Recruitment_Status__c = ' + '\'' + ON_HOLD + '\' ' +
                    'OR Override_Recruitment_Status__c IN (' + CollectionUtil.joinByComa(CollectionUtil.wrapInApostrophes(CTMS_ON_HOLD)) + ')) ';
        }
    }

    public class EnrollingNotEnrollingWhereClauseDecorator extends WhereClauseDecorator {

        public EnrollingNotEnrollingWhereClauseDecorator(WhereClause clause) {
            super(clause);
        }

        public override String getWhereClause() {
            return (String.isBlank(clause.getWhereClause()) ? 'WHERE' : clause.getWhereClause() + 'AND') +
                    ' (Override_Recruitment_Status__c IN (' + CollectionUtil.joinByComa(CollectionUtil.wrapInApostrophes(ORS_STATUS_ENROLLING)) + ') ' +
                    'OR Override_Recruitment_Status__c IN (' + CollectionUtil.joinByComa(CollectionUtil.wrapInApostrophes(CTMS_RECRUITMENT)) + ')) ';
        }
    }

}