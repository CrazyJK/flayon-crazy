package jk.kamoru.flayon.test;

import java.nio.file.Path;

import jk.kamoru.flayon.base.watch.DirectoryWatchServiceAdapter;

public class DirectoryWatchServiceTest extends DirectoryWatchServiceAdapter {

	@Override
	protected String getTaskName() {
		return "Test";
	}

	@Override
	protected String[] getPath() {
		return new String[] {"D:\\kAmOrU\\Shared\\Podcasts"};
	}

	protected void created(Path path) {
		System.out.println("create " + path);
	}
	
	protected void deleted(Path path) {
		System.out.println("deleted " + path);
	}
	
	protected void modified(Path path) {
		System.out.println("modified " + path);
	}

	public static void main(String[] args) {
		DirectoryWatchServiceAdapter dw = new DirectoryWatchServiceTest();
		dw.post();
	}

}
