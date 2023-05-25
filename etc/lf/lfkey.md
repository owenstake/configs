
[lf command - github.com/gokcehan/lf - Go Packages](https://pkg.go.dev/github.com/gokcehan/lf#section-readme )

[Using LF file manager on windows. LF is an extremely fast and… | by Ali Mostafavi | Medium](https://medium.com/@a.hr.mostafavi/using-lf-file-manager-on-windows-fc4f1e4e1442 )

[dotfiles/lf-windows at main · ahrm/dotfiles · GitHub](https://github.com/ahrm/dotfiles/tree/main/lf-windows )

zlua
[dotfiles/lfrc at main · horriblename/dotfiles · GitHub](https://github.com/horriblename/dotfiles/blob/main/.config/lf/lfrc )

set shell powershell
[lf/lfrc.ps1.example at f66e5824a11793f6ffee0c0d7ef6d3c28435287a · humbertocarmona/lf](https://github.com/humbertocarmona/lf/blob/f66e5824a11793f6ffee0c0d7ef6d3c28435287a/etc/lfrc.ps1.example#L2 )

   1   │ keys        command
   2   │ !       shell-wait -- []
   3   │ "       mark-remove -- []
   4   │ $       shell -- []
   5   │ %       shell-pipe -- []
   6   │ &       shell-async -- []
   7   │ '       mark-load -- []
   8   │ ,       find-prev -- []
   9   │ /       search -- []
  10   │ :       read -- []
  11   │ ;       find-next -- []
  12   │ <c-b>       page-up -- []
  13   │ <c-d>       half-down -- []
  14   │ <c-e>       scroll-down -- []
  15   │ <c-f>       page-down -- []
  16   │ <c-l>       redraw -- []
  17   │ <c-m-down>  scroll-down -- []
  18   │ <c-m-up>    scroll-up -- []
  19   │ <c-n>       cmd-history-next -- []
  20   │ <c-p>       cmd-history-prev -- []
  21   │ <c-r>       reload -- []
  22   │ <c-u>       half-up -- []
  23   │ <c-y>       scroll-up -- []
  24   │ <down>      down -- []
  25   │ <end>       bottom -- []
  26   │ <f-1>       doc -- []
  27   │ <home>      top -- []
  28   │ <left>      updir -- []
  29   │ <m-down>    down -- []
  30   │ <m-up>      up -- []
  31   │ <pgdn>      page-down -- []
  32   │ <pgup>      page-up -- []
  33   │ <right>     open -- []
  34   │ <space>     :{{ toggle -- []; down -- []; }}
  35   │ <up>        up -- []
  36   │ ?       search-back -- []
  37   │ F       find-back -- []
  38   │ G       bottom -- []
  39   │ H       high -- []
  40   │ L       low -- []
  41   │ M       middle -- []
  42   │ N       search-prev -- []
  43   │ [       jump-prev -- []
  44   │ ]       jump-next -- []
  45   │ c       clear -- []
  46   │ d       cut -- []
  47   │ e       ${{ %EDITOR% %f% }}
  48   │ f       find -- []
  49   │ gg      top -- []
  50   │ gh      cd -- [~]
  51   │ h       updir -- []
  52   │ i       !{{ %PAGER% %f% }}
  53   │ j       down -- []
  54   │ k       up -- []
  55   │ l       open -- []
  56   │ m       mark-save -- []
  57   │ n       search-next -- []
  58   │ p       paste -- []
  59   │ q       quit -- []
  60   │ r       rename -- []
  61   │ sa      :{{ set sortby atime; set info atime; }}
  62   │ sc      :{{ set sortby ctime; set info ctime; }}
  63   │ se      :{{ set sortby ext; set info ; }}
  64   │ sn      :{{ set sortby natural; set info ; }}
  65   │ ss      :{{ set sortby size; set info size; }}
  66   │ st      :{{ set sortby time; set info time; }}
  67   │ t       tag-toggle -- []
  68   │ u       unselect -- []
  69   │ v       invert -- []
  70   │ w       ${{ %SHELL% }}
  71   │ y       copy -- []
  72   │ za      set info size:time
  73   │ zh      set hidden!
  74   │ zn      set info
  75   │ zr      set reverse!
  76   │ zs      set info size
  77   │ zt      set info time
  
  
