trigger ContentDocumentLinkTrigger on ContentDocumentLink ( after insert ) {

    ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();

    if ( Trigger.isAfter && Trigger.isInsert ) {
        handler.handleAfterInsert( Trigger.new, Trigger.newMap );
    }

}