package jk.kamoru.flayon.crazy.video.source;

import java.io.File;
import java.util.List;
import java.util.Map;

import org.springframework.util.StopWatch;

import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.Studio;
import jk.kamoru.flayon.crazy.video.domain.TitlePart;
import jk.kamoru.flayon.crazy.video.domain.Video;

public interface VideoSource {

	/**
	 * 전체 Video 맵. &lt;opus, video&gt;
	 * @return map of video
	 */
	Map<String, Video> getVideoMap();
	
	/**
	 * 전체 Studio 맵. &lt;opus, studio&gt;
	 * @return map of studio
	 */
	Map<String, Studio> getStudioMap();
	
	/**
	 * 전체 Actress 맵. &lt;opus, actress&gt;
	 * @return map of actress
	 */
	Map<String, Actress> getActressMap();

	/**
	 * @return total video list
	 */
	List<Video> getVideoList();
	
	/**
	 * @return total studio list
	 */
	List<Studio> getStudioList();

	/**
	 * @return total actress list
	 */
	List<Actress> getActressList();

	
	/**
	 * 비디오 리로드.
	 * @param stopWatch 
	 */
	void reload(StopWatch stopWatch);

	/**
	 * 비디오 리로드.
	 */
	void reload();

	/**
	 * video, studio, actress 제거만 한다.
	 * @param opus
	 */
	void removeElement(String opus);
	
	/**
	 * video file은 지우고, 나머지는 archive로 이동 
	 * @param opus
	 */
	void removeVideo(String opus);

	/**
	 * 모든 파일을 지운다.
	 * @param opus
	 */
	void deleteVideo(String opus);

	/**
	 * video
	 * @param opus
	 * @return
	 */
	Video getVideo(String opus);
	
	/**
	 * studio
	 * @param name
	 * @return
	 */
	Studio getStudio(String name);
	
	/**
	 * actress
	 * @param name
	 * @return
	 */
	Actress getActress(String name);

	/**
	 * move video file to destination path
	 * @param opus
	 * @param destPath
	 */
	void moveVideo(String opus, String destPath);

	/**
	 * arrange video
	 * @param opus
	 */
	void arrangeVideo(String opus);

	/**
	 * add Video
	 * @param video
	 */
	void addVideo(Video video);

	void addFile(File file);
	
	void addTitlePart(TitlePart part);
	
}
