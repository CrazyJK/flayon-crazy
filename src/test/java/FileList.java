import java.io.File;
import java.util.Collection;

import jk.kamoru.flayon.crazy.Utils;

public class FileList {

	public static void main(String[] args) {
		
		String[] paths = {"C:\\Crazy\\Storage", "C:\\Crazy\\Cover", "C:\\Crazy\\Archive", "C:\\Crazy\\Stage", "C:\\Crazy\\Stage2"};
		
		Collection<File> files = Utils.listFiles(paths, null, true);
		for (File file : files) {
			System.out.format("%s%n", file);
		}
	}

}
