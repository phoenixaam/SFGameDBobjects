
public with sharing class FieldsChecker {
     /**
      * check if an Sobject has a field
      */
    public static boolean hasSObjectField(SObject so, String fieldName){

        String s = JSON.serialize(so);

        // Deserialize it back into a key/value map
        Map<String,Object> obj = (Map<String,Object>) JSON.deserializeUntyped(s);

        // Build a set containing the fields present on our SObject
        Set<String> fieldsPresent = obj.keyset().clone();

        return fieldsPresent.contains(fieldName);
    }
}