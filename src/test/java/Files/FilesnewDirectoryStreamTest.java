package Files;

import java.io.IOException;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.List;

import jk.kamoru.flayon.crazy.error.CrazyException;

public class FilesnewDirectoryStreamTest {

	public static synchronized void deleteEmptyDirectory(String... dirs) {
		List<Path> paths = new ArrayList<>();
		for (String dir : dirs) {
			try {
				Path start = Paths.get(dir);
				Files.walkFileTree(start, new SimpleFileVisitor<Path>() {
					@Override
					public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs) throws IOException {
						if (!start.equals(dir) 
								&& !Files.newDirectoryStream(dir).iterator().hasNext()) {
							paths.add(dir);
						}
						return super.preVisitDirectory(dir, attrs);
					}});
			} catch (IOException e) {
				throw new CrazyException("deleteEmptyFolder walk fail", e);
			}
		}
		for (Path dir : paths) {
//			try {
//				Files.delete(dir);
				System.out.format("empty directory deleted %s%n", dir);
//			} catch (IOException e) {
//				throw new CrazyException("deleteEmptyFolder delete fail", e);
//			}
		}
	}
	
	public static void main(String[] args) throws IOException {
		String pathStr = "F:\\Crazy";
		deleteEmptyDirectory(pathStr);
	}

}
