## GitNub
A RubyCocoa app for getting quick information for a git repo.  Similar to GitK.
 
### Requirements
* Git, RubyCocoa, Leopard, RubyGems, open4

### Quick Install
1. Move GitNub.app to /Applications
2. Move (or symlink) nub shell file to /usr/local/bin



### How to Use
In your shell, move to a git directory and invoke `nub`.  You always use this 
helper to invoke the application, otherwise you get nothing.

		$Caged@caged:~/dev/git/gitnub% nub

		
### Building from Source
1. Run `git submodule init` & `git submodule update` in the root directory.
2. Run `rake build` or open GitNub.xcodeproj in Xcode - press Build
3. Run `rake install` to move GitNub.app to /Applications and copy nub to /usr/local/bin.
   
### Major Contributors
* Justin Palmer - Maintainer
* Benjamin Stiglitz 
* Kevin Ballard
* Dustin Sallings
