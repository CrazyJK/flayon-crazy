package jk.kamoru.flayon.crazy.video.domain;

import java.io.Serializable;
import java.util.List;

import jk.kamoru.flayon.crazy.video.VIDEO;
import lombok.Data;

/**
 * 비디오 검색 form bean
 * @author kamoru
 */
@Data
public class VideoSearch implements Serializable {

	private static final long serialVersionUID = VIDEO.SERIAL_VERSION_UID;

	/**
	 * 검색조건 : 검색어
	 */
	String searchText;
//	/**
//	 * 검색조건 : 추가 여부. 조건 {@link #existVideo}, {@link #existSubtitles}
//	 */
//	boolean addCond = false;
	/**
	 * 검색조건 : 비디오 존재
	 */
	boolean existVideo = true;
	/**
	 * 검색조건 : 비디오 & 자막 존재
	 */
	boolean existSubtitles = true;
	/**
	 * 검색조건 : 커버 존재
	 */
	boolean existCover = false;
	/**
	 * 검색조건 : favorite 비디오
	 */
	boolean favorite = false;
	/**
	 * 검색조건 : 랭킹 범위
	 */
	List<Integer> rankRange;
	/**
	 * 검색조건 : 플레이 횟수 
	 */
	Integer playCount = 0;

	/**
	 * View type
	 */
	View listViewType = View.F;
	/**
	 * 정렬 방법 
	 */
	Sort sortMethod = Sort.O;
	/**
	 * 역정렬 여부
	 */
	boolean sortReverse = false;

	/**
	 * 검색조건 : 선택된 스튜디오
	 */
	List<String> selectedStudio;
	/**
	 * 검색조건 : 선택된 배우
	 */
	List<String> selectedActress;
	/**
	 * 검색조건 : 선택된 Tag
	 */
	List<String> selectedTag;

	/**
	 * 스튜디오 화면 볼지 여부
	 */
	boolean viewStudioDiv = false;
	/**
	 * 여배우 화면 볼지 여부
	 */
	boolean viewActressDiv = false;
	/**
	 * Tag 화면 볼지 여부
	 */
	boolean viewTagDiv = false;

	/**
	 * 전체 배우,스튜디오 목록을 볼지 여부 
	 */
	boolean wholeActressStudioView = true;
	
	/* Not use
	boolean neverPlay = false;
	boolean oldVideo = false;
	String studio;
	String title;
	String opus;
	String actress;
	InequalitySign rankSign = InequalitySign.gt;
	boolean zeroRank = false;
	Integer rank = -2;
	*/

}
