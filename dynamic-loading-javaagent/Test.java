public class Test {

    public static void main(String[] args) throws Exception {
        System.out.println("Invoking main.");
        Hello.print();
        AgentLoader.loadAgent();
    }
}

class Hello {

    public static void print() {
        System.out.println("Invoking print.");
    }
}
