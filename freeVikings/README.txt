[[[[[[[[[[   freeVikings  ]]]]]]]]]
[   release XXXXXXXX, DDDDDDDDDD  ]

Welcome to freeVikings, an open source clone of great DOS game Lost Vikings.


== INSTALLATION

| Instructions on installation contained in this README are meant as a quick |
| start-up for experienced users. For much more detailed manual see          |
| "freeVikings user's manual":                                               |
| ./docs/user_manual/usermanual.html                                         |

* Get ruby [http://www.ruby-lang.org/en/downloads/]

* Get following libraries:
   - RUDL [http://sourceforge.net/projects/rudl/]
   - REXML [included in newer ruby distributions || 
            http://www.germane-software.com/software/rexml/]

   - Log4r [optional, you don't need it unless you want to debug freeVikings
            http://raa.ruby-lang.org/project/log4r/]

As soon as you have finished installation of Ruby and necessary libraries,
you are ready to play freeVikings. Game itself doesn't need any installation
or compilation.

=== Note: redistributed libraries
A part of library 'script' by Joel VanderWerf is included in freeVikings 
distribution. (file 'lib/script.rb') It is distributed under the terms of Ruby 
license. 'script.rb' which is currently distributed with freeVikings is from
script 0.3 (see [http://raa.ruby-lang.org/project/script/])


== PLAYING

# chdir to the freeVikings directory:
$ cd freeVikings/

# read about game controls:
$ less HELP

# play!
$ ruby ./freevikings.rb


== SUPPORT

You may get some awful errors instead of the game. Try to solve them or
go to [http://sourceforge.net/projects/freevikings/] and send bug report
using the Bug tracker. You can also send your bug report via e-mail
(severus@post.cz)


== I WOULD LIKE TO HELP

Really? It's great! Any help is welcome.
Surely there is much to do I don't know about, but some tips:
- graphics
- level design
- music and sounds
(if you are a programmer, see TODO for inspiration where to start)
