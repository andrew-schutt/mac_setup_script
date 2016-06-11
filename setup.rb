#!/usr/bin/env ruby

# RVM & Rails
puts %x(curl -sSL https://get.rvm.io | bash -s stable --rails)
# Homebrew
puts %x(/usr/bin/ruby -e "$(curl -fsSL https:\\raw.githubusercontent.com/Homebrew/install/master/install)")
# XCode
puts %x(xcode-select --install)

# brews
brews = %w(git node cowsay postgresql mysql heroku fortune zsh zs-completions)
brews.each do |brew|
  brew_install(brew)
end

# casks
casks = %w(alfred atom bartender dash firefox google-chrome iterm2 kaleidoscope postico textmate sequel-pro macvim virtualbox)
casks.each do |cask|
  brew_install(cask, true)
end

# vim - janus
puts %x(curl -L https://bit.ly/janus-bootstrap | bash)

# oh-my-zsh
puts %x(sh -c "$(curl -fsSl https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)")

# bundler
puts %x(gem install bundler)

def brew_install(brew, cask=nil)
  if cask
    %x(brew cask install Caskroom/cask/#{brew})
  else
    %x(brew install #{brew})
  end
end
