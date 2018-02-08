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

	@Autowired private UserRepository userRepository;
	
	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		
		log.debug("loadUserByUsername [{}]", username);
		
		User found = null;

		List<User> foundUsers = userRepository.findByName(username);
		if (foundUsers.size() == 0) {
			throw new UsernameNotFoundException("User name not found");
		}
		else if (foundUsers.size() == 1) {
			found = foundUsers.get(0);
			log.debug("found {}", found);
		}
		else if (foundUsers.size() > 1) {
			throw new UsernameNotFoundException("User name is 2 over");
		}

		return new FlayOnUser(found);
	}

}
