package jk.kamoru.flayon.test;

import java.nio.file.Path;
import java.nio.file.Paths;

public class FilesWalkTest {

	static Path path = Paths.get("/home/kamoru/workspace/FlayOn/crazy/Seeds/Queue");

	public static void nameCount() {
		System.out.println(path.getNameCount());
		System.out.println(path.getName(0));
	}
	
	public static void empty() {
		
	}
	
	public static void main(String[] args) {
	}
}
