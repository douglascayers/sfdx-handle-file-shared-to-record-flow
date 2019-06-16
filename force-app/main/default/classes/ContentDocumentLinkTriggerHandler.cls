public with sharing class ContentDocumentLinkTriggerHandler {

    public void handleAfterInsert( List<ContentDocumentLink> newList, Map<ID, ContentDocumentLink> newMap ) {

        System.debug( 'ContentDocumentLinkTriggerHandler.afterInsert' );

        // To avoid the Flow needing to make an extra query to learn the ContentVersionId
        // of the document that was shared to the record, we can perform that query here.
        // Due to a silly implementation restriction with ContentDocumentLink object, queries
        // require a filter on ContentDocumentId or LinkedEntityId field.
        // Despite having the ID of the ContentDocumentLink records we want, if we
        // do a query we have to filter by one of the other fields.
        // We can iterate the list of CDLs that we have and filter by that.

        Set<ID> contentDocumentIds = new Set<ID>();
        for ( ContentDocumentLink cdl : newList ) {
            contentDocumentIds.add( cdl.ContentDocumentId );
        }

        // Re-query to get the ContentVersionId from the ContentDocument
        List<ContentDocumentLink> cdls = new List<ContentDocumentLink>([
            SELECT
                Id,
                LinkedEntityId,
                ContentDocumentId,
                ContentDocument.LatestPublishedVersionId
            FROM
                ContentDocumentLink
            WHERE
                // filtering by id "should" be the only filter needed...
                Id IN :newList
                AND
                // but due to implementation restriction, we need another filter...
                ContentDocumentId IN :contentDocumentIds
        ]);

        for ( ContentDocumentLink cdl : cdls ) {

            // Launch flow from apex
            // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/flow_interview_class.htm

            Map<String, Object> inputs = new Map<String, Object>{
                'varContentDocumentLinkId' => cdl.Id,
                'varRecordId' => cdl.LinkedEntityId,
                'varContentDocumentId' => cdl.ContentDocumentId,
                'varContentVersionId' => cdl.ContentDocument.LatestPublishedVersionId
            };

            Flow.Interview myFlow = Flow.Interview.createInterview( 'Handle_File_Shared_To_Record_Flow', inputs );
            myFlow.start();

        }

    }

}
