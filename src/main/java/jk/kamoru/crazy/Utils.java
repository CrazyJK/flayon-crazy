package jk.kamoru.crazy;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;

public class Utils {

	public static String getExtension(File file) {
		isTrue(file != null && file.isFile(), "It is not file! - " + file.getAbsolutePath());
		return StringUtils.substringAfterLast(file.getName(), ".");
	}

	public static void isTrue(boolean expression, String message) {
		if (!expression)
			throw new CrazyException(message);
	}

	/**
	 * 문자열 비교<br> 
	 * null일 경우 ""으로 변환. trim처리 후<br>
	 * {@link String#compareTo(String)} 사용
	 * @param text1
	 * @param text2
	 * @return 비교 결과 
	 */
	public static int compareTo(String text1, String text2) {
		text1 = text1 == null ? "" : text1.trim();
		text2 = text2 == null ? "" : text2.trim();
		return text1.compareTo(text2);
	}

	public static int compareToIgnoreCase(String text1, String text2) {
		text1 = text1 == null ? "" : text1.trim().toLowerCase();
		text2 = text2 == null ? "" : text2.trim().toLowerCase();
		return text1.compareTo(text2);
	}

	/**객체 비교<br>
	 * {@link Object#toString()}으로 변환 후<br>
	 * {@link String#compareTo(String)} 사용
	 * 객체가 null이면 ""으로 처리 
	 * @param obj1
	 * @param obj2
	 * @return 비교 결과
	 */
	public static int compareTo(Object obj1, Object obj2) {
		String str1 = obj1 == null ? "" : obj1.toString();
		String str2 = obj2 == null ? "" : obj2.toString();
		return str1.compareTo(str2);
	}

	/**
	 * properties 형태의 파일을 읽어 Map으로 반환
	 * @see #saveFileFromMap(File, Map)
	 * @param file
	 * @return 파일이 없으면 빈 Map
	 * @throws JKUtilException
	 */
	public static Map<String, String> readFileToMap(File file) {
		isTrue(file != null && file.exists() && file.isFile(), "[readFileToMap] file is not valid");
		try {
			Map<String, String> map = new HashMap<String, String>();
			for (String str : FileUtils.readLines(file, CRAZY.FILE_ENCODING)) {
				String[] strs = StringUtils.split(str, "=", 2);
				if (strs.length > 1)
					map.put(strs[0], strs[1]);
			}
			return map;
		} 
		catch (IOException e) {
			throw new CrazyException("read file error", e);
		}
	}

	public static void renameFile(File srcFile, String newName) {
		try {
			Path target = Paths.get(srcFile.getPath(), newName);
			Files.move(srcFile.toPath(), target, StandardCopyOption.REPLACE_EXISTING);
		} catch (IOException e) {
			throw new CrazyException("file rename fail", e);
		}
	}

	public static String trimToEmpty(Object object) {
		if (object == null) return "";
		return StringUtils.trimToEmpty(object.toString());
	}

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

	/**
	 * 확장자를 뺀 파일 이름
	 * @param file
	 * @return 확장자 없는 파일명
	 */
	public static String getNameExceptExtension(File file) {
		isTrue(file.isFile(), "It is not file! - " + file.getAbsolutePath());
		return StringUtils.substringBeforeLast(file.getName(), ".");
	}

	/**배열의 요소를 ,(comma)로 구분한 문자열 반환
	 * @param array the array to get a toString for, may be null
	 * @return 배열의 문자열 표현
	 */
	public static String toStringComma(Object array) {
		return StringUtils.replaceEach(ArrayUtils.toString(array), new String[] {"{", "}"}, new String[] {"", ""});
	}

	public static File getRootDirectory(File file) {
		return file.toPath().getRoot().toFile();
	}

	public static void exec(String[] command) {
		try {
			Runtime.getRuntime().exec(command);
		} catch (IOException e) {
			throw new CrazyException("execute error", e);
		}
	}

	/**
	 * Map 내용을 file로 저장
	 * @see #readFileToMap(File)
	 * @param file
	 * @param params
	 * @throws JKUtilException
	 */
	public static void saveFileFromMap(File file, Map<String, String> params) {
		if (params == null || params.size() == 0)
			throw new CrazyException("params is null or size 0");
		StringBuffer sb = new StringBuffer();
		for (Map.Entry<String, String> entry : params.entrySet()) {
			sb.append(String.format("%s=%s%n",entry.getKey().toUpperCase().trim(), entry.getValue().trim()));
		}
		try {
			FileUtils.writeStringToFile(file, sb.toString(), CRAZY.FILE_ENCODING);
		} catch (IOException e) {
			throw new CrazyException("write file error", e);
		}
	}

	public static boolean equalsRoot(String path1, String path2) {
		Path root1 = Paths.get(path1).getRoot();
		Path root2 = Paths.get(path2).getRoot();
		return root1.equals(root2);
	}

	public static boolean isEmptyDirectory(File dir) {
		return FileUtils.listFiles(dir, null, true).isEmpty();
	}

	/**
	 * 확장자에 맞는 파일을 찾는다
	 * @param directories 찾을 디렉토리
	 * @param extensions 파일 확장자. null이면 모든 파일
	 * @param recursive 하위폴더 검색 여부
	 * @return
	 */
	public static List<File> listFiles(String[] directories, String[] extensions, boolean recursive) {
		List<File> dirFiles = new ArrayList<File>();
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
		List<File> list = new ArrayList<File>();
		for (File dir : dirFiles)
			if (dir.isDirectory())
				list.addAll(FileUtils.listFiles(dir, extensions, recursive));
			else
				throw new CrazyException(String.format("%s is not directory", dir.getAbsolutePath()));
		return list;
	}

}
