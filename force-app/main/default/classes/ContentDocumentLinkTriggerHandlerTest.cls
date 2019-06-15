@IsTest
private class ContentDocumentLinkTriggerHandlerTest {

    @IsTest
    static void test_share_file_to_record() {

        // You may need to modify this
        // test to be able to insert an account
        // that meets your org's validation requirements.
        Account acct = new Account(
            Name = 'Test Account'
        );

        insert acct;

        // create a file, unshared to any record
        ContentVersion file = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'file.txt',
            VersionData = Blob.valueOf( 'Hello World' )
        );

        insert file;

        // query the generated content document id
        file = [ SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :file.Id ];

        Test.startTest();

        // share the file to the account
        ContentDocumentLink cdl = new ContentDocumentLink(
            ContentDocumentId = file.ContentDocumentId,
            LinkedEntityId = acct.Id,
            ShareType = 'I'
        );

        insert cdl; // trigger fires

        Test.stopTest();

        // Unless you've changed the "Handle File Shared To Record Flow" flow,
        // then it should have posted a chatter message to the record.
        // If you customize the flow, you'll need to modify this test logic too.
        List<FeedItem> posts = new List<FeedItem>([
            SELECT Id, Body
            FROM FeedItem
            WHERE ParentId = :acct.Id
            ORDER BY CreatedDate DESC
            LIMIT 10
        ]);

        Boolean postFound = false;
        for ( FeedItem post : posts ) {
            postFound = postFound || ( post.Body != null && post.Body.containsIgnoreCase( 'A file has been shared to this record' ) );
        }
        System.assert( postFound, 'Did not find Chatter post with message "A file has been shared to this record".' );

    }

}
