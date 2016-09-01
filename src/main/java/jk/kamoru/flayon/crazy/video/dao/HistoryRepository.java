package jk.kamoru.flayon.crazy.video.dao;

import org.springframework.data.jpa.repository.JpaRepository;

import jk.kamoru.flayon.crazy.video.domain.History;

public interface HistoryRepository extends JpaRepository<History, Long> {

}
