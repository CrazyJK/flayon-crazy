package jk.kamoru.flayon.crazy.video.domain;

import java.io.Serializable;
import java.util.Arrays;
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

	/** 검색조건 : 검색어 */				String searchText;
	/** 검색조건 : 비디오 존재 */			boolean existVideo = true;
	/** 검색조건 : 비디오 & 자막 존재 */	boolean existSubtitles = true;
	/** 검색조건 : 커버 존재 */				boolean existCover = false;
	/** 검색조건 : favorite 비디오 */		boolean favorite = false;
	/** 검색조건 : 랭킹 범위 */				List<Integer> rankRange = Arrays.asList(0);
	/** 검색조건 : 플레이 횟수 */			Integer playCount = -1;
	/** 검색조건 : 선택된 Tag */ 			List<String> selectedTag;
	
	/** List view type */					View listViewType = View.Flay;
	
	/** 정렬 방법 */						Sort sortMethod = Sort.Modified;
	/** 정렬 역정렬 여부 */					boolean sortReverse = false;

	/** Tag 화면 볼지 여부 */				boolean viewTagDiv = false;

}
