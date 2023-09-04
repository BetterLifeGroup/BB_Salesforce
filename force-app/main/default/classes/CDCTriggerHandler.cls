/**
 * Created by fkleynhans on 2022/09/01.
 */

public class CDCTriggerHandler {
    public static void createCDCLog(List<SObject> newTrigger) {
//        Integration_Parameter__mdt integrationParams = Integration_Parameter__mdt.getInstance('Excluded_Users');
//        List<String> userNames = integrationParams.Parameter_Value__c.split(',');
//        Set<Id> excludeIds = new Set<Id>(New Map<Id, User>([SELECT Id FROM User WHERE Username IN: userNames]).keySet());
//        List<CDC_Log__c> lst_CDC = new List<CDC_Log__c>();
//
//        for (SObject event : newTrigger) {
//            EventBus.ChangeEventHeader header = (EventBus.ChangeEventHeader) event.get('ChangeEventHeader');
//
//            if (!excludeIds.contains(header.commitUser)) {
//                CDC_Log__c cdc = new CDC_Log__c();
//                cdc.Object__c = header.entityName;
//                cdc.recordId__c = header.recordids[0];
//                cdc.Event__c = JSON.serialize(event);
//                cdc.Header__c = JSON.serialize(header);
//                lst_CDC.add(cdc);
//            }
//        }
//        insert lst_CDC;
    }
}