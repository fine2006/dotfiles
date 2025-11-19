if status is-interactive
    # Commands to run in interactive sessions can go here

    set -U fish_greeting
    fish_add_path /var/home/fine/.local/share/gem/ruby/3.4.0/bin/
    fish_add_path /var/home/fine/.pub-cache/bin/
    fish_add_path /var/home/fine/.cargo/bin/
    set -gx GEM_HOME $HOME/gems
    set -gx CHROME_EXECUTABLE /usr/bin/trivalent
    set -gx EDITOR /home/linuxbrew/.linuxbrew/bin/nvim
    # set -gx LD_PRELOAD libhardened_malloc.so
    fish_add_path /var/home/fine/gems/bin
    alias gcc gcc-11
    alias nv "NVIM_APPNAME=nvim-minimal nvim"
end
