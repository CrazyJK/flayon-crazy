package jk.kamoru.flayon.base.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class UserDataLoader {

	@Autowired private UserRepository userRepository;

	public void loadInitData() {
		User user = new User();
		user.setName("kamoru");
		user.setPassword("crazyjk");
		user.setRole("USER");
		userRepository.save(user);
	}
}
