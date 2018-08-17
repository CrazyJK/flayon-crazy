package jk.kamoru.flayon.base.util;

import java.io.File;
import java.io.IOException;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;

import jk.kamoru.flayon.FLAYON;
import jk.kamoru.flayon.crazy.CrazyException;

public class IOUtils {
	
	static DecimalFormat decimalFormatter = new DecimalFormat("#,###.#");

	static final String ILLEGAL_EXP = "[:\\\\/%*?:|\"<>]";

	public static String getValidFileName(String fileName, String replaceStr) {
		if (fileName == null || fileName.trim().length() == 0)
			return String.valueOf(System.currentTimeMillis());
		if (replaceStr == null || replaceStr.trim().length() == 0)
			replaceStr = "";
		return fileName.replaceAll(ILLEGAL_EXP, replaceStr);
	}
	
	/**
	 * 파일 크기를 보기 좋은 형식으로
	 * @param file
	 * @return ex. 11.3 TB, 115.5 GB, 11.8 MB, 12.1 kB, 123 bytes
	 */
	public static String toPrettyFileLength(File file) {
		long length = file.length();
		if (length > FileUtils.ONE_TB)
			return decimalFormatter.format((double) length / FileUtils.ONE_TB) + " TB";
		else if (length > FileUtils.ONE_GB)
			return decimalFormatter.format((double) length / FileUtils.ONE_GB) + " GB";
		else if (length > FileUtils.ONE_MB)
			return decimalFormatter.format((double) length / FileUtils.ONE_MB) + " MB";
		else if (length > FileUtils.ONE_KB)
			return decimalFormatter.format((double) length / FileUtils.ONE_KB) + " kB";
		else
			return length + " bytes";
	}

	/**
	 * 파일 이름 바꾸기
	 * @param srcFile
	 * @param newName 새 파일 이름
	 * @param suffixProtect true면 확장자 유지
	 * @return
	 */
	public static File renameFile(File srcFile, String newName, boolean suffixProtect) {
		if (suffixProtect) {
			String suffix = getSuffix(srcFile);
			if (StringUtils.isNotEmpty(suffix))
				newName = newName + "." + suffix;
		}
		return renameFile(srcFile, newName);
	}

	/**
	 * 파일이름 바꾸기<br>
	 * 확장자 포함 전체 이름이 바뀐다
	 * @param srcFile
	 * @param newName 새 파일 이름 
	 * @return
	 */
	public static File renameFile(File srcFile, String newName) {
		File destFile = new File(srcFile.getParent(), newName);
		if (srcFile.renameTo(destFile))
			return destFile;
		else
			throw new CrazyException("file rename fail: " + srcFile.getAbsolutePath());
	}

	/**
	 * 확장자를 뺀 파일 이름
	 * @param file
	 * @return 확장자 없는 파일명
	 */
	public static String getPrefix(File file) {
		return StringUtils.substringBeforeLast(file.getName(), ".");
	}

	/**
	 * 파일 확장자 구하기
	 * @param file
	 * @return 확장자. 없으면 공백
	 */
	public static String getSuffix(File file) {
		return StringUtils.substringAfterLast(file.getName(), ".");
	}

	/**
	 * root 구한다.
	 * @param file
	 * @return
	 */
	public static File getRoot(File file) {
		return file.toPath().getRoot().toFile();
	}

	/**
	 * 같은 root인지 확인
	 * @param path1
	 * @param path2
	 * @return
	 */
	public static boolean equalsRoot(String path1, String path2) {
		Path root1 = Paths.get(path1).getRoot();
		Path root2 = Paths.get(path2).getRoot();
		return root1.equals(root2);
	}

	/**
	 * 빈 폴더인지 확인
	 * @param dir
	 * @return
	 */
	public static boolean isEmptyDirectory(File dir) {
		return FileUtils.listFiles(dir, null, false).isEmpty();
	}

	/**
	 * 확장자에 맞는 파일을 찾는다
	 * @param directories 찾을 디렉토리
	 * @param extensions 파일 확장자. null이면 모든 파일
	 * @param recursive 하위폴더 검색 여부
	 * @return
	 */
	public static List<File> listFiles(String[] directories, String[] extensions, boolean recursive) {
		List<File> dirFiles = new ArrayList<>();
		for (String directory : directories)
			dirFiles.add(new File(directory));
		return listFiles(dirFiles, extensions, recursive);
	}

	/**
	 * 확장자에 맞는 파일을 찾는다
	 * @param dirFiles 찾을 폴더
	 * @param extensions 파일 확장자. null이면 모든 파일
	 * @param recursive 하위폴더 검색 여부
	 * @return
	 */
	public static List<File> listFiles(List<File> dirFiles, String[] extensions, boolean recursive) {
		List<File> list = new ArrayList<>();
		for (File dir : dirFiles)
			if (dir.isDirectory())
				if (FLAYON.JAVA_VERSION.equals("1.8"))
					list.addAll(listPath(dir.toPath(), extensions));
				else
					list.addAll(FileUtils.listFiles(dir, extensions, recursive));
		return list;
	}

	private static List<File> listPath(Path start, String... suffixs) {
		List<File> pathList = new ArrayList<>();
		try {
			boolean isSuffixEmpty = suffixs == null || suffixs.length == 0;
			Files.walkFileTree(start, new SimpleFileVisitor<Path>() {

				@Override
				public FileVisitResult visitFile(Path fileEntry, BasicFileAttributes attrs) throws IOException {
					if (attrs.isRegularFile()) {
						File file = fileEntry.toFile();
						if (isSuffixEmpty || StringUtils.endsWithAny(file.getName(), suffixs)) {
							pathList.add(file);
						}
					}
					return FileVisitResult.CONTINUE;
				}
				
			});
			return pathList;
		} catch (IOException e) {
			throw new CrazyException("walk file tree error", e);
		}
	}

	/**
	 * 파일이름으로 쓸수 없는 문자 제거
	 * @param name
	 * @return
	 */
	public static String removeInvalidFilename(String name) {
		name = StringUtils.remove(name, '\\');
		name = StringUtils.remove(name, '/');
		name = StringUtils.remove(name, ':');
		name = StringUtils.remove(name, '*');
		name = StringUtils.remove(name, '?');
		name = StringUtils.remove(name, '"');
		name = StringUtils.remove(name, '<');
		name = StringUtils.remove(name, '>');
		name = StringUtils.remove(name, '|');
		return name;
	}

}
