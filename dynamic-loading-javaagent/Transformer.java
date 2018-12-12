import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.IllegalClassFormatException;
import java.security.ProtectionDomain;

public class Transformer implements ClassFileTransformer {

    @Override
    public byte[] transform(ClassLoader classLoader, String className, Class<?> classBeingRedefined,
                            ProtectionDomain protectionDomain, byte[] classfileBuffer)
            throws IllegalClassFormatException {
        try {
            if (className.equals("Test") || className.equals("Hello")) {
                System.out.println("Transforming " + className);
            }
            return null;
        } catch (Throwable t) {
            throw new RuntimeException("Failed to transform.");
        }
    }
}
