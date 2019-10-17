/**
 * Created by Yulia Yakushenkova on 10/15/2019.
 */

public with sharing class GetPermissions {

    private static final String Patient_Portal_Edit = 'Patient_Portal_Edit_Study_Settings';
    private static final String Patient_Portal_Read = 'Patient_Portal_Read_Study_Settings';
    private static final List<String> STUDY_PERMISSIONS = new List<String>{
            Patient_Portal_Edit,
            Patient_Portal_Read
    };

    public static String getReadOrEditStudySettings(Id userId){
        List<PermissionSetAssignment> permissions = [
                SELECT PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE Assignee.Id = :userId
                AND PermissionSet.Name IN :STUDY_PERMISSIONS
        ];
        //if(permissions.isEmpty()) return 'Disabled';

        for(PermissionSetAssignment perm : permissions){
            if (perm.PermissionSet.Name == Patient_Portal_Edit) return 'Edit';
            if (perm.PermissionSet.Name == Patient_Portal_Read) return 'Read';
        }
        return 'Disabled';
    }

}