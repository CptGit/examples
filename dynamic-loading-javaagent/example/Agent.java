package example;

import java.lang.instrument.Instrumentation;

public class Agent {

    private static Instrumentation sInst;

    public static Instrumentation getInst() {
        return sInst;
    }

    public static void premain(String agentArgs, Instrumentation inst) {
        System.out.println("Invoking premain method.");
        sInst = inst;

        // add transformer
        Transformer t = new Transformer();
        inst.addTransformer(t);
    }

    public static void agentmain(String agentArgs, Instrumentation inst) {
        System.out.println("Invoking agentmain method.");
        sInst = inst;

        Transformer t = new Transformer();
        inst.addTransformer(t, true);
        try {
            for (Class<?> clz : inst.getAllLoadedClasses()) {
                String name = clz.getName();
                if (name.equals("Hello") || name.equals("Test")) {
                    inst.retransformClasses(clz);
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            inst.removeTransformer(t);
        }
    }
}
