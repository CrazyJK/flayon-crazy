package jk.kamoru.flayon.crazy.util;

import static java.nio.file.StandardOpenOption.CREATE;
import static java.nio.file.StandardOpenOption.TRUNCATE_EXISTING;
import static java.nio.file.StandardOpenOption.WRITE;

import java.io.File;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.FileAlreadyExistsException;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;

import jk.kamoru.flayon.base.util.IOUtils;
import jk.kamoru.flayon.crazy.error.CrazyException;
import jk.kamoru.flayon.crazy.video.domain.Video;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class CrazyUtils {

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
	public static int compareTo(Date date1, Date date2) {
		if (date1 == null || date2 == null)
			return 0;
		return date1.compareTo(date2);
	}
	public static int compareTo(String str1, String str2) {
		if (str1 == null || str2 == null)
			return 0;
		return str1.compareToIgnoreCase(str2);
	}
	public static int compareTo(long x, long y) {
		return (x < y) ? -1 : ((x == y) ? 0 : 1);
	}
	public static int compareTo(double x, double y) {
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
		try {
			Map<String, String> map = new HashMap<>();
			for (String str : Files.readAllLines(file.toPath())) {
				String[] strs = StringUtils.split(str, "=", 2);
				if (strs.length > 1)
					map.put(StringUtils.stripToEmpty(strs[0]), StringUtils.stripToEmpty(strs[1]));
			}
			return map;
		}
		catch (IOException e) {
			throw new CrazyException("file read error", e);
		}
	}

	/**
	 * 이름 바꾸기
	 * @param srcFile
	 * @param newName 확정자 제외 이름
	 * @return 이미 파일이 있으면, hashcode를 붙여 다시 시도
	 */
	public static Path renameFile(Path srcFile, String newName) {
		String suffix = IOUtils.getSuffix(srcFile.toFile());
		try {
			return Files.move(srcFile, srcFile.resolveSibling(newName + "." + suffix));
		} catch (FileAlreadyExistsException e) {
			return renameFile(srcFile, newName + "_" + srcFile.hashCode());
		} catch (IOException e) {
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
	 * trim한 문자 반환. 
	 * @param str
	 * @param def null이나 공백이면, default 문자 반환
	 * @return
	 */
	public static String trimToDefault(String str, String def) {
		String trim = StringUtils.trimToNull(str);
		return trim == null ? def : trim;
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

		// 파일이 있다면,내용 merge
		if (file.exists()) {
			Map<String, String> readFileToMap = readFileToMap(file);
			for (Entry<String, String> entry : readFileToMap.entrySet()) {
				String oldKey = entry.getKey();
				String oldVal = entry.getValue();
				String newVal = params.get(oldKey);
				
				boolean oldNotBlank = StringUtils.isNotBlank(oldVal);
				boolean newNotBlank = StringUtils.isNotBlank(newVal);
				if (oldNotBlank && !newNotBlank) { // 기존 내용은 있고 새 내용이 없으면, 기존내용을 update 
					params.put(oldKey, oldVal);
				}
			}
		}
		
		List<String> data = new ArrayList<>();
		for (Map.Entry<String, String> entry : params.entrySet()) {
			data.add(String.format("%s=%s", entry.getKey(), entry.getValue().trim()));
		}
		
		try {
			Files.write(file.toPath(), data, StandardCharsets.UTF_8, CREATE, WRITE, TRUNCATE_EXISTING);
		} catch (IOException e) {
			log.error("saveFileFromMap : {}, {}", e.getMessage(), file);
			throw new CrazyException("write file error", e);
		}
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

	public static URL makeURL(String string) {
		String str = StringUtils.trimToEmpty(string);
		if (StringUtils.isNotEmpty(str))
			if (!str.startsWith("http"))
				str = "http://" + str;
		try {
			return new URL(str);
		} catch (MalformedURLException e) {
			if (log.isDebugEnabled() && StringUtils.isNotEmpty(str))
				log.warn("Malformed URL {}", e.getMessage());
			return null;
		}
	}

	/**
	 * list를 컴마(,)로 구분한 string반환
	 * @param list
	 * @return string of list
	 */
	public static <T> String listToSimpleString(List<T> list) {
		StringBuilder sb = new StringBuilder();
		for (int i = 0, e = list.size(); i < e; i++) {
			T object = list.get(i);
			if (i > 0)
				sb.append(", ");
			sb.append(object);
		}
		return sb.toString();
	}

	/**
	 * file list를 컴마(,)로 구분한 string으로 반환
	 * @param list
	 * @return string of list
	 */
	public static String listFileToSimpleString(List<File> list) {
		StringBuilder sb = new StringBuilder();
		for (int i = 0, e = list.size(); i < e; i++) {
			File file = list.get(i);
			if (i > 0)
				sb.append(", ");
			sb.append(file.getAbsolutePath());
		}
		return sb.toString();
	}

	/**
	 * 전체 단어의 첫글자를 대문자로 바꾼다
	 * @param str
	 * @return ex. abc qwe => Abc Qwe
	 */
	public static String capitalize(String str) {
		String result = "";
		for (String s : StringUtils.split(str)) {
			result += StringUtils.capitalize(s.toLowerCase()) + " ";
		}
		return result.trim();
	}

	public static boolean containsAny(String str, String...searches) {
		for (String search : searches) {
			if (StringUtils.containsIgnoreCase(str, search))
				return true;
		}
		return false;
	}
	
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
//			dir.toFile().delete();
			try {
				FileUtils.deleteDirectory(dir.toFile());
//				Files.delete(dir);
				log.info("empty directory deleted {}", dir);
			} catch (IOException e) {
				throw new CrazyException("deleteEmptyFolder delete fail", e);
			}
		}
	}

	public static File renameFile(File file, String newName) {
		return IOUtils.renameFile(file, newName, true);
	}

	/**
	 * 공백 등등 지우기
	 * replace regex로는 뭘 지우는지 모르겟다.
	 * @param text
	 * @return
	 */
	public static String trimBlank(String text) {
		return trimWhitespace(text).replaceAll("(^\\p{Z}+|\\p{Z}+$)", "");
	}

	/**
	 * Trim leading and trailing whitespace from the given {@code String}.
	 * @param str the {@code String} to check
	 * @return the trimmed {@code String}
	 * @see java.lang.Character#isWhitespace
	 */
	public static String trimWhitespace(String str) {
		if (str == null || str.trim().length() == 0) {
			return "";
		}
		StringBuilder sb = new StringBuilder(str);
		while (sb.length() > 0 && Character.isWhitespace(sb.charAt(0))) {
			sb.deleteCharAt(0);
		}
		while (sb.length() > 0 && Character.isWhitespace(sb.charAt(sb.length() - 1))) {
			sb.deleteCharAt(sb.length() - 1);
		}
		return sb.toString();
	}

	/**
	 * 유니코드 u00A0 NBSP공백을 일반 공백u0020 으로 교체
	 * @param str
	 * @return
	 */
	public static String replaceNBSP(String str) {
		StringBuilder sb = new StringBuilder(str);
		for (int i=0; i<sb.length(); i++) {
			if (160 == (int)sb.charAt(i)) {
				sb.deleteCharAt(i);
				sb.insert(i, (char)32);
			}
		}
		return sb.toString();
	}

}
