public class Context {
    public static Boolean isFutureContext = false;  /* this can be set by @future [asynchronous] methods to help control 
                                                       trigger recursion caused by updates that the asynchronous method may make to records
                                                       you don't need to use this unless the @future method performs DML operations             */

    public static Boolean isTriggerContext = false; // this can be set by Triggers to indicate that a Trigger operation caused the update
}