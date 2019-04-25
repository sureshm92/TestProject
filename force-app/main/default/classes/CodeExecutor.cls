public virtual class CodeExecutor {

    public List<Object> result;

    public Object execute(List<Object> listOfArgs) {
        result = this.getResult(listOfArgs);
        return result;
    }

    public virtual List<Object> getResult(List<Object> listOfArgs) {return result;}
}