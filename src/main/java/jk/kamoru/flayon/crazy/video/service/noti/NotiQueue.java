package jk.kamoru.flayon.crazy.video.service.noti;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import lombok.extern.slf4j.Slf4j;
import net.sf.ehcache.util.concurrent.ConcurrentHashMap;

@Slf4j
public class NotiQueue {

	private static final long TIME_OFFSET = 5000l;
	
	private static List<Noti> notiList = new ArrayList<>();
	private static Map<Long, AtomicInteger> indexMapByUserid = new ConcurrentHashMap<>();
	
	public static void push(String message) {
		Noti noti = new Noti(System.currentTimeMillis(), message);
		notiList.add(noti);
		log.info("push Noti : {}th {}", notiList.size(), noti);
	}
	
	public static Noti pull(Long userid) {
		indexMapByUserid.putIfAbsent(userid, new AtomicInteger(0));
		AtomicInteger currNotiIndex = indexMapByUserid.get(userid);
		
		if (notiList.size() > currNotiIndex.get()) {
			Noti noti = notiList.get(currNotiIndex.getAndIncrement());

			// past 5s      > 53000                      - 51000 = 2000
			if (TIME_OFFSET > System.currentTimeMillis() - noti.getTime()) { // in OFFSET time
				log.info("pull Noti : userid {}, {}th [{}]", userid, currNotiIndex, noti.getMessage());
				return noti;
			}
			else { // past
				return pull(userid);
			}
		}
		else { // have no Noti 
			return new Noti();
		}
	}

}

