package jk.kamoru.flayon.crazy.video.service.noti;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class NotiQueue {

	private static final long TIME_OFFSET = 5000l;
	
	@Autowired NotiRepository notiRepository;
	
	private List<Noti> notiList = new ArrayList<>();
	private Map<Long, AtomicInteger> indexMapByUserid = new ConcurrentHashMap<>();
	
	public void push(String message) {
		Noti noti = new Noti(new Date(), message);
		notiList.add(noti);
		notiRepository.save(noti);
		log.info("push Noti : {}th {}", notiList.size(), noti);
	}
	
	public Noti pull(Long userid) {
		indexMapByUserid.putIfAbsent(userid, new AtomicInteger(0));
		AtomicInteger currNotiIndex = indexMapByUserid.get(userid);
		
		if (notiList.size() > currNotiIndex.get()) {
			Noti noti = notiList.get(currNotiIndex.getAndIncrement());

			// past 5s      > 53000                      - 51000 = 2000
			if (TIME_OFFSET > System.currentTimeMillis() - noti.getDate().getTime()) { // in OFFSET time
				log.info("pull Noti : userid {}, {}th [{}]", userid, currNotiIndex, noti.getMessage());
				return noti;
			}
			else { // past
				return pull(userid);
			}
		}
		else { // have no Noti 
			return null;
		}
	}

	public List<Noti> getNotiList() {
		return notiList;
	}
}

