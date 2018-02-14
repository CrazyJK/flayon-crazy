package jk.kamoru.flayon.crazy.video.dao;

import java.util.List;

import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.video.domain.VTag;

public interface TagDao {

	/**
	 * 새 Tag를 저장
	 * @param tag
	 * @return
	 */
	VTag persist(VTag tag);
	
	/**
	 * Id로 Tag를 찾는다.
	 * @param id
	 * @return
	 * @throws CrazyException
	 */
	VTag findById(Integer id) throws CrazyException;
	
	/**
	 * 이름으로 Tag를 찾는다
	 * @param name
	 * @return
	 * @throws CrazyException
	 */
	VTag findByName(String name) throws CrazyException;
	
	/**
	 * 설명으로 Tag를 찾는다
	 * @param desc
	 * @return
	 */
	List<VTag> findByDesc(String desc);
	
	/**
	 * 모든 태그를 구한다
	 * @return
	 */
	List<VTag> findAll();

	/**
	 * 태스 수정
	 * @param tag
	 */
	VTag merge(VTag tag);

	/**
	 * 태그 삭제
	 * @param tag
	 * @return 
	 */
	boolean remove(VTag tag);
	
}
