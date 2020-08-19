package example;

class Main {

    public static void main(String[] args) {
        Outer outer = new Outer();
        outer.declareLocal();
        outer.declareAnonymous();
        outer.declareMember();
        outer.declareStaticNested();
    }
}
