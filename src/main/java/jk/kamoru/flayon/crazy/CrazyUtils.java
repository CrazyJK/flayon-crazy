package jk.kamoru.flayon.crazy;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.StandardCopyOption;
import java.nio.file.attribute.BasicFileAttributes;

import static java.nio.file.StandardOpenOption.*;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.lang.UsesJava8;

import jk.kamoru.flayon.FLAYON;
import jk.kamoru.flayon.crazy.error.CrazyException;
import jk.kamoru.flayon.crazy.video.domain.Video;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class CrazyUtils extends jk.kamoru.flayon.base.BaseUtils {

	/**
	 * 파일의 확장자를 구한다.
	 * @param file
	 * @return
	 */
	public static String getExtension(File file) {
		isTrue(file != null && file.isFile(), "It is not file! - " + file.getAbsolutePath());
		return StringUtils.substringAfterLast(file.getName(), ".");
	}

	/**
	 * 조건이 <code>true</code>인지 판별한다.
	 * @param expression
	 * @param message
	 */
	public static void isTrue(boolean expression, String message) {
		if (!expression)
			throw new CrazyException(message);
	}

	/**
	 * 객체 비교<br>
	 * {@link Object#toString()}으로 변환 후<br>
	 * {@link String#compareTo(String)} 사용
	 * 객체가 null이면 ""으로 처리 
	 * @param obj1
	 * @param obj2
	 * @return 비교 결과
	 */
	public static int compareTo(Object obj1, Object obj2) {
		if (obj1 == null || obj2 == null)
			return 0;
		return obj1.toString().compareToIgnoreCase(obj2.toString());
	}
	public static int compareTo(String str1, String str2) {
		if (str1 == null || str2 == null)
			return 0;
		return str1.compareToIgnoreCase(str2);
	}
	public static int compareTo(long x, long y) {
		return (x < y) ? -1 : ((x == y) ? 0 : 1);
	}
	public static int compareTo(int x, int y) {
		return (x < y) ? -1 : ((x == y) ? 0 : 1);
	}
	
	
	/**
	 * properties 형태의 파일을 읽어 Map으로 반환
	 * @see #saveFileFromMap(File, Map)
	 * @param file
	 * @return 파일이 없으면 빈 Map
	 */
	public static Map<String, String> readFileToMap(File file) {
		Map<String, String> map = new HashMap<>();
		try {
			for (String str : Files.readAllLines(file.toPath())) {
				String[] strs = StringUtils.split(str, "=", 2);
				if (strs.length > 1)
					map.put(strs[0], strs[1]);
			}
		} 
		catch (IOException e) {
			throw new CrazyException("file read error", e);
		}
		return map;
	}

	/**
	 * 파일명 바꾸기.<br>
	 * 원 파일의 확장자를 구해 자동으로 붙여 준다
	 * @param srcFile
	 * @param newName   확장자 제외 이름만 
	 * @throws 실패시 에러
	 */
	public static File renameFile(File srcFile, String newName) {
		try {
			String suffix = getExtension(srcFile);
			if (StringUtils.isNotEmpty(suffix))
				newName = newName + "." + suffix;
			log.debug("rename {} {} -> {}", suffix, srcFile.getAbsolutePath(), newName);
			return Files.move(srcFile.toPath(), Paths.get(srcFile.getParent(), newName), StandardCopyOption.REPLACE_EXISTING).toFile();
		} catch (IOException e) {
			log.error("rename fail", e);
			throw new CrazyException("file rename fail", e);
		}
	}

	/**
	 * null 이나 공백 제거
	 * @param object
	 * @return
	 */
	public static String trimToEmpty(Object object) {
		if (object == null) return "";
		return StringUtils.trimToEmpty(object.toString());
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

	/**
	 * 확장자를 뺀 파일 이름
	 * @param file
	 * @return 확장자 없는 파일명
	 */
	public static String getNameExceptExtension(File file) {
		isTrue(file.isFile(), "It is not file! - " + file.getAbsolutePath());
		return StringUtils.substringBeforeLast(file.getName(), ".");
	}

	/**
	 * 배열의 요소를 ,(comma)로 구분한 문자열 반환
	 * @param array the array to get a toString for, may be null
	 * @return 배열의 문자열 표현
	 */
	public static String toStringComma(Object array) {
		return StringUtils.replaceEach(ArrayUtils.toString(array), new String[] {"{", "}"}, new String[] {"", ""});
	}

	/**
	 * root 구한다.
	 * @param file
	 * @return
	 */
	public static File getRootDirectory(File file) {
		return file.toPath().getRoot().toFile();
	}

	/**
	 * 외부 프로그램 실행
	 * @param command
	 */
	public static void exec(String[] command) {
		try {
			Runtime.getRuntime().exec(command);
		} catch (IOException e) {
			throw new CrazyException("execute error", e);
		}
	}

	/**
	 * Map 내용을 file로 저장
	 * @param file
	 * @param params
	 * @throws JKUtilException
	 * 
	 * @see #readFileToMap(File)
	 */
	public static void saveFileFromMap(File file, Map<String, String> params) {
		if (params == null || params.size() == 0)
			throw new CrazyException("params is null or size 0");
		List<String> data = new ArrayList<>();
		for (Map.Entry<String, String> entry : params.entrySet()) {
			data.add(String.format("%s=%s",entry.getKey().toUpperCase().trim(), entry.getValue().trim()));
		}
		try {
			Files.write(file.toPath(), data, StandardCharsets.UTF_8, CREATE, WRITE);
		} catch (IOException e) {
			log.error("write file error", e);
			throw new CrazyException("write file error", e);
		}
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
		isTrue(dir != null && dir.isDirectory(), "It is not a directory. " + dir);
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

	@UsesJava8
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
	 * 배열을 합친다.
	 * @param arr1
	 * @param arr2
	 * @return
	 */
	public static String[] merge(String[] arr1, String[] arr2) {
		String[] dst = new String[arr1.length + arr2.length];
		System.arraycopy(arr1, 0, dst, 0, arr1.length);
		System.arraycopy(arr2, 0, dst, arr1.length, arr2.length);
		return dst;
	}

	/**
	 * view에서 사용<br>
	 * list의 video 파일 크기의 합을 구함
	 * @param videoList
	 * @return
	 */
	public static long sumOfVideoList(List<Video> videoList) {
		long sum = 0;
		for (Video video : videoList)
			sum += video.getLength();
		return sum;
	}
	
	static DecimalFormat decimalFormatter = new DecimalFormat("#,###.# GB");

	/**
	 * view에서 사용<br>
	 * GB 사이즈로 표현
	 * @param length
	 * @return
	 */
	public static String toGBSize(long length) {
		return decimalFormatter.format((double)length / FileUtils.ONE_GB);
	}

	/**
	 * view에서 사용<br>
	 * size별 css class로 표현
	 * @param itemCssClass
	 * @param size
	 * @return
	 */
	public static String getCssClassNameByItemCount(String itemCssClass, int size) {
		if (size >= 100)
			itemCssClass += "100";
		else if (size >= 50)
			itemCssClass += "50";
		else if (size >= 30)
			itemCssClass += "30";
		else if (size >= 10)
			itemCssClass += "10";
		else if (size >= 5)
			itemCssClass += "5";
		else
			itemCssClass += "1";
		return itemCssClass;
	}
	
	/**
	 * trim한 문자 반환. 
	 * @param str
	 * @param def null이나 공백이면, default 문자 반환
	 * @return
	 */
	public static String trimToDefault(String str, String def) {
		String _str = StringUtils.trimToNull(str);
		return _str == null ? def : _str;
	}
	
}
