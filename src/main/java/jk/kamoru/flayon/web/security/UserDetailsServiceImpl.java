package jk.kamoru.flayon.web.security;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class UserDetailsServiceImpl implements UserDetailsService {

	@Autowired
	private UserRepository userRepository;

	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		List<User> foundUsers = userRepository.findByName(username);
		log.debug("loadUserByUsername [{}] {} found", username, foundUsers.size());
		
		if (foundUsers.size() == 0) {
			log.warn("User name not found");
			throw new UsernameNotFoundException("User name not found");
		} else if (foundUsers.size() == 1) {
			return foundUsers.get(0);
		} else { // size > 1
			log.warn("User name is 2 over");
			throw new UsernameNotFoundException("User name is 2 over");
		}
	}

}
