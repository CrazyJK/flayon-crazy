package jk.kamoru.flayon.crazy.video.dao;

import java.util.List;

import jk.kamoru.flayon.crazy.CrazyException;
import jk.kamoru.flayon.crazy.video.domain.video.Tag;

public interface TagDao {

	/**
	 * 새 Tag를 저장
	 * @param tag
	 * @return
	 */
	Tag persist(Tag tag);
	
	/**
	 * Id로 Tag를 찾는다.
	 * @param id
	 * @return
	 * @throws CrazyException
	 */
	Tag findById(Integer id) throws CrazyException;
	
	/**
	 * 이름으로 Tag를 찾는다
	 * @param name
	 * @return
	 * @throws CrazyException
	 */
	Tag findByName(String name) throws CrazyException;
	
	/**
	 * 설명으로 Tag를 찾는다
	 * @param desc
	 * @return
	 */
	List<Tag> findByDesc(String desc);
	
	/**
	 * 모든 태그를 구한다
	 * @return
	 */
	List<Tag> findAll();

	/**
	 * 태스 수정
	 * @param tag
	 */
	void merge(Tag tag);

	/**
	 * 태그 삭제
	 * @param tag
	 */
	void remove(Tag tag);
	
}
