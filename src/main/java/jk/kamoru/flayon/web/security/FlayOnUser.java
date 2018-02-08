package jk.kamoru.flayon.base.security;

import java.util.Arrays;

import org.springframework.security.core.authority.SimpleGrantedAuthority;

import jk.kamoru.flayon.FLAYON;

public class FlayOnUser extends org.springframework.security.core.userdetails.User {

	private static final long serialVersionUID = FLAYON.SERIAL_VERSION_UID;

	private User user;

	public FlayOnUser(User user) {
		super(user.getName(), user.getPassword(), Arrays.asList(new SimpleGrantedAuthority(user.getRole())));
		this.user = user;
	}
	
	public User getUser() {
		return user;
	}

}
