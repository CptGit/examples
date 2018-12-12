package example;

import java.lang.instrument.ClassFileTransformer;
import java.lang.instrument.IllegalClassFormatException;
import java.security.ProtectionDomain;

public class Transformer implements ClassFileTransformer {

    @Override
    public byte[] transform(ClassLoader classLoader, String className, Class<?> classBeingRedefined,
                            ProtectionDomain protectionDomain, byte[] classfileBuffer)
            throws IllegalClassFormatException {
        if (isIgnoreClass(className)) {
            return null;
        }

        try {
            System.out.println("Transforming " + className);
            if (isClassRedefined(classBeingRedefined)) {
                return deleteInstrumentation(classLoader, className, classfileBuffer);
            } else {
                return instrumentClass(classLoader, className, classfileBuffer);
            }
        } catch (Throwable t) {
            throw new RuntimeException("Failed to transform.");
        }
    }

    private byte[] instrumentClass(ClassLoader classLoader, String className, byte[] classfileBuffer) {
        System.out.println("Instrumenting " + className);
        return null;
    }

    private byte[] deleteInstrumentation(ClassLoader classLoader, String className, byte[] classfileBuffer) {
        System.out.println("Deleting instrumentation " + className);
        return null;
    }

    private boolean isClassRedefined(Class<?> classBeingRedefined) {
        return classBeingRedefined != null;
    }

    private boolean isIgnoreClass(String className) {
        return className.startsWith("java/") ||
            className.startsWith("jdk/") ||
            className.startsWith("sun/") ||
            className.startsWith("com/sun/") ||
            className.startsWith("org/gradle/") ||
            className.startsWith("worker/org/gradle/") ||
            className.startsWith("org/apache/maven/") ||
            className.startsWith("org/hamcrest/") ||
            className.startsWith("org/slf4j/") ||
            className.startsWith("junit/") ||
            className.startsWith("org/junit/");
    }
}
