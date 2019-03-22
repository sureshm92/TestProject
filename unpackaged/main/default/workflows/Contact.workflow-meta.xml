<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Populate_Override_Field_Address</fullName>
        <field>Override_Mailing_Address__c</field>
        <formula>MailingStreet &amp; BR() &amp; MailingCity &amp; &quot;, &quot; &amp; MailingState &amp; &quot;  &quot; &amp;MailingPostalCode</formula>
        <name>Populate Override Field: Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Override_Field_Email</fullName>
        <field>Override_Email__c</field>
        <formula>Email</formula>
        <name>Populate Override Field: Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Populate_Override_Field_Phone</fullName>
        <field>Override_Phone__c</field>
        <formula>Phone</formula>
        <name>Populate Override Field: Phone</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Populate Override Address Field%3A Contact</fullName>
        <actions>
            <name>Populate_Override_Field_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>LastName &lt;&gt; NULL &amp;&amp; ISBLANK(  Override_Mailing_Address__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populate Override Email Field%3A Contact</fullName>
        <actions>
            <name>Populate_Override_Field_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>LastName &lt;&gt; NULL &amp;&amp; ISBLANK( Override_Email__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populate Override Fields%3A Contact</fullName>
        <actions>
            <name>Populate_Override_Field_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Override_Field_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Populate_Override_Field_Phone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>LastName &lt;&gt; NULL</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Populate Override Phone Field%3A Contact</fullName>
        <actions>
            <name>Populate_Override_Field_Phone</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>LastName &lt;&gt; NULL &amp;&amp;  ISBLANK( Override_Phone__c )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
