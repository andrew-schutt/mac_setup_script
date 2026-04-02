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
      git git-lfs git-delta
      rbenv ruby-build
      nvm
      direnv
      postgresql@16
      kubernetes-cli
      awscli terraform flyctl
      fzf fd ripgrep
      starship
      lazydocker htop ctop
      docker docker-compose docker-machine
      neovim
      httpie tldr bat
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
      logitech-g-hub
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

    puts 'configuring rbenv'
    zshrc = File.expand_path('~/.zshrc')
    if File.read(zshrc).include?('rbenv init')
      say 'rbenv already configured in .zshrc'
    else
      File.open(zshrc, 'a') { |f| f.puts "\neval \"$(rbenv init - zsh)\"" }
      say 'rbenv added to .zshrc'
    end

    puts 'configuring starship'
    if File.read(zshrc).include?('starship init')
      say 'starship already configured in .zshrc'
    else
      File.open(zshrc, 'a') { |f| f.puts "\neval \"$(starship init zsh)\"" }
      say 'starship added to .zshrc'
    end

    puts 'configuring fzf'
    if File.read(zshrc).include?('fzf')
      say 'fzf already configured in .zshrc'
    else
      run('$(brew --prefix)/opt/fzf/install --all --no-bash --no-fish')
    end

    puts 'configuring nvm'
    nvm_config = <<~NVM
      export NVM_DIR="$HOME/.nvm"
      [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \\. "/opt/homebrew/opt/nvm/nvm.sh"
    NVM
    if File.read(zshrc).include?('NVM_DIR')
      say 'nvm already configured in .zshrc'
    else
      File.open(zshrc, 'a') { |f| f.puts "\n#{nvm_config}" }
      say 'nvm added to .zshrc'
    end
    run('bash -c "source /opt/homebrew/opt/nvm/nvm.sh && nvm install --lts && nvm alias default node"')

    puts 'configuring direnv'
    direnv_hook = 'eval "$(direnv hook zsh)"'
    if File.read(zshrc).include?('direnv hook')
      say 'direnv already configured in .zshrc'
    else
      File.open(zshrc, 'a') { |f| f.puts "\n#{direnv_hook}" }
      say 'direnv added to .zshrc'
    end

    puts 'configuring git-delta'
    run('git config --global core.pager delta')
    run('git config --global interactive.diffFilter "delta --color-only"')
    run('git config --global delta.navigate true')
    run('git config --global merge.conflictstyle diff3')
    run('git config --global diff.colorMoved default')

    puts 'installing latest ruby via rbenv'
    latest_ruby = run("rbenv install -l 2>/dev/null | grep -v '-' | tail -1", config).strip
    installed_rubies = run('rbenv versions --bare', config)
    if installed_rubies.include?(latest_ruby)
      say "ruby #{latest_ruby} already installed"
    else
      run("rbenv install #{latest_ruby}")
    end
    run("rbenv global #{latest_ruby}")

    puts 'installing bundler'
    run('gem install bundler')

    puts 'installing oh-my-zsh'
    if Dir.exist?(File.expand_path('~/.oh-my-zsh'))
      say 'oh-my-zsh already installed'
    else
      run('sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"')
    end

    puts 'installing Nord iTerm2 color scheme'
    nord_source = File.expand_path('../dotfiles/Nord.itermcolors', __dir__)
    nord_dest = File.expand_path('~/Library/Application Support/iTerm2/ColorSchemes/Nord.itermcolors')
    FileUtils.mkdir_p(File.dirname(nord_dest))
    if File.exist?(nord_dest)
      say 'Nord iTerm2 color scheme already installed'
    elsif File.exist?(nord_source)
      FileUtils.cp(nord_source, nord_dest)
      say 'Nord color scheme copied — select it in iTerm2 → Preferences → Profiles → Colors'
    else
      say "Nord.itermcolors not found at #{nord_source}, skipping"
    end

    puts 'configuring macOS defaults'

    # Close any open System Preferences panes
    run('osascript -e \'tell application "System Preferences" to quit\'')

    # General UI/UX
    run('sudo pmset -a standbydelay 86400')
    run('sudo nvram SystemAudioVolume=" "')
    run('defaults write com.apple.universalaccess reduceTransparency -bool true')
    run('defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"')
    run('defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true')
    run('defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true')
    run('defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true')
    run('defaults write com.apple.LaunchServices LSQuarantine -bool false')
    run('defaults write com.apple.CrashReporter DialogType -string "none"')

    # Trackpad, keyboard, Bluetooth
    run('defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40')
    run('defaults write NSGlobalDomain KeyRepeat -int 1')
    run('defaults write NSGlobalDomain InitialKeyRepeat -int 10')

    # Mouse - enable right click
    run('defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode -string "TwoButton"')
    run('defaults write com.apple.driver.AppleHIDMouse Button2 -int 1')

    # Screen
    run('defaults write com.apple.screensaver askForPassword -int 1')
    run('defaults write com.apple.screensaver askForPasswordDelay -int 0')
    run('defaults write com.apple.screencapture location -string "${HOME}/Desktop"')
    run('defaults write com.apple.screencapture type -string "png"')
    run('defaults write com.apple.screencapture disable-shadow -bool true')

    # Finder
    run('defaults write com.apple.finder QuitMenuItem -bool true')
    run('defaults write com.apple.finder DisableAllAnimations -bool true')
    run('defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true')
    run('defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true')
    run('defaults write com.apple.finder ShowMountedServersOnDesktop -bool true')
    run('defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true')
    run('defaults write NSGlobalDomain AppleShowAllExtensions -bool true')
    run('defaults write com.apple.finder ShowStatusBar -bool true')
    run('defaults write com.apple.finder ShowPathbar -bool true')
    run('defaults write com.apple.finder _FXShowPosixPathInTitle -bool true')
    run('defaults write com.apple.finder _FXSortFoldersFirst -bool true')
    run('defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"')
    run('defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false')
    run('defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true')
    run('defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true')
    run('chflags nohidden ~/Library')
    run('sudo chflags nohidden /Volumes')

    # Dock
    run('defaults write com.apple.dock mouse-over-hilite-stack -bool true')
    run('defaults write com.apple.dock tilesize -int 36')
    run('defaults write com.apple.dock mineffect -string "scale"')
    run('defaults write com.apple.dock minimize-to-application -bool true')
    run('defaults write com.apple.dock show-process-indicators -bool true')
    run('defaults write com.apple.dock expose-group-by-app -bool false')
    run('defaults write com.apple.dock expose-animation-duration -float 0.15')
    run('defaults write com.apple.dock autohide-delay -float 0.0')
    run('defaults write com.apple.dock autohide-time-modifier -float 0.75')
    run('defaults write com.apple.dock autohide -bool true')

    # Safari
    run('defaults write com.apple.Safari UniversalSearchEnabled -bool false')
    run('defaults write com.apple.Safari SuppressSearchSuggestions -bool true')

    # Terminal
    run('defaults write com.apple.terminal StringEncodings -array 4')

    # Activity Monitor
    run('defaults write com.apple.ActivityMonitor OpenMainWindow -bool true')
    run('defaults write com.apple.ActivityMonitor IconType -int 5')
    run('defaults write com.apple.ActivityMonitor ShowCategory -int 0')
    run('defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"')
    run('defaults write com.apple.ActivityMonitor SortDirection -int 0')

    # Mac App Store
    run('defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true')
    run('defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1')
    run('defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1')

    # Photos
    run('defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true')

    # Chrome
    run('defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false')
    run('defaults write com.google.Chrome DisablePrintPreview -bool true')
    run('defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true')

    # Restart affected services
    %w[ActivityMonitor Dock Finder Safari SystemUIServer].each do |app|
      run("killall #{app} 2>/dev/null || true")
    end

    puts 'all finished up!'
  end
end
