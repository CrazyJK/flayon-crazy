package jk.kamoru.flayon.base.access;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;

public interface AccessLogRepository extends MongoRepository<AccessLog, String> {

	Page<AccessLog> findByRemoteAddrLike(String remoteAddr, Pageable pageable);
	
	Page<AccessLog> findByRequestURILike(String requestURI, Pageable pageable);

	Page<AccessLog> findByRequestURILikeOrRemoteAddrLike(String requestURI, String remoteAddr, Pageable pageable);

	Page<AccessLog> findByRequestURILikeAndRemoteAddrLike(String requestURI, String remoteAddr, Pageable pageable);

	Page<AccessLog> findByRequestURIOrRemoteAddr(String requestURI, String remoteAddr, Pageable pageable);

}
