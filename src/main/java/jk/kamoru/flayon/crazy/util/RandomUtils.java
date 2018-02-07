package jk.kamoru.flayon.crazy.util;

import java.util.Random;

import jk.kamoru.flayon.crazy.error.CrazyException;

public class RandomUtils {

    private static final class RandomNumberGeneratorHolder {
        static final Random randomNumberGenerator = new Random();
    }

	/**
	 * Returns a boolean value
	 * @return a pseudorandom boolean
	 */
	public static boolean getBoolean() {
		return nextBoolean();
	}
	
	/**
	 * Returns a int value, greater than or equal to 0 and less than max
	 * @param max maximum range 
	 * @return a pseudorandom int greater than or equal to 0 and less than max.
	 */
	public static int getInt(int max) {
		return (int) getDouble(0, max);
	}
	
	/**
	 * Returns a int value, greater than or equal to min and less than max
	 * @param min minimum range
	 * @param max maximum range 
	 * @return a pseudorandom int greater than or equal to min and less than max.
	 */
	public static int getInt(int min, int max) {
		return (int) getDouble(min, max);
	}

	/**
	 * Returns a long value, greater than or equal to 0 and less than max
	 * @param max maximum range 
	 * @return a pseudorandom long greater than or equal to 0 and less than max.
	 */
	public static long getLong(long max) {
		return (long) getDouble(0, max);
	}

	/**
	 * Returns a long value, greater than or equal to min and less than max
	 * @param min minimum range
	 * @param max maximum range 
	 * @return a pseudorandom long greater than or equal to min and less than max.
	 */
	public static long getLong(long min, long max) {
		return (long) getDouble(min, max);
	}

	/**
	 * Returns a float value, greater than or equal to 0.0 and less than max
	 * @param max maximum range 
	 * @return a pseudorandom float greater than or equal to 0.0 and less than max.
	 */
	public static float getFloat(float max) {
		return (float) getDouble(0, max);
	}

	/**
	 * Returns a float value, greater than or equal to min and less than max
	 * @param min minimum range
	 * @param max maximum range 
	 * @return a pseudorandom float greater than or equal to min and less than max.
	 */
	public static float getFloat(float min, float max) {
		return (float) getDouble(min, max);
	}

	/**
	 * Returns a double value, greater than or equal to 0.0 and less than max
	 * @param max maximum range 
	 * @return a pseudorandom double greater than or equal to 0.0 and less than max.
	 */
	public static double getDouble(double max) {
		return getDouble(0, max);
	}

	/**
	 * Returns a double value, greater than or equal to min and less than max
	 * @param min minimum range
	 * @param max maximum range 
	 * @return a pseudorandom double greater than or equal to min and less than max.
	 */
	public static double getDouble(double min, double max) {
		if (min > max)
			throw new CrazyException("must be min < max");
		return nextDouble() * (max - min) + min;
	}

	public static boolean nextBoolean() {
		return RandomNumberGeneratorHolder.randomNumberGenerator.nextBoolean();
	}

	public static int nextInt() {
		return RandomNumberGeneratorHolder.randomNumberGenerator.nextInt();
	}

	public static int nextInt(int bound) {
		return RandomNumberGeneratorHolder.randomNumberGenerator.nextInt(bound);
	}

	public static long nextLong() {
		return RandomNumberGeneratorHolder.randomNumberGenerator.nextLong();
	}

	public static float nextFloat() {
		return RandomNumberGeneratorHolder.randomNumberGenerator.nextFloat();
	}

	public static double nextDouble() {
		return RandomNumberGeneratorHolder.randomNumberGenerator.nextDouble();
	}

	public static double nextGaussian() {
		return RandomNumberGeneratorHolder.randomNumberGenerator.nextGaussian();
	}

	public static void nextBytes(byte[] bytes) {
		RandomNumberGeneratorHolder.randomNumberGenerator.nextBytes(bytes);
	}

	// Test
//	public static void main(String[] args) {
//		for (int i=0; i< 100; i++) {
//			byte[] randomBytes = new byte[10];
//			nextBytes(randomBytes);
//			System.out.format("%-5s %s %s %-12s %-20s %s %-25s %s %n", 
//					RandomUtils.getBoolean(),
//					RandomUtils.getInt(0, 10),
//					RandomUtils.getLong(0, 10),
//					RandomUtils.getFloat(0.1f, 9.2f),
//					RandomUtils.getDouble(0.9, 9.2222),
//					nextInt(9),
//					nextGaussian(),
//					org.apache.commons.lang3.ArrayUtils.toString(randomBytes)
//			);
//		}
//	}

}
