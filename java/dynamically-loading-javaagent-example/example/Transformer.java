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
            if (isClassRedefinedOrRetransformed(classBeingRedefined)) {
                return retransformClass(classLoader, className, classfileBuffer);
            } else {
                return firstTransformClass(classLoader, className, classfileBuffer);
            }
        } catch (Throwable t) {
            throw new RuntimeException("Failed to transform.");
        }
    }

    private byte[] firstTransformClass(ClassLoader classLoader, String className, byte[] classfileBuffer) {
        System.out.println("First transforming " + className + " but we did not anything.");
        return null;
    }

    private byte[] retransformClass(ClassLoader classLoader, String className, byte[] classfileBuffer) {
        System.out.println("Retransforming " + className + " but we did not anything.");
        return null;
    }

    private boolean isClassRedefinedOrRetransformed(Class<?> classBeingRedefined) {
        // classBeingRedefined will be null if the class is normally loaded
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
