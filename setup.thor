class Setup < Thor
  include Thor::Actions

  desc 'kickoff', 'this will kickoff the all the steps for running through setup'
  def kickoff
    config = {capture: true, verbose: false}
    ENV['PATH'] = "/opt/homebrew/bin:/usr/local/bin:#{ENV['PATH']}"
    puts 'lets get you all setup!'

    puts 'installing Homebrew'
    homebrew_not_installed = !system('which brew > /dev/null 2>&1')
    if homebrew_not_installed
      run('/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"')
    else
      say "Homebrew already installed"
    end

    puts 'installing XCode tools'
    xcode_not_installed = !system('xcode-select --version > /dev/null 2>&1')
    if xcode_not_installed
      run('xcode-select --install')
    else
      say "XCode already installed"
    end

    puts 'installing all brews'
    brews = %w(
      git git-lfs
      rbenv ruby-build
      node
      postgresql@16
      kubernetes-cli
      awscli terraform flyctl
      fzf fd ripgrep
      starship
      lazydocker htop ctop
      neovim
      httpie tldr
      imagemagick jq tree watch
      gh yarn mas
      zsh-completions cowsay fortune
    )
    brews.each do |brew|
      brew_not_installed = run("brew info #{brew}", config).include? 'Not installed'
      if brew_not_installed
        run("brew install #{brew}")
      else
        say "brew #{brew} already installed"
      end
    end

    puts 'installing all casks'
    casks = %w(
      alfred
      visual-studio-code
      iterm2
      firefox google-chrome brave-browser
      slack
      postman ngrok
      postico
      bartender onyx
      kaleidoscope
      vlc
      caffeine
      docker displaylink
      rectangle
      1password
      zoom
      claude claude-code
    )
    casks.each do |cask|
      cask_not_installed = run("brew info --cask #{cask}", config).include? 'Not installed'
      if cask_not_installed
        run("brew install --cask #{cask}")
      else
        say "cask #{cask} already installed"
      end
    end

    puts 'all finished up!'
  end
end
