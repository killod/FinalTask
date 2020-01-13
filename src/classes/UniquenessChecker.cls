/**
 * Created by User on 08.01.2020.
 */

public interface UniquenessChecker {

    void onAfterUndeleteUniqueCheck(Map<Id, SObject> newTriggerMap);
}