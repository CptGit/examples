package example;

import java.lang.management.ManagementFactory;

import com.sun.tools.attach.VirtualMachine;

public class AgentLoader {
    private static final String jarFilePath = "example/Agent.jar";

    public static void loadAgent() {
        System.out.println("Dynamically Loading javaagent.");
        String nameOfRunningVM = ManagementFactory.getRuntimeMXBean().getName();
        String pid = nameOfRunningVM.substring(0, nameOfRunningVM.indexOf('@'));

        try {
            VirtualMachine vm = VirtualMachine.attach(pid);
            vm.loadAgent(jarFilePath, "");
            vm.detach();
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        }
    }
}
