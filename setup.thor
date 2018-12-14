class Setup < Thor
  include Thor::Actions

  desc 'kickoff', 'this will kickoff the all the steps for running through setup'
  def kickoff
    config = {capture: true, verbose: false}
    puts 'lets get you all setup!'

    puts 'installing Homebrew'
    homebrew_not_installed = run('brew --version', config).include?('command not found')
    if homebrew_not_installed then
      run('/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"', config)
    else
      say "Homebrew already installed"
    end

    puts 'installing RVM'
    rvm_not_installed = run('rvm --version', config).include? 'command not found'
    if rvm_not_installed then
      run('\curl -sSL https://get.rvm.io | bash -s stable')
    else
      say "RVM already installed"
    end

    puts 'installing XCode'
    xcode_not_installed = run('xcode-select --version', config).include? 'command not found'
    if xcode_not_installed then
      run('xcode-select --install')
    else
      say "XCode already installed"
    end

    puts 'installing all brews'
    brews = %w(git elixir cowsay postgresql mysql mongodb fortune zsh kubectl
               zsh-completions imagemagick exercism redis jq tree kotlin cfssl)
    brews.each do |brew|
      brew_not_installed = run("brew info #{brew}", config).include? 'Not installed'
      if brew_not_installed then
        run("brew install #{brew}")
      else
        say "brew #{brew} already installed"
      end
    end

    puts 'installing all casks'
    casks = %w(alfred atom bartender caffeine firefox google-chrome iterm2
               kaleidoscope postico sequel-pro slack onyx vlc postman ngrok)
     casks.each do |cask|
       cask_not_installed = run("brew cask info #{cask}", config).include? 'Not installed'
       if cask_not_installed then
         run("brew cask install #{cask}")
       else
         say "brew cask #{cask} already installed"
       end
     end

    puts 'all finished up!'
  end
end
