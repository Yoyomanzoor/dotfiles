function y --description 'Yazi with shell directory handoff'
    set -l tmp (mktemp -t yazi-cwd.XXXXXX)
    command yazi $argv --cwd-file="$tmp"
    set -l yazi_status $status
    if test -s "$tmp"
        set -l cwd (command cat -- "$tmp")
        if test -n "$cwd"; and test -d "$cwd"; and test "$cwd" != "$PWD"
            builtin cd -- "$cwd"
        end
    end
    command rm -f -- "$tmp"
    return $yazi_status
end
