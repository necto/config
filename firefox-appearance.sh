PROFILE_DIR=~/.mozilla/firefox/mbhhl1f7.default-release
mkdir -p $PROFILE_DIR/chrome
cat > $PROFILE_DIR/chrome/userChrome.css <<EOF
* {
  font-size:12pt !important;
}

#tabbrowser-tabs {
 font-size:14pt !important;
}
EOF

# Increasing all the interface elements (except for fonts)
# (1) In a new tab, type or paste about:config in the address bar and press Return. Click the button accepting the risk.
#(2) In the filter box, type or paste devp and pause while the list is filtered -- there should only be one preference left
#(3) The layout.css.devPixelsPerPx normally has -1.0 which follows the Windows Text Size setting. 

# to enable this custom css, need to:

# 1. In a new tab, type or paste about:config in the address bar and press Enter/Return. Click the button accepting the risk.
# 2. In the search box above the list, type or paste userprof and pause while the list is filtered. If you do not see anything on the list, please ignore the rest of these instructions. You can close this tab now.
# 3. If the toolkit.legacyUserProfileCustomizations.stylesheets preference is not already set to true, double-click it to switch the value from false to true.
# taken from https://www.userchrome.org/firefox-changes-userchrome-css.html
