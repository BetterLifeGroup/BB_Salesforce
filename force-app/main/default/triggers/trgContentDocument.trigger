/**
 * Created by frans fourie on 2024/01/10.
 */

trigger trgContentDocument on ContentDocument (before delete) {

    for (ContentDocument cd : Trigger.old) {
        Boolean block = true;
        List<ContentVersion> cvList = [SELECT Id, ReasonForChange FROM ContentVersion WHERE ContentDocumentId = :cd.Id];
        for (ContentVersion cv : cvList) {
            if (cv.ReasonForChange == 'delete') {
                block = false;
            }
        }
        if (block) {
            cd.addError('Unable to delete - Please delete files using the file component');
        }
    }
}