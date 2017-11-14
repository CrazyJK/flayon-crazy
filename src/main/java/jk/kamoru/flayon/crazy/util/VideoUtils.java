package jk.kamoru.flayon.crazy.util;

import java.io.File;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import org.apache.commons.lang3.StringUtils;

import jk.kamoru.flayon.crazy.video.domain.VTag;
import jk.kamoru.flayon.crazy.video.domain.Video;

/**
 * Video에서 이용되는 utility method 모음
 * @author kamoru
 *
 */
public class VideoUtils {

	/**
	 * 같은 배우 이름인지 확인
	 * <br>대소문자 구분없이 공백을 기준으로 순차 정렬하여 비교.
	 * 
	 * @param name1
	 * @param name2
	 * @return {@code true} if equal
	 */
	public static boolean equalsActress(String name1, String name2) {
		if (name1 == null || name2 == null)
			return false;
		return StringUtils.equalsIgnoreCase(sortForwardName(name1), sortForwardName(name2));
	}

	/**
	 * 배우이름이 포함되어 있는지 검사
	 * @param name1
	 * @param name2
	 * @return 성, 이름을 구분하여 조금이라도 포함되면 {@code true}
	 */
	public static boolean containsActress(String name1, String name2) {
		String[] _name1 = StringUtils.split(name1);
		String[] _name2 = StringUtils.split(name2);
		if (_name1 == null || _name2 == null)
			return false;
		for (String name1a : _name1) {
			for (String name2a : _name2) {
				if (StringUtils.containsIgnoreCase(name1a, name2a))
					return true;
			}
		}
		return false;
	}
	
	/**
	 * 공백기준으로 분리후 순차정렬
	 * @param name
	 * @return
	 */
	public static String sortForwardName(String name) {
		if (name == null)
			return "";
		String[] nameArr = StringUtils.split(name.trim());
		Arrays.sort(nameArr);
		return StringUtils.join(nameArr, " ");
	}

	/**
	 * video list을 opus값 배열 스타일로 반환. ["abs-123", "avs-34"]
	 * @param videoList
	 * @return string of opus list
	 */
	public static String getOpusArrayStyleString(List<Video> videoList) {
		StringBuilder sb = new StringBuilder("[");
		for (int i = 0, iEnd = videoList.size(); i < iEnd; i++) {
			if (i > 0)
				sb.append(",");
			sb.append("\"").append(videoList.get(i).getOpus()).append("\"");
		}
		sb.append("]");
		return sb.toString();
	}

	/**
	 * video list중 video파일이 있는것만 골라 opus값 배열 스타일로 반환. ["abs-123", "avs-34"]
	 * @param videoList
	 * @return string of opus list with file
	 */
	public static String getOpusArrayStyleStringWithVideofile(List<Video> videoList) {
		return getOpusArrayStyleString(videoList.stream().filter(v -> v.isExistVideoFileList()).collect(Collectors.toList()));
	}

	/**
	 * 앞 뒤 공백, [ 제거. null이나 공백이면 "" 리턴
	 * @param str
	 * @return string
	 */
	public static String removeUnnecessaryCharacter(String str) {
		return removeUnnecessaryCharacter(str, "");
	}

	/**
	 * 앞 뒤 공백, [ 제거
	 * @param str
	 * @param defaultString
	 * @return string
	 */
	public static String removeUnnecessaryCharacter(String str, String defaultString) {
		if (str == null || str.trim().length() == 0)
			return defaultString;

		str = str.trim();
		str = str.startsWith("[") ? str.substring(1) : str;
		str = StringUtils.removeEnd(str, ".");
		return str.length() == 0 ? defaultString : str;
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
	 * 문자열 equalsIgnoreCase 비교
	 * <br> compare null is true
	 * <br> compare empty is true
	 * 
	 * @param target
	 * @param compare
	 * @return {@code true} if equals
	 */
	public static boolean equals(String target, String compare) {
		return StringUtils.isBlank(compare) || StringUtils.equalsIgnoreCase(target, compare);
	}

	/**
	 * 문자열 containsIgnoreCase 비교
	 * <br> compare null is true
	 * <br> compare empty is true
	 * 
	 * @param target
	 * @param compare
	 * @return {@code true} if contains
	 */
	public static boolean containsName(String target, String compare) {
		return StringUtils.isBlank(compare) || StringUtils.containsIgnoreCase(target, compare);
	}

	/**
	 * 비디오에 배우가 포함되어 있는지
	 * <br> compare null is true
	 * <br> compare empty is true
	 * 
	 * @param target
	 * @param compare
	 * @return {@code true} if contains
	 */
	public static boolean containsActress(Video target, String compare) {
		return StringUtils.isBlank(compare) || target.containsActress(compare);
	}

	/**
	 * 배우 이름 중 하나라도 비디오에 포함되어 있는지
	 * 
	 * @param video
	 * @param actressNameList
	 * @return {@code true} if contains
	 */
	public static boolean containsActress(Video video, List<String> actressNameList) {
		for (String actress : actressNameList)
			if (containsActress(video, actress))
				return true;
		return false;
	}

	/**
	 * 비디오 현재 폴더에서 릴리즈 날자를 기준으로 yyyy-mm 형식의 하위 폴더를 만든다.
	 * @param video
	 * @return 생성된 폴더 위치
	 */
	public static String makeSubPathByReleaseDate(Video video) {
		if (!StringUtils.isEmpty(video.getReleaseDate())) {
			File subDir = new File(video.getDelegatePathFile(), StringUtils.substring(video.getReleaseDate(), 0, 7).replace(".", "-"));
			if (!subDir.exists()) {
				subDir.mkdir();
			}
			return subDir.getAbsolutePath();
		}
		return video.getDelegatePath();
	}

	/**
	 * 릴리즈 년도를 기준으로 yyyy 형식 하위 폴더를 만든다 
	 * @param video
	 * @return 생성된 폴더 path
	 */
	public static String makeSubPathByReleaseYear(Video video) {
		if (!StringUtils.isEmpty(video.getReleaseDate())) {
			File subDir = new File(video.getDelegatePathFile(), StringUtils.substring(video.getReleaseDate(), 0, 4));
			if (!subDir.exists()) {
				subDir.mkdir();
			}
			return subDir.getAbsolutePath();
		}
		return video.getDelegatePath();
	}

	/**
	 * title(full name)에서 opus를 찾아 반환
	 * @param title
	 * @return
	 */
	public static String findOpusInTitle(String title) {
		String[] split = StringUtils.split(title, "]", 6);
		if (split == null || split.length < 2)
			return "";
		return removeUnnecessaryCharacter(split[1]);
	}

	/**
	 * 공백, nbsp 등등 지우기
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
	 * 공백 구분하여, 첫글자를 대문자로, 뒤는 소문자로
	 * @param actress
	 * @return
	 */
	public static String capitalizeActressName(String actress) {
		String[] array = StringUtils.split(actress);
		if (array != null) {
			actress = "";
			for (String name : array) {
				actress += StringUtils.capitalize(name.toLowerCase()) + " ";
			}
			actress = trimBlank(actress);
		}
		return actress;
	}

	public static String getTagNames(List<VTag> tags) {
		StringBuilder names = new StringBuilder();
		for (VTag tag : tags) {
			names.append(tag.getName()).append(" ");
		}
		return names.toString();
	}
	
}
