global class OppsAutoCloseOffBatch implements Database.Batchable<SObject> {

    public List<BLG_Workflow__c> blgWorkFlows = [SELECT Id, Name, IncludedStatus__c, Close_off_Contact_Attempts__c, Close_off_Days__c, Close_off_Reason__c, Auto_Close__c FROM BLG_Workflow__c];
    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT ID, Name, Workflow_Description_Formula__c, General_Opportunity__c, Contact_Attempts__c, Assignment_DateTime__c, CloseDate ' +
                'FROM Opportunity ' +
                'WHERE Workflow_Description_Formula__c != null ' +
                'AND (StageName != \'Closed Lost\' OR StageName != \'Closed Won\') ' +
                'AND (' +
                '   (Workflow_Description_Formula__c = \'Attempting Contact\' AND Contact_Attempts__c >= 5) ' +
                '   OR(Workflow_Description_Formula__c = \'Awaiting OTP\' AND Contact_Attempts__c >= 7) ' +
                '   OR(Workflow_Description_Formula__c = \'Awaiting Signature\' AND Contact_Attempts__c >= 2)' +
                '   OR(Workflow_Description_Formula__c = \'Deal Submitted\' AND Contact_Attempts__c >= 2)' +
                '   OR(Workflow_Description_Formula__c = \'OTP Received\')' +
                '   OR(Workflow_Description_Formula__c = \'OTP Received - Awaiting Documents\' AND Contact_Attempts__c >= 11)' +
                '   OR(Workflow_Description_Formula__c = \'Pre-Approval Consent\' AND Contact_Attempts__c >= 6)' +
                '   OR(Workflow_Description_Formula__c = \'Pre-Approval Documents\' AND Contact_Attempts__c >= 8)' +
                '   OR(Workflow_Description_Formula__c = \'Pre-approval OTP Nurturing\' AND Contact_Attempts__c >= 11)' +
                '   OR(Workflow_Description_Formula__c = \'Pre-Approval Verification\' AND Contact_Attempts__c >= 3)' +
                '   OR(Workflow_Description_Formula__c = \'Ready for Verification (Bond)\' AND Contact_Attempts__c >= 2)' +
                '   OR(Workflow_Description_Formula__c = \'Signed Application Uploaded\' AND Contact_Attempts__c >= 2)' +
                ') ' +
                'LIMIT 10000';
        return Database.getQueryLocator(query);

    }
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {

        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        Map<String, BLG_Workflow__c> blgMap = new Map<String, BLG_Workflow__c>();
        for (BLG_Workflow__c blg : blgWorkFlows) {
            blgMap.put(blg.Name.toLowerCase(), blg);
        }
        for (Opportunity opp : scope) {

            BLG_Workflow__c blg = blgMap.get(opp.Workflow_Description_Formula__c.toLowerCase());
            if (blg == null || blg.Close_off_Reason__c == null) {
                System.debug('BLG Workflow not found - ' + opp.Workflow_Description_Formula__c + ' or BLG Workflow Close off Reason not populated');
            } else {
//                System.debug(opp.Contact_Attempts__c + ' - ' + blg.Close_off_Contact_Attempts__c + ' - ' + opp.CloseDate.addDays(Integer.valueOf(blg.Close_off_Days__c)) + ' - ' + Datetime.now());
                if (blg.Auto_Close__c == true && opp.Contact_Attempts__c >= blg.Close_off_Contact_Attempts__c && opp.CloseDate < Datetime.now()) {

                    opp.StageName = 'Closed Lost';
                    opp.Status__c = blg.Close_off_Reason__c;
                    opp.Wrap_Up_Reason__c = 'Automated';
                    if (opp.Status__c == 'No OTP Received') {
                        opp.MC_Counter_NoOTPReceived__c = 31;
//                        Field update to trigger MC - No OTP Received
                    }

                    oppsToUpdate.add(opp);
//                    System.debug('must close' + opp.Name);
                }
            }
        }
        System.debug(oppsToUpdate.size());
        List<Database.SaveResult> updateResults = Database.update(oppsToUpdate, false);
        for (Integer i = 0; i < updateResults.size(); i++) {
            if (!updateResults[i].isSuccess()) {
                System.debug(updateResults[i]);

            }

        }
    }
    global void finish(Database.BatchableContext BC) {
    }
}