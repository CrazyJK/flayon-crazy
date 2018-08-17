package jk.kamoru.flayon.web.security;

import javax.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class UserDataLoader {

	@Autowired private UserRepository userRepository;

	@PostConstruct
	public void loadInitData() {
		
		User admin = new User();
		admin.setName("admin");
		admin.setPassword("{noop}6969");
		admin.setRole(Role.ADMIN);
		userRepository.save(admin);

		User kamoru = new User();
		kamoru.setName("kamoru");
		kamoru.setPassword("{noop}crazyjk");
		kamoru.setRole(Role.USER);
		userRepository.save(kamoru);
	}
}
