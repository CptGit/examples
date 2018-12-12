package test.objecthistory.recorded;

public class Outer {
    String str;
    public Outer() {
        this.str = "Outer";
        System.out.println(str);
    }

    public static class StaticNested {
        String str;
        public StaticNested() {
            this.str = "Static Nested Class";
            System.out.println(str);
        }
//        public void print() {
//            System.out.println(str);
//        }
    }

    public class Member {
        String str;
        public Member() {
            this.str = "Member Class";
            System.out.println(str);
        }
//        public void print() {
//            System.out.println(str);
//        }
    }

    public void declareLocal() {
        class Local {
            String str;
            Local () {
                this.str = "Local Class";
                System.out.println(str);
            }
//            void print() {
//                System.out.println(str);
//            }
        }
        Local local = new Local();
//        local.print();
    }

    public void declareAnonymous() {
        new Object() {
            String str;
            {
                this.str = "Anonymous Class";
                System.out.println(str);
            }
//            public void print() {
//                System.out.println(str);
//            }
        };// .print();
    }

    public void declareMember() {
        Member member = new Member();
    }

    public void declareStaticNested() {
        StaticNested staticNested = new StaticNested();
    }
}
