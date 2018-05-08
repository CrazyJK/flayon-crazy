package jk.kamoru.flayon.crazy.util;

import java.io.File;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

import org.apache.commons.lang3.StringUtils;

import jk.kamoru.flayon.crazy.video.VIDEO;
import jk.kamoru.flayon.crazy.video.domain.Sort;
import jk.kamoru.flayon.crazy.video.domain.Video;

/**
 * Video에서 이용되는 utility method 모음
 * @author kamoru
 *
 */
public class VideoUtils {

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
	 * @return string of opus list if file exist
	 */
	public static String getOpusArrayStyleStringIfVideofile(List<Video> videoList) {
		return getOpusArrayStyleString(videoList.stream().filter(v -> v.isExistVideoFileList()).collect(Collectors.toList()));
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
	
	public static int compareVideo(Video v1, Video v2, Sort sort, boolean reverse) {
		int result = 0;
		switch(sort) {
		case S:
			result = CrazyUtils.compareTo(v1.getStudio().getName(), v2.getStudio().getName());
			break;
		case O:
			result = CrazyUtils.compareTo(v1.getOpus(), v2.getOpus());
			break;
		case T:
			result = CrazyUtils.compareTo(v1.getTitle(), v2.getTitle());
			break;
		case A:
			result = CrazyUtils.compareTo(v1.getActressName(), v2.getActressName());
			break;
		case D:
			result = compareToRelease(v1.getReleaseDate(), v2.getReleaseDate());
			break;
		case M:
			result = CrazyUtils.compareTo(v1.getDelegateFile().lastModified(), v2.getDelegateFile().lastModified());
			break;
		case P:
			result = CrazyUtils.compareTo(v1.getPlayCount().intValue(), v2.getPlayCount().intValue());
			break;
		case R:
			result = CrazyUtils.compareTo(v1.getRank(), v2.getRank());
			break;
		case L:
			result = CrazyUtils.compareTo(v1.getLength(), v2.getLength());
			break;
		case SC:
			result = CrazyUtils.compareTo(v1.getScore(), v2.getScore());
			break;
		case VC:
			if (v1.getVideoCandidates().size() > 0) {
				if (v2.getVideoCandidates().size() == 0) {
					result = -1;
				}
			}
			else {
				if (v2.getVideoCandidates().size() > 0) {
					result = 1;
				}
			}
			result = CrazyUtils.compareTo(v1.getStudio().getName(), v2.getStudio().getName());
			break;
		default:
			result = CrazyUtils.compareTo(v1, v2);
		}
		return result * (reverse ? -1 : 1);
	}

	public static int compareToRelease(String release1, String release2) {
		return CrazyUtils.compareTo(parseReleaseDate(release1), parseReleaseDate(release2));
	}

	public static Date parseReleaseDate(String source) {
		try {
			return VIDEO.ReleaseDateFotmat.parse(source);
		} catch (ParseException e) {
			return null;
		}
	}
	
	public static List<Integer> getPlayRange(List<Video> videoList) {
		List<Integer> range = new ArrayList<>();
		range.add(new Integer(-1));
		for (Video video : videoList) {
			Integer count = video.getPlayCount();
			if (!range.contains(count))
				range.add(count);
		}
		return range.stream().sorted().collect(Collectors.toList());
	}

}
