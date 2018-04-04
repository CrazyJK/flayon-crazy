package jk.kamoru.flayon.crazy.video.dao;

import java.util.List;
import java.util.Map;

import jk.kamoru.flayon.base.util.StopWatch;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.Studio;
import jk.kamoru.flayon.crazy.video.domain.TitleValidator;
import jk.kamoru.flayon.crazy.video.domain.Video;

/**
 * Video DAO
 * @author kamoru
 */
public interface VideoDao {

	// --- getter for Instance source --------------------------------------
	
	/**
	 * @return total video list
	 */
	List<Video> getVideoList(Boolean instance, Boolean archive);
	
	/**
	 * @return total studio list
	 */
	List<Studio> getStudioList(Boolean instance, Boolean archive);

	/**
	 * @return total actress list
	 */
	List<Actress> getActressList(Boolean instance, Boolean archive);

	/**
	 * video by opus
	 * @param opus
	 * @return video
	 */
	Video getVideo(String opus);
	
	/**
	 * studio by studio name
	 * @param name studio name
	 * @return studio
	 */
	Studio getStudio(String name);
	
	/**
	 * actress by actress name
	 * @param name actress name
	 * @return actress
	 */
	Actress getActress(String name);

	/**
	 * whether opus contains at source 
	 * @param opus
	 * @return
	 */
	boolean contains(String opus, Boolean instance, Boolean archive);

	// --- getter for Archive source --------------------------------------
	
	/**
	 * archive video list
	 * @return video list
	 */
//	List<Video> getArchiveVideoList();

	/**
	 * archive actress list
	 * @return
	 */
//	List<Actress> getArchiveActressList();

	/**
	 * archive studio list
	 * @return
	 */
//	List<Studio> getArchiveStudioList();

	/**
	 * archive video by opus
	 * @param opus
	 * @return
	 */
//	Video getArchiveVideo(String opus);

	// --- source reload --------------------------------------
	
	/**
	 * reload instance videosource
	 * @param stopWatch 
	 */
	void reload(StopWatch stopWatch, Boolean instance, Boolean archive);

	/**
	 * reload instance videosource
	 */
//	void reload(Boolean instance, Boolean archive);

	/**
	 * reload archive videosource
	 */
//	void reloadArchive();

	// --- action method -----------------------------
	
	/**
	 * arrange video
	 * @param opus
	 */
	void arrangeVideo(String opus);
	
	/**
	 * remove video
	 * @param opus
	 */
	void removeVideo(String opus);

	/**
	 * delete video
	 * @param opus
	 */
	void deleteVideo(String opus);

	/**
	 * move video
	 * @param opus
	 * @param destPath destination path
	 */
	void moveVideo(String opus, String destPath);
	
	/**
	 * rename video domain
	 * @param opus
	 * @param newName
	 */
	void renameVideo(String opus, String newName);

	/**
	 * build Video domain
	 * @param titlePart
	 * @param cOVER_PATH
	 */
	void buildVideo(TitleValidator titlePart);

	/**
	 * move to instance source
	 * @param opus
	 */
	void moveToInstance(String opus);
	
	/**
	 * rename Studio
	 * @param data
	 * @return 
	 */
	Studio renameStudio(Map<String, String> data);
	
	/**
	 * rename Actress
	 * @param data
	 * @return 
	 */
	Actress renameActress(Map<String, String> data);
	
}
