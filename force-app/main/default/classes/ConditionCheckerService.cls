/**
 * Created by Andrii Kryvolap.
 */

public without sharing class ConditionCheckerService {
    private static final Integer NOT_OPERATOR_CODE = 1;
    private static final Integer OR_OPERATOR_CODE = 2;
    private static final Integer AND_OPERATOR_CODE = 3;
    private static final Integer BRACKET_CODE = 4;
    private static  final Integer OPERATOR_STACK_BASE = 5;
    private static final Integer FALSE_VALUE_CODE = 1;
    private static final Integer TRUE_VALUE_CODE = 2;
    private static  final Integer VALUE_STACK_BASE = 3;
    private static final String defaultName = 'obj';

    private static Map<Id, Map<String, Boolean>> resultsCache = new Map<Id, Map<String, Boolean>>();

    public static Boolean checkConditionForObject(String condition, SObject obj){
        if(resultsCache.containsKey(obj.Id) && resultsCache.get(obj.Id).containsKey(condition))
            return resultsCache.get(obj.Id).get(condition);
        Boolean result = checkConditionForMultipleObjects(condition, new Map<String, SObject>{defaultName=>obj},defaultName );
        if(!resultsCache.containsKey(obj.Id)){
            resultsCache.put(obj.Id, new Map<String, Boolean>());
        }
        resultsCache.get(obj.Id).put(condition, result);
        return result;
    }

    public static Boolean checkConditionForMultipleObjects(String condition, Map<String, SObject> objectMap, String defaultObjectName){
        enumStack operatorStack = new enumStack(OPERATOR_STACK_BASE);
        enumStack valueStack = new enumStack(VALUE_STACK_BASE);
        Pattern operatorPattern = Pattern.compile('\\(|\\)|&&|\\|\\||!');
        Matcher operatorMatcher = operatorPattern.matcher(condition);
        Integer pos = 0;
        while(operatorMatcher.find()){
            if(pos != operatorMatcher.start()){
                processToken(condition.substring(pos, operatorMatcher.start()),operatorStack, valueStack, objectMap, defaultObjectName);
            }
            processToken(operatorMatcher.group(), operatorStack, valueStack, objectMap, defaultObjectName);
            pos = operatorMatcher.end();
        }
        if(pos < condition.length()){
            processToken(condition.substring(pos, condition.length()),operatorStack, valueStack, objectMap, defaultObjectName);
        }
        while(!operatorStack.isEmpty()){
            executeTopOperator(operatorStack, valueStack);
        }
        return valueStack.pop() == TRUE_VALUE_CODE;
    }

    private static void processToken(String token, enumStack operatorStack, enumStack valueStack, Map<String, SObject> objectMap, String defaultObjectName){
        switch on token {
            when '!', '&&', '||', '(', ')' {
                processOperator(token, operatorStack, valueStack);
            }
            when else {
                if( String.isNotBlank(token)){
                    Boolean value = parseAndCheckAtomicConditionForObject(token, objectMap, defaultObjectName);
                    processValue(value, operatorStack, valueStack);
                }
            }
        }
    }

    private static void processOperator(String operator, enumStack operatorStack, enumStack valueStack) {
        switch on operator{
            when '!' {
                operatorStack.push(NOT_OPERATOR_CODE);
            }
            when '&&' {
                operatorStack.push(AND_OPERATOR_CODE);
            }
            when '||' {
                if(operatorStack.peek() == OR_OPERATOR_CODE){
                    executeTopOperator(operatorStack, valueStack);
                }
                operatorStack.push(OR_OPERATOR_CODE);
            }
            when '(' {
                operatorStack.push(BRACKET_CODE);
            }
            when ')' {
                while(operatorStack.peek()!= BRACKET_CODE){
                    executeTopOperator(operatorStack, valueStack);
                }
                operatorStack.pop();
                processValue(valueStack.pop() == TRUE_VALUE_CODE, operatorStack, valueStack);
            }
        }
    }

    private static void processValue(Boolean value, enumStack operatorStack, enumStack valueStack){
        Integer valueCode = value?TRUE_VALUE_CODE:FALSE_VALUE_CODE;
        valueStack.push(valueCode);
        Integer operationCode = operatorStack.peek();
        if(operationCode == AND_OPERATOR_CODE || operationCode == NOT_OPERATOR_CODE){
            executeTopOperator(operatorStack, valueStack);
        }

    }

    private static void executeTopOperator(enumStack operatorStack, enumStack valueStack){
        Integer operationCode = operatorStack.pop();
        if(operationCode != NOT_OPERATOR_CODE){
            Integer valueCode1 = valueStack.pop();
            Integer valueCode2 = valueStack.pop();
            if(operationCode == OR_OPERATOR_CODE){
                valueStack.push(Math.max(valueCode1, valueCode2));
            }
            else{
                valueStack.push(Math.min(valueCode1, valueCode2));
            }
        }
        else{
            Integer valueCode = valueStack.pop();
            valueStack.push(TRUE_VALUE_CODE+FALSE_VALUE_CODE-valueCode);
        }
    }

    private static Boolean parseAndCheckAtomicConditionForObject(String condition, Map<String, SObject> objectMap, String defaultObjectName){

        Pattern equalsPattern = Pattern.compile('==|<>');
        Matcher equalsMatcher = equalsPattern.matcher(condition);
        if(equalsMatcher.find()){
            return checkAtomicConditionForObject(
                    condition.substring(0,equalsMatcher.start()).trim(),
                    equalsMatcher.group() == '==',
                    condition.substring(equalsMatcher.end(), condition.length()).trim(),
                    objectMap, defaultObjectName
            );
        }
        else{
           // throw Exception();
            return false;
        }
    }

    private static Boolean checkAtomicConditionForObject(String fullFieldName, Boolean equality, String valueString, Map<String, SObject> objectMap, String defaultObjectName){
        List<String> filedTokens = fullFieldName.split('\\.');
        SObject obj;
        Object fieldValue;
        if (filedTokens.size() == 1) {
            obj = objectMap.get(defaultObjectName);
            fieldValue = obj.get(filedTokens[0]);
        }
        else{
            obj = objectMap.get(filedTokens[0]);
            fieldValue = obj.get(filedTokens[1]);
        }
        String fieldValueString = String.valueOf(fieldValue);
        return fieldValue != null && (equality ? fieldValueString.toLowerCase() == valueString.toLowerCase() : fieldValueString.toLowerCase() != valueString.toLowerCase());
    }

    private class enumStack{
        private Integer base;
        private Integer stack;
        public enumStack(Integer base){
            this.base = base;
            stack = 0;
        }
        public Integer pop(){
            Integer value = Math.mod(stack, base);
            stack /= base;
            return value;
        }

        public void push(Integer value){
            stack = stack * base + value;
        }

        public Boolean isEmpty(){
            return stack == 0;
        }

        public Integer peek(){
            return Math.mod(stack, base);
        }

    }
}